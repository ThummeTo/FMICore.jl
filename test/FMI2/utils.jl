#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
using ZipFile

function test_status_ok(status)
    @test typeof(status) == fmi2Status
    @test status == fmi2StatusOK
end

function getFMU()
    dlpath = Downloads.download("https://github.com/ThummeTo/FMIZoo.jl/raw/main/models/bin/Dymola/2023x/2.0/BouncingBallGravitySwitch1D.fmu")
    unpackPath = mktempdir(; prefix="fmijl_", cleanup=true)
    unzippedPath = joinpath(unpackPath, "BouncingBallGravitySwitch1D")
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

function instantiate_args(fmuPath, type::fmi2Type)
    # TODO get guid and Name from XML
    guidStr = "{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"
    callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    # include("build_callbacks.jl")
    # callbackFunctions = build_callbacks()
    instanceName = "BouncingBallGravitySwitch1D$(type)"
    resourcelocation = string("file:///", fmuPath)
    # resourcelocation = joinpath(resourcelocation, "resources")
    # resourcelocation = replace(resourcelocation, "\\" => "/")
    visible = fmi2Boolean(true)
    loggingon = fmi2Boolean(true)

    # (pointer(instanceName), type, pointer(guidStr), pointer(resourcelocation), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), visible, loggingon)
    [pointer(guidStr), pointer(resourcelocation), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), visible, loggingon]
end

function get_os_binaries()
    path = getFMU()
    binarypath = joinpath(path, "binaries")
    cblibpath = joinpath(pwd(), "FMI2","callbackFunctions")
    if Sys.WORD_SIZE == 64
        if Sys.islinux()
            binarypath = joinpath(binarypath, "linux64")
            cblibpath = joinpath(cblibpath, "linux64")
            os_supported = true
        elseif Sys.iswindows()
            binarypath = joinpath(binarypath, "win64")
            cblibpath = joinpath(cblibpath, "win64")
            os_supported = true
        elseif Sys.isapple()
            binarypath = joinpath(binarypath, "darwin64")
            cblibpath = joinpath(cblibpath, "darwin64")
            os_supported = false # the FMU we are testing with only contains Binaries for win<32,64> and linux64
        else
            os_supported = false
        end
    elseif Sys.iswindows()
        binarypath = joinpath(binarypath, "win32")
        os_supported = true
    else
        os_supported = false
    end
    if !os_supported
        @warn "The OS or Architecture used for Testing is not compatible with the FMU used for Testing."
        binarypath = ""
    else
        binarypath = joinpath(binarypath, "BouncingBallGravitySwitch1D")
    end
    cblibpath = joinpath(cblibpath, "callbackFunctions")
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

function fmi2CallbackAllocateMemory(nobj::Csize_t, size::Csize_t)
    ptr = Libc.calloc(nobj, size)
    @debug "cbAllocateMemory($(nobj), $(size)): Allocated $(nobj) x $(size) bytes at $(ptr)."
	ptr
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Function that must be called in the FMU if memory is freed that has been allocated with allocateMemory. If a null pointer is provided as input argument obj, the function shall perform no action [(a simple implementation is to use free from the C standard library; in ANSI C89 and C99, the null pointer handling is identical as defined here)]. If attribute “canNotUseMemoryManagementFunctions = true” in <fmiModelDescription><ModelExchange / CoSimulation>, then function freeMemory is not used in the FMU and a null pointer can be provided.
"""
function fmi2CallbackFreeMemory(obj::Ptr{Cvoid})
    @debug "cbFreeMemory($(obj)): Freeing object at $(obj)."
	Libc.free(obj)
    nothing
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

