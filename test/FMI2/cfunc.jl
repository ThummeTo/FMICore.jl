#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using ZipFile, Libdl

function getFMU()
    dlpath = Downloads.download("https://github.com/ThummeTo/FMIZoo.jl/raw/main/models/bin/Dymola/2023x/2.0/BouncingBallGravitySwitch1D.fmu")
    unpackPath = mktempdir(; prefix="fmijl_", cleanup=true)
    println(unpackPath)
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

path = getFMU()
binaryPath = joinpath(path, "binaries", "linux64", "BouncingBallGravitySwitch1D")
println(readdir(joinpath(path, "binaries", "linux64")))
lib = dlopen(binaryPath)
# fmu.cInstantiate                  = dlsym(fmu.libHandle, :fmi2Instantiate)
# Download
# Unzip
# OS-Distinction
    # Dynamic Linking
# Tests
