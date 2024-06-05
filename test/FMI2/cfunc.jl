#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using ZipFile, Libdl
include("utils.jl")

path = getFMU()
binarypath = joinpath(path, "binaries")

if Sys.WORD_SIZE == 64
    if Sys.islinux()
        binarypath = joinpath(binarypath, "linux64")
        os_supported = true
    elseif Sys.iswindows()
        binarypath = joinpath(binarypath, "win64")
        os_supported = true
    elseif Sys.isapple()
        binarypath = joinpath(binarypath, "darwin64")
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
@test os_supported
if !os_supported
    @warn "Running Tests on a System/OS that is not supported by the FMU we are testing with"
else
    binarypath = joinpath(binarypath, "BouncingBallGravitySwitch1D")
    lib = dlopen(binarypath)
end



cInstantiate = dlsym(lib, :fmi2Instantiate)
compAddr = fmi2Instantiate(cInstantiate, instantiate_args()...)
@test compAddr != Ptr{Cvoid}(C_NULL)
component = fmi2Component(compAddr)
println(fmi2Component(compAddr))
cFree = dlsym(lib, :fmi2FreeInstance)
fmi2FreeInstance(cFree, component)
# fmi2FreeInstance(cFree, component)

## fmi2GetTypesPlatform
cGetTypesPlatform = dlsym(lib, :fmi2GetTypesPlatform)
test = fmi2GetTypesPlatform(cGetTypesPlatform)
@test unsafe_string(test) == "default"

## fmi2GetVersion TODO get Version from modelDescription.xml
vers = fmi2GetVersion(dlsym(lib, :fmi2GetVersion))
@test unsafe_string(vers) == "2.0"


# Callback Functions werden in FMIImport.jl/c.jl definiert

# Download
# Unzip
# OS-Distinction
    # Dynamic Linking
# Tests
