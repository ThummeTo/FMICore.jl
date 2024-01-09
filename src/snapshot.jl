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
    c.solution.snapshots[c.t] = s
    return s
end
export snapshot!

function hasSnapshot!(c::FMU2Component, t::Float64)
    return haskey(c.solution.snapshots, t)
end

function getSnapshot!(c::FMU2Component, t::Float64)
    # [Note] only take exact fit if we are at 0, otherwise take the next left, 
    #        because we are saving snapshots for the right root of events.

    ts = keys(c.solution.snapshots) 

    tStart = Inf 
    for _t in ts
        if _t < tStart
            tStart = _t 
        end
    end
   
    if hasSnapshot!(c, t) && t == tStart
        return c.solution.snapshots[t]
    else
        left = -Inf
        right = Inf
        
        for _t in ts
            if _t < t && _t > left
                left = _t 
            end
            if _t > t && _t < right
                right = _t 
            end
        end

        @assert left != -Inf "Can't find snapshot for timestamp $(t) s."
        
        #@warn "FMU has no snapshot at timestamp $(t)s.\nClosest are $(left)s (left) and $(right)s right.\nTaking left."
        return c.solution.snapshots[left]
    end
end
export getSnapshot!

function update!(s::FMUSnapshot, c::FMU2Component)
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

function cleanup!(c, s::FMUSnapshot) 
    #@async println("cleanup!")
    freeFMUstate!(c, Ref(s.fmuState))
    s.fmuState = nothing
    return nothing
end
export cleanup!