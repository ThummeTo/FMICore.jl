#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# struct definition is in `src/types.jl`

function getFMUstate(c::FMU2Component)
    state = fmi2FMUstate()
    ref = Ref(state)
    getFMUstate!(c, ref)
    #@info "snap state: $(state)"
    return ref[]
end

function getFMUstate!(c::FMU2Component, state::Ref{fmi2FMUstate})
    if c.fmu.modelDescription.modelExchange.canGetAndSetFMUstate || c.fmu.modelDescription.coSimulation.canGetAndSetFMUstate
        return fmi2GetFMUstate!(c.fmu.cGetFMUstate, c.compAddr, state)
    end
    return nothing
end
function getFMUstate!(c::FMU2Component, s::Ref{Nothing})
    return nothing
end

function setFMUstate!(c::FMU2Component, state::fmi2FMUstate)
    if c.fmu.modelDescription.modelExchange.canGetAndSetFMUstate || c.fmu.modelDescription.coSimulation.canGetAndSetFMUstate
        return fmi2SetFMUstate(c.fmu.cSetFMUstate, c.compAddr, state)
    end
    return nothing
end
function setFMUstate!(c::FMU2Component, state::Nothing)
    return nothing 
end

function freeFMUstate!(c::FMU2Component, state::Ref{fmi2FMUstate})
    fmi2FreeFMUstate!(c.fmu.cFreeFMUstate, c.compAddr, state)
    return nothing 
end
function freeFMUstate!(c::FMU2Component, state::Ref{Nothing})
    return nothing 
end

function snapshot!(c::FMU2Component)
    s = FMUSnapshot(c)
    return s
end
function snapshot!(sol::FMU2Solution)
    s = snapshot!(sol.component)
    push!(sol.snapshots, s)
    return s
end
export snapshot!

function snapshot_if_needed!(obj::Union{FMU2Component, FMU2Solution}, t::Real; atol=1e-8)
    if !hasSnapshot(obj, t; atol=atol)
        snapshot!(obj)
    end
end
export snapshot_if_needed!

function hasSnapshot(c::Union{FMU2Component, FMU2Solution}, t::Float64; atol=0.0)
    for snapshot in c.snapshots
        if abs(snapshot.t-t) <= atol 
            return true 
        end
    end
    return false
end

function getSnapshot(c::FMU2Component, t::Float64; kwargs...)
    return getSnapshot(c.fmu, t; kwargs...)
end

function getSnapshot(c::Union{FMU2, FMU2Solution}, t::Float64; exact::Bool=false, atol=0.0) 
    # [Note] only take exact fit if we are at 0, otherwise take the next left, 
    #        because we are saving snapshots for the right root of events.

    @assert t ∉ (-Inf, Inf) "t = $(t), this is not allowed for snapshot search!"
    @assert length(c.snapshots) > 0 "No snapshots available!"

    left = c.snapshots[1]
    # right = c.snapshots[1]
    
    if exact  
        for snapshot in c.snapshots
            if abs(snapshot.t - t) <= atol
                return snapshot
            end
        end
        return nothing
    else
        for snapshot in c.snapshots
            if snapshot.t < (t-atol) && snapshot.t > (left.t+atol)
                left = snapshot
            end
            # if snapshot.t > t && snapshot.t < right.t
            #     right = snapshot
            # end
        end
    end

    return left
end
export getSnapshot

function update!(c::FMU2Component, s::FMUSnapshot)
    s.t = c.t
    s.eventInfo = deepcopy(c.eventInfo)
    s.state = c.state
    getFMUstate!(s, Ref(s.fmuState))
    # [ToDo] Do a real pull.
    s.x_c = copy(c.x) 
    s.x_d = copy(c.x_d)
    return nothing
end
export update!

function apply!(c::FMU2Component, s::FMUSnapshot; 
                t=s.t, x_c=s.x_c, x_d=s.x_d, fmuState=s.fmuState)

    # FMU state
    setFMUstate!(c, fmuState)
    c.eventInfo = deepcopy(s.eventInfo)
    c.state = s.state

    @debug "Applied snapshot $(s.t)"
    
    # continuous state
    if !isnothing(x_c)
        fmi2SetContinuousStates(c.fmu.cSetContinuousStates, c.compAddr, x_c, Csize_t(length(x_c)))
        c.x = copy(x_c)
    end

    # discrete state
    if !isnothing(x_d)
        # [ToDo] This works only for real values!
        fmi2SetReal(c.fmu.cSetReal, c.compAddr, c.fmu.modelDescription.discreteStateValueReferences, x_d, Csize_t(length(x_d)))
        c.x_d = copy(x_d)
    end

    # time
    fmi2SetTime(c.fmu.cSetTime, c.compAddr, t)
    c.t = t
    
    return nothing
end
export apply!

function freeSnapshot!(s::FMUSnapshot) 
    #@async println("cleanup!")
    freeFMUstate!(s.instance, Ref(s.fmuState))
    s.fmuState = nothing

    ind = findall(x -> x == s, s.instance.snapshots)
    @assert length(ind) == 1 "freeSnapshot!: Freeing $(length(ind)) snapshots with one call, this is not allowed. Target was found $(length(ind)) times at indicies $(ind)."
    deleteat!(s.instance.snapshots, ind)

    return nothing
end
export freeSnapshot!