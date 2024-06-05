#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl
include("utils.jl")

binarypath, fmu_path = get_os_binaries()
@test binarypath != ""
if binarypath != ""
    lib = dlopen(binary)

    ## fmi2GetTypesPlatform
    cGetTypesPlatform = dlsym(lib, :fmi2GetTypesPlatform)
    test = fmi2GetTypesPlatform(cGetTypesPlatform)
    @test unsafe_string(test) == "default"
    
    ## fmi2GetVersion TODO get Version from modelDescription.xml
    vers = fmi2GetVersion(dlsym(lib, :fmi2GetVersion))
    @test unsafe_string(vers) == "2.0"

    ## fmi2Instantiate
    cInstantiate = dlsym(lib, :fmi2Instantiate)
    compAddr = fmi2Instantiate(cInstantiate, instantiate_args(fmu_path)...)
    @test compAddr != Ptr{Cvoid}(C_NULL)
    component = fmi2Component(compAddr)

    ## fmi2FreeInstance
    cFree = dlsym(lib, :fmi2FreeInstance)
    fmi2FreeInstance(cFree, component)
    

end




# Callback Functions werden in FMIImport.jl/c.jl definiert

# Download
# Unzip
# OS-Distinction
    # Dynamic Linking
# Tests
