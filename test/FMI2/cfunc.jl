#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl

include("utils.jl")
include("ME.jl")


binarypath, fmu_path = get_os_binaries()
function get_args()
    callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    [pointer("test2"), fmi2TypeCoSimulation, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), fmi2Boolean(true), fmi2Boolean(true)]
end
@test binarypath != ""
if binarypath != ""
    lib = dlopen(binarypath)
    # @testset "Generic Functions in ME Mode" test_generic(lib, fmi2TypeModelExchange)
    # @testset "ME-specific Functions" test_ME(lib)
    # Test generic functions in CS Mode
    # @testset "CS-specific Functions" test_generic(lib, fmi2TypeCoSimulation)
    @testset "CS-specific Functions" test_CS(lib)
    # test_CS(lib)
    

    # compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test"), fmi2TypeModelExchange, instantiate_args(fmu_path, fmi2TypeModelExchange)...)
    # callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)

    # compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test2"), fmi2TypeCoSimulation, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), fmi2Boolean(true), fmi2Boolean(true))
    # args = get_args()
    # compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), args...)

    # println(compAddr)
end
