#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] The module separates the FMI 3 test functions from the (equally named) FMI 2 ones.
module FMI3Tests

using FMICore, Test, Libdl
import Main: loadReferenceFMU, unloadReferenceFMU, instantiationToken

include.(["utils.jl", "wrappers.jl", "generic.jl", "ME.jl", "CS.jl"])

@testset "Wrappers (arrays and pointers)" begin
    test_wrappers()
end

# Reference FMUs
fmus = Dict(
    name => loadReferenceFMU("3.0", name) for
    name in ("BouncingBall", "Feedthrough", "VanDerPol")
)

if any(isnothing, values(fmus))
    @warn "No FMI 3 Reference FMU binaries for this platform, skipping the FMI 3 Reference FMU tests."
else
    bb, ft, vdp = fmus["BouncingBall"], fmus["Feedthrough"], fmus["VanDerPol"]

    @testset "Generic Functions in ME Mode" begin
        test_generic(bb, fmi3TypeModelExchange)
    end
    @testset "Generic Functions in CS Mode" begin
        test_generic(bb, fmi3TypeCoSimulation)
    end
    @testset "Generic Functions in ME Mode with IO FMU" begin
        test_generic_io(ft, fmi3TypeModelExchange)
    end
    @testset "Generic Functions in CS Mode with IO FMU" begin
        test_generic_io(ft, fmi3TypeCoSimulation)
    end
    @testset "Directional and adjoint derivatives" begin
        test_derivatives(vdp)
    end
    @testset "ME-specific Functions" begin
        test_ME(bb)
    end
    @testset "CS-specific Functions" begin
        test_CS(bb)
    end
end

for fmu in values(fmus)
    isnothing(fmu) || unloadReferenceFMU(fmu)
end

end # module FMI3Tests
