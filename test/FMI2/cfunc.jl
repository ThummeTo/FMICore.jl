#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using ZipFile, Libdl

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
path = getFMU()
binarypath = joinpath(path, "binaries")
# println(readdir(binarypath))
if Sys.WORD_SIZE == 64
    if Sys.islinux()
        binarypath = joinpath(binarypath, "linux64")
        @test true
    elseif Sys.iswindows()
        binarypath = joinpath(binarypath, "win64")
        @test true
    elseif Sys.isapple()
        binarypath = joinpath(binarypath, "darwin64")
        @test false # the FMU we are testing with only contains Binaries for win<32,64> and linux64
    else
        @test false
    end
elseif Sys.iswindows()
    binarypath = joinpath(binarypath, "win32")
    @test true
else
    @test false
end

binarypath = joinpath(binarypath, "BouncingBallGravitySwitch1D")
lib = dlopen(binarypath)
cInstantiate                  = dlsym(lib, :fmi2Instantiate)
# Download
# Unzip
# OS-Distinction
    # Dynamic Linking
# Tests
