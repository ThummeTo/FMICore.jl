#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [Note] The module separates the FMI 2 test functions from the (equally named) FMI 3 ones.
module FMI2Tests

using FMICore, Test, Libdl, Suppressor, Downloads
import Main:
    binaryPlatform, loadReferenceFMU, unloadReferenceFMU, resourceURI, instantiationToken

include.(["utils.jl", "wrappers.jl", "generic.jl", "ME.jl", "CS.jl"])

@testset "Wrappers (arrays and pointers)" begin
    test_wrappers()
end

# Reference FMUs
cblibpath = getCallbackLibrary()
fmus = Dict(
    name => loadReferenceFMU("2.0", name) for
    name in ("BouncingBall", "Feedthrough", "VanDerPol")
)

if fmi2Real != Cdouble
    # [ToDo] `fmi2Real` follows the Julia architecture, but is always a C `double`
    @warn "`fmi2Real` is not `Cdouble` on this architecture, skipping the FMI 2 Reference FMU tests."
elseif isnothing(cblibpath) || any(isnothing, values(fmus))
    @warn "No FMI 2 Reference FMU binaries for this platform, skipping the FMI 2 Reference FMU tests."
else
    callbacks = getCallbacks(cblibpath)
    bb, ft, vdp = (
        merge(fmus[name], (callbacks = callbacks,)) for
        name in ("BouncingBall", "Feedthrough", "VanDerPol")
    )

    @testset "Generic Functions in ME Mode" begin
        test_generic(bb, fmi2TypeModelExchange)
    end
    @testset "Generic Functions in CS Mode" begin
        test_generic(bb, fmi2TypeCoSimulation)
    end
    @testset "Generic Functions in ME Mode with IO FMU" begin
        test_generic_io(ft, fmi2TypeModelExchange)
    end
    @testset "Generic Functions in CS Mode with IO FMU" begin
        test_generic_io(ft, fmi2TypeCoSimulation)
    end
    @testset "Directional derivatives" begin
        test_derivatives(vdp)
    end
    @testset "ME-specific Functions" begin
        test_ME(bb)
    end
    @testset "CS-specific Functions" begin
        test_CS(bb)
    end
    @testset "CS-specific Functions with IO FMU" begin
        test_CS_IO(ft)
    end
end

for fmu in values(fmus)
    isnothing(fmu) || unloadReferenceFMU(fmu)
end
isnothing(cblibpath) || unloadCallbackLibrary(cblibpath)

end # module FMI2Tests
