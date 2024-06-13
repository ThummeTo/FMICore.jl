#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl

include.(["utils.jl", "ME.jl", "CS.jl", "generic.jl"])


binarypath, fmu_path, cblibpath = get_os_binaries()
@test binarypath != ""
if binarypath != ""
    lib = dlopen(binarypath)
    # Missing Tests for fmi2<Set, Get><Boolean, String> because the FMU we are testing with doesnt variables of these types
    @testset "Generic Functions in ME Mode" test_generic(lib,cblibpath, fmi2TypeModelExchange)
    @testset "Generic Functions in CS Mode" test_generic(lib,cblibpath, fmi2TypeCoSimulation)
    @testset "ME-specific Functions" test_ME(lib, cblibpath)
    @testset "CS-specific Functions" test_CS(lib, cblibpath)
    
end
