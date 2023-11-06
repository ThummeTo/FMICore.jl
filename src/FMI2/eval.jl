#
# Copyright (c) 2022 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in the file `eval.jl`?
# - calling function for FMU2 and FMU2Component

import FMICore: fmi2ValueReference
import ChainRulesCore: ignore_derivatives

"""

    (fmu::FMU2)(;dx::AbstractVector{<:Real},
                 y::AbstractVector{<:Real},
                 y_refs::AbstractVector{<:fmi2ValueReference},
                 x::AbstractVector{<:Real}, 
                 u::AbstractVector{<:Real},
                 u_refs::AbstractVector{<:fmi2ValueReference},
                 p::AbstractVector{<:Real},
                 p_refs::AbstractVector{<:fmi2ValueReference},
                 ec::AbstractVector{<:Real},
                 t::Real)

Evaluates a `FMU2` by setting the component state `x`, inputs `u` and/or time `t`. If no component is available, one is allocated. The result of the evaluation might be the system output `y` and/or state-derivative `dx`. 
Not all options are available for any FMU type, e.g. setting state is not supported for CS-FMUs. Assertions will be generated for wrong use.

# Keywords
- `dx`: An array to store the state-derivatives in. If not provided but necessary, a suitable array is allocated and returned. Not supported by CS-FMUs.
- `y`: An array to store the system outputs in. If not provided but requested, a suitable array is allocated and returned.
- `y_refs`: An array of value references to indicate which system outputs shall be returned.
- `x`: An array containing the states to be set. Not supported by CS-FMUs.
- `u`: An array containing the inputs to be set.
- `u_refs`: An array of value references to indicate which system inputs want to be set.
- `p`: An array of FMU parameters to be set.
- `p_refs`: An array of parameter references to indicate which system parameter sensitivities need to be determined.
- `ec`: An array of real valued implicit event conditions ("event indicators")
- `t`: A scalar value holding the system time to be set.

# Returns (as Tuple)
- `y::Union{AbstractVector{<:Real}, Nothing}`: The system output `y` (if requested, otherwise `nothing`).
- `dx::Union{AbstractVector{<:Real}, Nothing}`: The system state-derivaitve (if ME-FMU, otherwise `nothing`).
- `ec::Union{AbstractVector{<:Real}, Nothing}`: The system event indicators (if ME-FMU, otherwise `nothing`).
"""
function (fmu::FMU2)(;dx_refs::Union{AbstractVector{<:fmi2ValueReference}, Symbol}=fmu.default_dx_refs, 
                      kwargs...)

    if dx_refs == :all 
        dx_refs = fmu.modelDescription.derivativeValueReferences
    elseif dx_refs == :none 
        dx_refs = EMPTY_fmi2ValueReference
    end

    @assert hasCurrentComponent(fmu) "Calling FMU, but no FMU2Component allocated."
    c = getCurrentComponent(fmu)

    return (c)(;dx_refs=dx_refs, kwargs...)
end

"""

    (c::FMU2Component)(;dx::AbstractVector{<:Real},
                        y::AbstractVector{<:Real},
                        y_refs::AbstractVector{<:fmi2ValueReference},
                        x::AbstractVector{<:Real}, 
                        u::AbstractVector{<:Real},
                        u_refs::AbstractVector{<:fmi2ValueReference},
                        p::AbstractVector{<:Real},
                        p_refs::AbstractVector{<:fmi2ValueReference},
                        ec::AbstractVector{<:Real},
                        t::Real)

Evaluates a `FMU2Component` by setting the component state `x`, inputs `u` and/or time `t`. The result of the evaluation might be the system output `y` and/or state-derivative `dx`. 
Not all options are available for any FMU type, e.g. setting state is not supported for CS-FMUs. Assertions will be generated for wrong use.

# Keywords
- `dx`: An array to store the state-derivatives in. If not provided but necessary, a suitable array is allocated and returned. Not supported by CS-FMUs.
- `y`: An array to store the system outputs in. If not provided but requested, a suitable array is allocated and returned.
- `y_refs`: An array of value references to indicate which system outputs shall be returned.
- `x`: An array containing the states to be set. Not supported by CS-FMUs.
- `u`: An array containing the inputs to be set.
- `u_refs`: An array of value references to indicate which system inputs want to be set.
- `p`: An array of FMU parameters to be set.
- `p_refs`: An array of parameter references to indicate which system parameter sensitivities need to be determined.
- `ec`: An array of real valued implicit event conditions ("event indicators")
- `t`: A scalar value holding the system time to be set.

# Returns (as Tuple)
- `y::Union{AbstractVector{<:Real}, Nothing}`: The system output `y` (if requested, otherwise `nothing`).
- `dx::Union{AbstractVector{<:Real}, Nothing}`: The system state-derivaitve (if ME-FMU, otherwise `nothing`).
- `ec::Union{AbstractVector{<:Real}, Nothing}`: The system event indicators (if ME-FMU, otherwise `nothing`).
"""
function (c::FMU2Component)(dx::AbstractVector{<:Real},
                            dx_refs::AbstractVector{<:fmi2ValueReference},
                            y::AbstractVector{<:Real},
                            y_refs::AbstractVector{<:fmi2ValueReference},
                            x::AbstractVector{<:Real},
                            u::AbstractVector{<:Real},
                            u_refs::AbstractVector{<:fmi2ValueReference},
                            p::AbstractVector{<:Real},
                            p_refs::AbstractVector{<:fmi2ValueReference},
                            ec::AbstractVector{<:Real},
                            ec_idcs::AbstractVector{<:fmi2ValueReference},
                            t::Real)

    # CS and ME 
    if length(y_refs) > 0
        if y === c.default_y
            if length(y) != length(y_refs)
                c.default_y = zeros(fmi2Real, length(y_refs))
                logInfo(c.fmu, "Automatically allocated `y` for given `y_refs`")
                y = c.default_y
            end
        end
    end

    # Model-Exchange only
    if !isnothing(c.fmu.modelDescription.modelExchange)
        if c.type == fmi2TypeModelExchange::fmi2Type
            
            if dx === c.default_dx
                if length(dx) != length(dx_refs)
                    c.default_dx = zeros(fmi2Real, length(dx_refs))
                    logInfo(c.fmu, "Automatically allocated `dx` because of ME.")
                    dx = c.default_dx
                end
            end

            if length(ec_idcs) > 0
                if ec === c.default_ec
                    if length(ec) != length(ec_idcs)
                        c.default_ec = zeros(fmi2ValueReference, length(ec_idcs))
                        logInfo(c.fmu, "Automatically allocated `ec` for given `ec_idcs`")
                        ec = c.default_ec
                    end
                end
            end
           
        end
    end

    @assert (length(dx) == length(dx_refs)) || (length(dx) == length(c.fmu.modelDescription.derivativeValueReferences)) "Length of `dx` ($(length(dx))) must match:\n- number of given derivative references `dx_refs` (=$(length(dx_refs))) or\n- absolute number of derivatives (=$(length(c.fmu.modelDescription.derivativeValueReferences)))."
    @assert (length(y) == length(y_refs)) "Length of `y` must match length of `y_refs`."
    @assert (length(u) == length(u_refs)) "Length of `u` must match length of `u_refs`."
    @assert (length(p) == length(p_refs)) "Length of `p` must match length of `p_refs`."
    @assert (length(ec) == length(ec_idcs)) || (length(ec) == c.fmu.modelDescription.numberOfEventIndicators) "Length of `ec` ($(length(ec))) must match:\n- number of given event indicators `ec_idcs` (=$(length(ec_idcs))) or\n- absolute number of event indicators (=$(c.fmu.modelDescription.numberOfEventIndicators))."

    # Co-Simulation only
    if !isnothing(c.fmu.modelDescription.coSimulation)
        if c.type == fmi2TypeCoSimulation::fmi2Type

            if dx === c.default_dx
                if length(dx) != 0
                    c.default_dx = EMPTY_fmi2Real
                    logInfo(c.fmu, "Automatically deallocated `dx` because of CS.")
                    dx = c.default_dx
                end
            end

            @assert length(ec) <= 0 "Keyword `ec != []` is invalid for CS-FMUs. Setting a buffer for event indicators is not possible in CS."
            @assert length(dx) <= 0 "Keyword `dx != []` is invalid for CS-FMUs. Setting a state-derivative is not possible in CS."
            @assert length(x) <= 0 "Keyword `x != []` is invalid for CS-FMUs. Setting a state is not possible in CS."
            @assert t < 0.0 "Keyword `t != []` is invalid for CS-FMUs. Setting explicit time is not possible in CS."
        end
    end

    # [ToDo] This is necessary, because ForwardDiffChainRules.jl can't handle arguments with type `Ptr{Nothing}`.
    cRef = nothing
    ignore_derivatives() do
        cRef = pointer_from_objref(c)
        cRef = UInt64(cRef)
    end

    if c.fmu.executionConfig.concat_eval
        
        ret = eval!(cRef, dx, dx_refs, y, y_refs, x, u, u_refs, p, p_refs, ec, ec_idcs, t)

        len_dx = length(dx)
        len_y = length(y_refs)
        len_ec = length(ec)

        if len_dx > 0
            c.eval_output.dx = ret[1:len_dx]
        else
            c.eval_output.dx = nothing
        end

        if len_y > 0
            c.eval_output.y = ret[1+len_dx:len_dx+len_y]
        else
            c.eval_output.y = nothing
        end 

        if len_ec > 0
            c.eval_output.ec = ret[1+len_dx+len_y:end]
        else
            c.eval_output.ec = nothing
        end
       
    else
        
        c.eval_output.dx, c.eval_output.y, c.eval_output.ec = eval!(cRef, dx, dx_refs, y, y_refs, x, u, u_refs, p, p_refs, ec, ec_idcs, t)
    end

    return c.eval_output
end

function (c::FMU2Component)(;dx::AbstractVector{<:Real}=c.default_dx,
                             dx_refs::AbstractVector{<:fmi2ValueReference}=c.default_dx_refs,
                             y::AbstractVector{<:Real}=c.default_y,
                             y_refs::AbstractVector{<:fmi2ValueReference}=c.default_y_refs,
                             x::AbstractVector{<:Real}=EMPTY_fmi2Real, 
                             u::AbstractVector{<:Real}=EMPTY_fmi2Real,
                             u_refs::AbstractVector{<:fmi2ValueReference}=EMPTY_fmi2ValueReference,
                             p::AbstractVector{<:Real}=c.default_p, 
                             p_refs::AbstractVector{<:fmi2ValueReference}=c.default_p_refs, 
                             ec::AbstractVector{<:Real}=c.default_ec, 
                             ec_idcs::AbstractVector{<:fmi2ValueReference}=c.default_ec_idcs,
                             t::Real=c.default_t)
    (c)(dx, dx_refs, y, y_refs, x, u, u_refs, p, p_refs, ec, ec_idcs, t)
end

function eval!(cRef, dx, dx_refs, y, y_refs, x, u, u_refs, p, p_refs, ec, ec_idcs, t)
    @assert isa(ec, AbstractArray{fmi2Real}) "eval!(...): Wrong dispatched: `ec` is `ForwardDiff.Dual` or `ReverseDiff.TrackedReal`.\nThis is most likely because you tried differentiating over a FMU.\nIf so, you need to `import FMISensitivity` first."
    @assert isa(x, AbstractArray{fmi2Real}) "eval!(...): Wrong dispatched: `x` is `ForwardDiff.Dual` or `ReverseDiff.TrackedReal`.\nThis is most likely because you tried differentiating over a FMU.\nIf so, you need to `import FMISensitivity` first."
    @assert isa(u, AbstractArray{fmi2Real}) "eval!(...): Wrong dispatched: `u` is `ForwardDiff.Dual` or `ReverseDiff.TrackedReal`.\nThis is most likely because you tried differentiating over a FMU.\nIf so, you need to `import FMISensitivity` first."
    @assert isa(t, fmi2Real)                "eval!(...): Wrong dispatched: `t` is `ForwardDiff.Dual` or `ReverseDiff.TrackedReal`.\nThis is most likely because you tried differentiating over a FMU.\nIf so, you need to `import FMISensitivity` first."
    @assert isa(p, AbstractArray{fmi2Real}) "eval!(...): Wrong dispatched: `p` is `ForwardDiff.Dual` or `ReverseDiff.TrackedReal`.\nThis is most likely because you tried differentiating over a FMU.\nIf so, you need to `import FMISensitivity` first."
    @assert false "Fatal error, no dispatch implemented!\nPlease open an issue with MWE and attach error message:\neval!($(typeof(cRef)), $(typeof(dx)), $(typeof(y)), $(typeof(y_refs)), $(typeof(x)), $(typeof(u)), $(typeof(u_refs)), $(typeof(p)), $(typeof(p_refs)), $(typeof(t)))"
end

function eval!(cRef::UInt64, 
    dx::AbstractVector{<:fmi2Real},
    dx_refs::AbstractVector{<:fmi2ValueReference},
    y::AbstractVector{<:fmi2Real},
    y_refs::AbstractVector{<:fmi2ValueReference},
    x::AbstractVector{<:fmi2Real}, 
    u::AbstractVector{<:fmi2Real},
    u_refs::AbstractVector{<:fmi2ValueReference},
    p::AbstractVector{<:fmi2Real},
    p_refs::AbstractVector{<:fmi2ValueReference},
    ec::AbstractVector{<:fmi2Real}, 
    ec_idcs::AbstractVector{<:fmi2ValueReference},
    t::fmi2Real)

    c = unsafe_pointer_to_objref(Ptr{Nothing}(cRef))

    # set state
    if length(x) > 0 && !c.fmu.isZeroState
        fmi2SetContinuousStates(c, x)
    end

    # set time
    if t >= 0.0
        fmi2SetTime(c, t)
    end

    # set input
    if length(u) > 0 
        fmi2SetReal(c, u_refs, u)
    end

    # set parameters DURING simulation, this is very uncommon, but can be necessary if "tunable" parameters are optimized during simulation
    if length(p) > 0 && c.fmu.executionConfig.set_p_every_step
        fmi2SetReal(c, p_refs, p)
    end

    # get derivative
    if length(dx) > 0
        getDerivatives!(c, dx, dx_refs)
    end

    # get output 
    if length(y) > 0
        getOutputs!(c, y, y_refs)
    end

    # get event indicators
    if length(ec) > 0
        getEventIndicators!(c, ec, ec_idcs)
    end

    if c.fmu.executionConfig.concat_eval
        # ToDo: This allocations could be skipped by in-place modification
        return vcat(y, dx, ec) # [y..., dx..., ec...]
    else
        return y, dx, ec
    end
end

# [ToDo] Implement dx_refs to grab only specific derivatives
function getDerivatives!(c::FMU2Component, dx::AbstractArray{<:fmi2Real}, dx_refs::AbstractArray{<:fmi2ValueReference})
    if c.fmu.isZeroState
        dx[:] = [1.0]
    else
        fmi2GetDerivatives!(c, dx)
    end
    return nothing
end

function getOutputs!(c::FMU2Component, y::AbstractArray{<:fmi2Real}, y_refs::AbstractArray{<:fmi2ValueReference})
    fmi2GetReal!(c, y_refs, y)
    return nothing
end

function getEventIndicators!(c::FMU2Component, ec::AbstractArray{<:fmi2Real}, ec_idcs::AbstractArray{<:fmi2ValueReference})
    if length(ec_idcs) == c.fmu.modelDescription.numberOfEventIndicators || length(ec_idcs) == 0 # pick ALL event indicators
        fmi2GetEventIndicators!(c, ec)
    else # pick only some specific ones
        fmi2GetEventIndicators!(c, c.eventIndicatorBuffer)
        ec[:] = c.eventIndicatorBuffer[ec_idcs]
    end
    return nothing
end
