#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl

include("utils.jl")
include("ME.jl")

function test_status_ok(status)
    @test typeof(status) == fmi2Status
    @test status == fmi2StatusOK
end

binarypath, fmu_path = get_os_binaries()
@test binarypath != ""
if binarypath != ""
    lib = dlopen(binarypath)
    test_generic(lib, fmi2TypeModelExchange)
    test_generic(lib, fmi2TypeCoSimulation)
   
end




# Callback Functions werden in FMIImport.jl/c.jl definiert

# Download
# Unzip
# OS-Distinction
    # Dynamic Linking
# Tests
