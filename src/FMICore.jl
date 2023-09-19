#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMICore

using Requires
import ChainRulesCore
import Base: show

# check float size (32 or 64 bits)
juliaArch = Sys.WORD_SIZE
@assert (juliaArch == 64 || juliaArch == 32) "FMICore: Unknown Julia Architecture with $(juliaArch)-bit, must be 64- or 32-bit."
Creal = Cdouble
if juliaArch == 32
    Creal = Cfloat
end

# checks if integrator has NaNs (that is not good...)
function assert_integrator_valid(integrator)
    @assert !isnan(integrator.opts.internalnorm(integrator.u, integrator.t)) "NaN in `integrator.u` @ $(integrator.t)."
end

# copy only if field can't be overwritten
function fast_copy!(str, dst::Symbol, src)
    @assert false "fast_copy! not implemented for src of type $(typeof(src))"
end
function fast_copy!(str, dst::Symbol, src::Nothing)
    setfield!(str, dst, nothing)
end
function fast_copy!(str, dst::Symbol, src::AbstractArray)
    tmp = getfield(str, dst)
    if isnothing(tmp) || length(tmp) != length(src)
        setfield!(str, dst, copy(src))
    else
        tmp[:] = src
    end
end

include("types.jl")
include("printing.jl")
include("jacobian.jl")

include("FMI2/cconst.jl")
include("FMI2/ctype.jl")
include("FMI2/cfunc.jl")
include("FMI2/cfunc_unload.jl")
include("FMI2/convert.jl")
include("FMI2/struct.jl")
include("FMI2/eval.jl")

include("FMI3/cconst.jl")
include("FMI3/ctype.jl")
include("FMI3/cfunc.jl")
# ToDo: include("FMI3/cfunc_unload.jl")
include("FMI3/convert.jl")
include("FMI3/struct.jl")

include("logging.jl")
include("sense.jl")

# Requires init
function __init__()
    @require FMISensitivity="3e748fe5-cd7f-4615-8419-3159287187d2" begin
        import .FMISensitivity
        include("extensions/FMISensitivity.jl")
    end
end

end # module
