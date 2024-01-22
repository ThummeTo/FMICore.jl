#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""

    FMU 

The abstract type for FMUs (FMI 2 & 3).
"""
abstract type FMU end
export FMU

"""

    FMUInstance 

An instance of a FMU. This was called `component` in FMI2, but was corrected to `instance` in FMI3.
"""
abstract type FMUInstance end 
export FMUInstance

"""

    FMUSolution

The abstract type for a solution generated by simulating an FMU (FMI 2 & 3).
"""
abstract type FMUSolution end
export FMUSolution

"""

    FMUExecutionConfiguration

The abstract type for the configuration used to simulate (execute) an FMU (FMI 2 & 3).
"""
abstract type FMUExecutionConfiguration end
export FMUExecutionConfiguration

"""

    FMUEvent

The abstract type for an event triggered by a FMU (FMI 2 & 3).
"""
abstract type FMUEvent end
export FMUEvent

"""
 ToDo 
"""
mutable struct FMUSnapshot{E, C, D, I, S} 

    t::Float64 
    eventInfo::E
    state::UInt32
    instance::I
    fmuState::Union{S, Nothing}
    x_c::C
    x_d::D

    function FMUSnapshot{E, C, D, I, S}() where {E, C, D, I, S}
        inst = new{E, C, D, I, S}()
        inst.fmuState = nothing
        return inst
    end

    function FMUSnapshot(c::FMUInstance)

        t = c.t
        eventInfo = deepcopy(c.eventInfo)
        state = c.state
        instance = c
        fmuState = getFMUstate(c)
        #x_c = isnothing(c.x  ) ? nothing : copy(c.x  ) 
        #x_d = isnothing(c.x_d) ? nothing : copy(c.x_d)

        n_x_c = Csize_t(length(c.fmu.modelDescription.stateValueReferences))
        x_c = zeros(Float64, n_x_c)
        fmi2GetContinuousStates!(c.fmu.cGetContinuousStates, c.compAddr, x_c, n_x_c)
        x_d = nothing # ToDo

        E = typeof(eventInfo)
        C = typeof(x_c)
        D = typeof(x_d)
        I = typeof(instance)
        S = typeof(fmuState)

        inst = new{E, C, D, I, S}(t, eventInfo, state, instance, fmuState, x_c, x_d)

        # if !isnothing(fmuState)
        #     inst = finalizer((_inst) -> cleanup!(c, _inst), inst)
        # end

        push!(c.snapshots, inst)

        return inst
    end

end
export FMUSnapshot

function Base.show(io::IO, s::FMUSnapshot)
    print(io, "FMUSnapshot(t=$(s.t), x_c=$(s.x_c), x_d=$(s.x_d), fmuState=$(s.fmuState))")
end