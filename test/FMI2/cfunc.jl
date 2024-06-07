#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl

include("utils.jl")
include("ME.jl")

binarypath, fmu_path = get_os_binaries()
@test binarypath != ""
if binarypath != ""
    lib = dlopen(binarypath)
    # Test generic functions in ME Mode
    test_generic(lib, fmi2TypeModelExchange)

    # Test generic functions in CS Mode
    # test_generic(lib, fmi2TypeCoSimulation)
    # Test ME-specific functions
    test_ME(lib)
   
end
