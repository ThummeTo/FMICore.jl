#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
using ZipFile


function getFMU(fmuname::String="BouncingBallGravitySwitch1D")
    if fmuname == "IO"
        dlurl = "https://github.com/ThummeTo/FMIZoo.jl/raw/main/models/bin/Dymola/2023x/2.0/IO.fmu"
    else
        dlurl = "https://github.com/ThummeTo/FMIZoo.jl/raw/main/models/bin/Dymola/2023x/2.0/BouncingBallGravitySwitch1D.fmu"
        fmuname = "BouncingBallGravitySwitch1D"
    end
    dlpath = Downloads.download(dlurl)
    unpackPath = mktempdir(; prefix="fmijl_", cleanup=true)
    unzippedPath = joinpath(unpackPath, fmuname)
    unzippedAbsPath = isabspath(unzippedPath) ? unzippedPath : joinpath(pwd(), unzippedPath)
    numFiles = 0
    if !isdir(unzippedAbsPath)
        mkpath(unzippedAbsPath)

        zarchive = ZipFile.Reader(dlpath)
        for f in zarchive.files
            fileAbsPath = normpath(joinpath(unzippedAbsPath, f.name))
            if endswith(f.name,"/") || endswith(f.name,"\\")
                mkpath(fileAbsPath) # mkdir(fileAbsPath)
                @assert isdir(fileAbsPath) ["fmi2Unzip(...): Can't create directory `$(f.name)` at `$(fileAbsPath)`."]
            else
                # create directory if not forced by zip file folder
                mkpath(dirname(fileAbsPath))

                numBytes = write(fileAbsPath, read(f))

                if numBytes == 0
                    @debug "fmi2Unzip(...): Written file `$(f.name)`, but file is empty."
                end

                @assert isfile(fileAbsPath) ["fmi2Unzip(...): Can't unzip file `$(f.name)` at `$(fileAbsPath)`."]
                numFiles += 1
            end
        end
        close(zarchive)
    end
    unzippedAbsPath
end


function get_os_binaries(fmuname::String="BouncingBallGravitySwitch1D")
    path = getFMU(fmuname)
    binarypath = joinpath(path, "binaries")
    if Sys.WORD_SIZE == 64
        if Sys.islinux()
            binarypath = joinpath(binarypath, "linux64")
            cblibpath = Downloads.download("https://github.com/ThummeTo/FMIImport.jl/raw/main/src/FMI2/callbackFunctions/binaries/linux64/libcallbackFunctions.so")
            os_supported = true
        elseif Sys.iswindows()
            binarypath = joinpath(binarypath, "win64")
            cblibpath = Downloads.download("https://github.com/ThummeTo/FMIImport.jl/raw/main/src/FMI2/callbackFunctions/binaries/win64/callbackFunctions.dll")
            cblibpath = cblibpath * "."
            os_supported = true
        elseif Sys.isapple()
            binarypath = joinpath(binarypath, "darwin64")
            cblibpath = Downloads.download("https://github.com/ThummeTo/FMIImport.jl/raw/main/src/FMI2/callbackFunctions/binaries/darwin64/libcallbackFunctions.dylib")
            os_supported = false # the FMU we are testing with only contains Binaries for win<32,64> and linux64
        else
            os_supported = false
        end
    elseif Sys.iswindows()
        binarypath = joinpath(binarypath, "win32")
        cblibpath = Downloads.download("https://github.com/ThummeTo/FMIImport.jl/raw/main/src/FMI2/callbackFunctions/binaries/win32/callbackFunctions.dll")
        cblibpath = cblibpath * "."
        os_supported = true
    else
        os_supported = false
    end
    if !os_supported
        @warn "The OS or Architecture used for Testing is not compatible with the FMU used for Testing."
        binarypath = ""
        cblibpath = ""
    else
        binarypath = joinpath(binarypath, fmuname)
        perm = filemode(cblibpath)
        permRWX = 16895
        if perm != permRWX
            chmod(cblibpath, permRWX; recursive=true)
        end
    end
    (binarypath, path, cblibpath)
end

mutable struct FMU2ComponentEnvironment
    logStatusOK::Bool
    logStatusWarning::Bool
    logStatusDiscard::Bool
    logStatusError::Bool
    logStatusFatal::Bool
    logStatusPending::Bool

    function FMU2ComponentEnvironment()
        inst = new()
        inst.logStatusOK = true
        inst.logStatusWarning = true
        inst.logStatusDiscard = true
        inst.logStatusError = true
        inst.logStatusFatal = true
        inst.logStatusPending = true
        return inst
    end
end

function get_callbacks(cblibpath)
    compEnv = FMU2ComponentEnvironment()
    ptrComponentEnvironment = Ptr{FMU2ComponentEnvironment}(pointer_from_objref(compEnv))
    callbacklib = dlopen(cblibpath)
    ptrLogger = dlsym(callbacklib, :logger)
    callbackFunctions = fmi2CallbackFunctions(ptrLogger, C_NULL, C_NULL, C_NULL, ptrComponentEnvironment)
    callbackFunctions
end

function fmi2StatusToString(status::Union{fmi2Status, Integer})
    if status == fmi2StatusOK
        return "OK"
    elseif status == fmi2StatusWarning
        return "Warning"
    elseif status == fmi2StatusDiscard
        return "Discard"
    elseif status == fmi2StatusError
        return "Error"
    elseif status == fmi2StatusFatal
        return "Fatal"
    elseif status == fmi2StatusPending
        return "Pending"
    else
        @assert false "fmi2StatusToString($(status)): Unknown FMU status `$(status)`."
    end
end
export fmi2StatusToString

function fmi2CallbackLogger(_componentEnvironment::Ptr{FMU2ComponentEnvironment},
        _instanceName::Ptr{Cchar},
        _status::Cuint,
        _category::Ptr{Cchar},
        _message::Ptr{Cchar})

    message = unsafe_string(_message)
    category = unsafe_string(_category)
    status = fmi2StatusToString(_status)
    instanceName = unsafe_string(_instanceName)
    componentEnvironment = unsafe_load(_componentEnvironment)

    if status == fmi2StatusOK && componentEnvironment.logStatusOK
    @info "[$status][$category][$instanceName]: $message"
    elseif (status == fmi2StatusWarning && componentEnvironment.logStatusWarning) ||
    (status == fmi2StatusPending && componentEnvironment.logStatusPending)
    @warn "[$status][$category][$instanceName]: $message"
    elseif (status == fmi2StatusDiscard && componentEnvironment.logStatusDiscard) ||
    (status == fmi2StatusError   && componentEnvironment.logStatusError) ||
    (status == fmi2StatusFatal   && componentEnvironment.logStatusFatal)
    @error "[$status][$category][$instanceName]: $message"
    end

    return nothing
end

