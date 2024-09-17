#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl

include.(["utils.jl", "ME.jl", "CS.jl", "generic.jl"])


binarypath, fmu_path, cblibpath = get_os_binaries()
iopath, io_fmu_path, iocblibpath = get_os_binaries("IO")
if binarypath != ""
    lib = dlopen(binarypath)
    libio = dlopen(iopath)
    # Missing Tests for fmi2<Set, Get><Boolean, String> because the FMU we are testing with doesnt variables of these types
    @testset "Generic Functions in ME Mode" begin
        test_generic(lib, cblibpath, fmi2TypeModelExchange)
    end
    @testset "Generic Functions in ME Mode with IO FMU" begin
        test_generic_io(libio, iocblibpath, fmi2TypeModelExchange)
    end
    @testset "Generic Functions in CS Mode with IO FMU" begin
        test_generic_io(libio, iocblibpath, fmi2TypeCoSimulation)
    end
    @testset "Generic Functions in CS Mode" begin
        test_generic(lib, cblibpath, fmi2TypeCoSimulation)
    end
    @testset "ME-specific Functions" begin
        test_ME(lib, cblibpath)
    end
    @testset "CS-specific Functions" begin
        test_CS(lib, cblibpath)
    end
    @testset "CS-specific Functions with IO FMU" begin
        test_CS_IO(libio, iocblibpath)
    end
else
    @warn "No valid FMU binaries found for this OS. Skipping tests."
end
