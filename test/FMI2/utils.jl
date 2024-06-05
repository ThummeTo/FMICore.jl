#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
using ZipFile

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

function instantiate_args()
    # TODO get guid and Name from XML
    guidStr = "{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"
    ptrAllocateMemory = C_NULL
    ptrFreeMemory = C_NULL
    ptrStepFinished = C_NULL # ToDo
    ptrComponentEnvironment = C_NULL
    ptrLogger = C_NULL
    fmi2TypeModelExchange
    instanceName = "BouncingBallGravitySwitch1D"
    callbackFunctions = fmi2CallbackFunctions(ptrLogger, ptrAllocateMemory, ptrFreeMemory, ptrStepFinished, ptrComponentEnvironment)
    resourcelocation = string("file:///", path)
    resourcelocation = joinpath(resourcelocation, "resources")
    resourcelocation = replace(resourcelocation, "\\" => "/")
    type = fmi2TypeModelExchange
    visible = fmi2Boolean(true)
    loggingon = fmi2Boolean(true)

    (pointer(instanceName),type, pointer(guidStr), pointer(resourcelocation), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), visible, loggingon)
end