#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - the `fmi2ComponentState`--enum which mirrors the internal FMU state (state-machine, not the system state)
# - the `FMU2ComponentEnvironment`- and `FMU2Component`-struct 
# - the `FMU2`-struct
# - string/enum-converters for FMI-attribute-structs (e.g. `fmi2StatusToString`, ...)

# default values for function calls
const EMPTY_fmi2Real = zeros(fmi2Real, 0)
const EMPTY_fmi2ValueReference = zeros(fmi2ValueReference, 0)

"""
Container for event related information.
"""
struct FMU2Event <: FMUEvent
    t::Creal                                        # event time point
    indicator::UInt                                 # index of event indicator ("0" for time events)
    
    x_left::Union{Array{Creal, 1}, Nothing}       # state before the event
    x_right::Union{Array{Creal, 1}, Nothing}      # state after the event (if discontinuous)

    indicatorValue::Union{Creal, Nothing}         # value of the event indicator that triggered the event (should be really close to zero)

    function FMU2Event(t::Creal, 
                       indicator::UInt = 0, 
                       x_left::Union{Array{Creal, 1}, Nothing} = nothing, 
                       x_right::Union{Array{Creal, 1}, Nothing} = nothing, 
                       indicatorValue::Union{Creal, Nothing} = nothing)
        inst = new(t, indicator, x_left, x_right, indicatorValue)
        return inst 
    end
end
export FMU2Event

""" 
Overload the Base.show() function for custom printing of the FMU2.
"""
function Base.show(io::IO, e::FMU2Event)
    timeEvent = (e.indicator == 0)
    stateChange = (e.x_left != e.x_right)
    if timeEvent
        print(io, "Time-Event @ $(e.t)s (state-change: $(stateChange))")
    else
        print(io, "State-Event #$(e.indicator) @ $(e.t)s (state-change: $(stateChange))")
    end
end

""" 
The mutable struct representing a specific Solution of a FMI2 FMU.
"""
mutable struct FMU2Solution{C} <: FMUSolution where {C}
    component::C # FMU2Component
    snapshots::Vector{FMUSnapshot}
    success::Bool

    states                                          # ToDo: ODESolution 

    values                                          # ToDo: DataType
    valueReferences::Union{Array, Nothing}          # ToDo: Array{fmi2ValueReference}

    # record events
    events::Array{FMU2Event, 1}

    # record event indicators
    recordEventIndicators::Union{Array{Int, 1}, Nothing}
    eventIndicators                                 # ToDo: DataType

    # record eigenvalues 
    eigenvalues                                     # ToDo: DataType

    evals_∂ẋ_∂x::Integer
    evals_∂y_∂x::Integer
    evals_∂e_∂x::Integer
    evals_∂ẋ_∂u::Integer
    evals_∂y_∂u::Integer
    evals_∂e_∂u::Integer
    evals_∂ẋ_∂t::Integer
    evals_∂y_∂t::Integer
    evals_∂e_∂t::Integer
    evals_∂ẋ_∂p::Integer
    evals_∂y_∂p::Integer
    evals_∂e_∂p::Integer
    evals_∂xr_∂xl::Integer

    evals_fx_inplace::Integer 
    evals_fx_outofplace::Integer 
    evals_condition::Integer
    evals_affect::Integer
    evals_stepcompleted::Integer
    evals_timechoice::Integer
    evals_savevalues::Integer
    evals_saveeventindicators::Integer
    evals_saveeigenvalues::Integer
    
    function FMU2Solution{C}() where {C}
        inst = new{C}()

        inst.snapshots = []
        inst.success = false
        inst.states = nothing 
        inst.values = nothing
        inst.valueReferences = nothing

        inst.events = []

        inst.recordEventIndicators = nothing
        inst.eigenvalues = nothing

        inst.evals_∂ẋ_∂x = 0
        inst.evals_∂y_∂x = 0
        inst.evals_∂e_∂x = 0
        inst.evals_∂ẋ_∂u = 0
        inst.evals_∂y_∂u = 0
        inst.evals_∂e_∂u = 0
        inst.evals_∂ẋ_∂t = 0
        inst.evals_∂y_∂t = 0
        inst.evals_∂e_∂t = 0
        inst.evals_∂ẋ_∂p = 0
        inst.evals_∂y_∂p = 0
        inst.evals_∂e_∂p = 0
        inst.evals_∂xr_∂xl = 0

        inst.evals_fx_inplace = 0
        inst.evals_fx_outofplace = 0
        inst.evals_condition = 0
        inst.evals_affect = 0
        inst.evals_stepcompleted = 0
        inst.evals_timechoice = 0
        inst.evals_savevalues = 0
        inst.evals_saveeventindicators = 0
        inst.evals_saveeigenvalues = 0
        
        return inst
    end
    
    function FMU2Solution(component::C) where {C}
        inst = FMU2Solution{C}()
        inst.component = component
        
        return inst
    end
end
export FMU2Solution

""" 
Overload the Base.show() function for custom printing of the FMU2.
"""
function Base.show(io::IO, sol::FMU2Solution) 
    print(io, "Model name:\n\t$(sol.component.fmu.modelDescription.modelName)\nSuccess:\n\t$(sol.success)\n")

    print(io, "f(x)-Evaluations:\n")
    print(io, "\tIn-place: $(sol.evals_fx_inplace)\n")
    print(io, "\tOut-of-place: $(sol.evals_fx_outofplace)\n")
    print(io, "Jacobian-Evaluations:\n")
    print(io, "\t∂ẋ_∂p: $(sol.evals_∂ẋ_∂p)\n")
    print(io, "\t∂ẋ_∂x: $(sol.evals_∂ẋ_∂x)\n")
    print(io, "\t∂ẋ_∂u: $(sol.evals_∂ẋ_∂u)\n")
    print(io, "\t∂y_∂p: $(sol.evals_∂y_∂p)\n")
    print(io, "\t∂y_∂x: $(sol.evals_∂y_∂x)\n")
    print(io, "\t∂y_∂u: $(sol.evals_∂y_∂u)\n")
    print(io, "\t∂e_∂p: $(sol.evals_∂e_∂p)\n")
    print(io, "\t∂e_∂x: $(sol.evals_∂e_∂x)\n")
    print(io, "\t∂e_∂u: $(sol.evals_∂e_∂u)\n")
    print(io, "\t∂xr_∂xl: $(sol.evals_∂xr_∂xl)\n")
    print(io, "Gradient-Evaluations:\n")
    print(io, "\t∂ẋ_∂t: $(sol.evals_∂ẋ_∂t)\n")
    print(io, "\t∂y_∂t: $(sol.evals_∂y_∂t)\n")
    print(io, "\t∂e_∂t: $(sol.evals_∂e_∂t)\n")
    print(io, "Callback-Evaluations:\n")
    print(io, "\tCondition (event-indicators): $(sol.evals_condition)\n")
    print(io, "\tTime-Choice (event-instances): $(sol.evals_timechoice)\n")
    print(io, "\tAffect (event-handling): $(sol.evals_affect)\n")
    print(io, "\tSave values: $(sol.evals_savevalues)\n")
    print(io, "\tSteps completed: $(sol.evals_stepcompleted)\n")
    
    if !isnothing(sol.states)
        print(io, "States [$(length(sol.states))]:\n")
        if length(sol.states.u) > 10
            for i in 1:9
                print(io, "\t$(sol.states.t[i])\t$(sol.states.u[i])\n")
            end
            print(io, "\t...\n\t$(sol.states.t[end])\t$(sol.states.u[end])\n")
        else
            for i in 1:length(sol.states)
                print(io, "\t$(sol.states.t[i])\t$(sol.states.u[i])\n")
            end
        end
    end

    if !isnothing(sol.values)
        print(io, "Values [$(length(sol.values.saveval))]:\n")
        if length(sol.values.saveval) > 10
            for i in 1:9
                print(io, "\t$(sol.values.t[i])\t$(sol.values.saveval[i])\n")
            end
            print(io, "\t...\n\t$(sol.values.t[end])\t$(sol.values.saveval[end])\n")
        else
            for i in 1:length(sol.values.saveval)
                print(io, "\t$(sol.values.t[i])\t$(sol.values.saveval[i])\n")
            end
        end
    end

    if !isnothing(sol.events)
        print(io, "Events [$(length(sol.events))]:\n")
        if length(sol.events) > 10
            for i in 1:9
                print(io, "\t$(sol.events[i])\n")
            end
            print(io, "\t...\n\t$(sol.events[end])\n")
        else
            for i in 1:length(sol.events)
                print(io, "\t$(sol.events[i])\n")
            end
        end
    end

end

"""
Source: FMISpec 2.0.3 [p.16f]

This is a pointer to a data structure in the simulation environment that calls the FMU. Using this
pointer, data from the modelDescription.xml file [(for example, mapping of valueReferences to
variable names)] can be transferred between the simulation environment and the logger function
(see [FMISpec 2.0.3] section 2.1.5).
"""
mutable struct FMU2ComponentEnvironment
    logStatusOK::Bool
    logStatusWarning::Bool
    logStatusDiscard::Bool
    logStatusError::Bool
    logStatusFatal::Bool
    logStatusPending::Bool

    function FMU2ComponentEnvironment()
        inst = new()
        inst.logStatusOK = true
        inst.logStatusWarning = true
        inst.logStatusDiscard = true
        inst.logStatusError = true
        inst.logStatusFatal = true
        inst.logStatusPending = true
        return inst
    end
end
export FMU2ComponentEnvironment

"""
The mutable struct represents an allocated instance of an FMU in the FMI 2.0.2 Standard.
"""
mutable struct FMU2Component{F} <: FMUInstance
    compAddr::fmi2Component
    cRef::UInt64
    fmu::F 
    state::fmi2ComponentState
    componentEnvironment::FMU2ComponentEnvironment
    problem # ToDo: ODEProblem, but this is not a dependency of FMICore.jl nor FMIImport.jl ...
    type::Union{fmi2Type, Nothing}
    solution::FMU2Solution
    force::Bool
    threadid::Integer
    
    loggingOn::fmi2Boolean
    visible::fmi2Boolean
    callbackFunctions::fmi2CallbackFunctions
    instanceName::String
    continuousStatesChanged::fmi2Boolean
    eventInfo::Union{fmi2EventInfo, Nothing}
    
    t::fmi2Real             # the system time
    t_offset::fmi2Real      # time offset between simulation environment and FMU
    x::Union{Array{fmi2Real, 1}, Nothing}   # the system states (or sometimes u)
    x_d::Union{Array{Union{fmi2Real, fmi2Integer, fmi2Boolean}, 1}, Nothing}   # the system discrete states
    ẋ::Union{Array{fmi2Real, 1}, Nothing}   # the system state derivative (or sometimes u̇)
    ẍ::Union{Array{fmi2Real, 1}, Nothing}   # the system state second derivative
    #u::Union{Array{fmi2Real, 1}, Nothing}  # the system inputs
    #y::Union{Array{fmi2Real, 1}, Nothing}  # the system outputs
    #p::Union{Array{fmi2Real, 1}, Nothing}  # the system parameters
    z::Union{Array{fmi2Real, 1}, Nothing}   # the system event indicators
    z_prev::Union{Array{fmi2Real, 1}, Nothing}   # the last system event indicators

    values::Dict{fmi2ValueReference, Union{fmi2Real, fmi2Integer, fmi2Boolean}}    

    x_vrs::Array{fmi2ValueReference, 1}   # the system state value references 
    ẋ_vrs::Array{fmi2ValueReference, 1}   # the system state derivative value references
    u_vrs::Array{fmi2ValueReference, 1}   # the system input value references
    y_vrs::Array{fmi2ValueReference, 1}   # the system output value references
    p_vrs::Array{fmi2ValueReference, 1}   # the system parameter value references

    # sensitivities
    ∂ẋ_∂x #::Union{J, Nothing}
    ∂ẋ_∂u #::Union{J, Nothing}
    ∂ẋ_∂p #::Union{J, Nothing}
    ∂ẋ_∂t #::Union{G, Nothing}

    ∂y_∂x #::Union{J, Nothing}
    ∂y_∂u #::Union{J, Nothing}
    ∂y_∂p #::Union{J, Nothing}
    ∂y_∂t #::Union{G, Nothing}

    ∂e_∂x #::Union{J, Nothing}
    ∂e_∂u #::Union{J, Nothing}
    ∂e_∂p #::Union{J, Nothing}
    ∂e_∂t #::Union{G, Nothing}

    ∂xr_∂xl #::Union{J, Nothing}

    # performance (pointers to prevent repeating allocations)
    _enterEventMode::Array{fmi2Boolean, 1}
    _ptr_enterEventMode::Ptr{fmi2Boolean}
    _terminateSimulation::Array{fmi2Boolean, 1}
    _ptr_terminateSimulation::Ptr{fmi2Boolean}

    # misc
    skipNextDoStep::Bool    # allows skipping the next `fmi2DoStep` like it is not called
    progressMeter           # progress plot
    output::FMU2ADOutput 
    rrule_input::FMU2EvaluationInput     # input buffer (for rrules)
    eval_output::FMU2EvaluationOutput   # output buffer with multiple arrays that behaves like a single array (to allow for single value return functions, necessary for propper AD)
    frule_output::FMU2EvaluationOutput

    eventIndicatorBuffer::AbstractArray{<:fmi2Real}

    # parameters that need sensitivities and/or are catched by optimizers (like in FMIFlux.jl)
    default_t::Real
    default_p_refs::AbstractVector{<:fmi2ValueReference}
    default_p::AbstractVector{<:Real}
    default_ec_idcs::AbstractVector{<:fmi2ValueReference}
    default_dx_refs::AbstractVector{<:fmi2ValueReference}
    default_u::AbstractVector{<:Real}
    default_y_refs::AbstractVector{<:fmi2ValueReference}

    # deprecated 
    default_y::AbstractVector{<:Real}
    default_ec::AbstractVector{<:Real}
    default_dx::AbstractVector{<:Real}

    # a container for all created snapshots, so that we can properly release them at unload
    snapshots::Vector{FMUSnapshot}

    # constructor
    function FMU2Component{F}() where {F}
        inst = new{F}()
        inst.cRef = UInt64(pointer_from_objref(inst))
        inst.state = fmi2ComponentStateInstantiated
        inst.t = -Inf
        inst.t_offset = 0.0
        inst.eventInfo = fmi2EventInfo()
        inst.problem = nothing
        inst.type = nothing
        inst.threadid = Threads.threadid()

        inst.output = FMU2ADOutput{Real}(; initType=Float64)
        inst.eval_output = FMU2EvaluationOutput{Float64}()
        inst.rrule_input = FMU2EvaluationInput()
        inst.frule_output = FMU2EvaluationOutput{Float64}()

        inst.loggingOn = fmi2False
        inst.visible = fmi2False
        inst.instanceName = ""
        inst.continuousStatesChanged = fmi2False
        
        inst.x = nothing
        inst.x_d = nothing
        inst.ẋ = nothing
        inst.ẍ = nothing
        inst.z = nothing
        inst.z_prev = nothing
        
        inst.values = Dict{fmi2ValueReference, Union{fmi2Real, fmi2Integer, fmi2Boolean}}()
        inst.x_vrs = Array{fmi2ValueReference, 1}()
        inst.ẋ_vrs = Array{fmi2ValueReference, 1}() 
        inst.u_vrs = Array{fmi2ValueReference, 1}()  
        inst.y_vrs = Array{fmi2ValueReference, 1}()  
        inst.p_vrs = Array{fmi2ValueReference, 1}() 

        inst.∂ẋ_∂x = nothing
        inst.∂ẋ_∂u = nothing
        inst.∂ẋ_∂p = nothing
        inst.∂ẋ_∂t = nothing

        inst.∂y_∂x = nothing
        inst.∂y_∂u = nothing
        inst.∂y_∂p = nothing
        inst.∂y_∂t = nothing

        inst.∂e_∂x = nothing
        inst.∂e_∂u = nothing
        inst.∂e_∂p = nothing
        inst.∂e_∂t = nothing

        inst.∂xr_∂xl = nothing

        # initialize further variables 
        inst.skipNextDoStep = false
        inst.progressMeter = nothing
        
        # performance (pointers to prevent repeating allocations)
        inst._enterEventMode = zeros(fmi2Boolean, 1)
        inst._terminateSimulation = zeros(fmi2Boolean, 1)
        inst._ptr_enterEventMode = pointer(inst._enterEventMode)
        inst._ptr_terminateSimulation = pointer(inst._terminateSimulation)

        inst.default_t = -1.0
        inst.default_p_refs = EMPTY_fmi2ValueReference
        inst.default_p = EMPTY_fmi2Real
        inst.default_ec_idcs = EMPTY_fmi2ValueReference
        inst.default_u = EMPTY_fmi2Real
        inst.default_y_refs = EMPTY_fmi2ValueReference
        inst.default_dx_refs = EMPTY_fmi2ValueReference

        inst.snapshots = []

        # deprecated
        inst.default_ec = EMPTY_fmi2Real
        inst.default_y = EMPTY_fmi2Real
        inst.default_dx = EMPTY_fmi2Real

        return inst
    end

    function FMU2Component(fmu::F) where {F}
        inst = FMU2Component{F}()
        inst.fmu = fmu
        inst.eventIndicatorBuffer = zeros(fmi2Real, fmu.modelDescription.numberOfEventIndicators)

        inst.default_t          = inst.fmu.default_t
        inst.default_p_refs     = inst.fmu.default_p_refs   === EMPTY_fmi2ValueReference    ? inst.fmu.default_p_refs   : copy(inst.fmu.default_p_refs)
        inst.default_p          = inst.fmu.default_p        === EMPTY_fmi2Real              ? inst.fmu.default_p        : copy(inst.fmu.default_p)
        inst.default_ec         = inst.fmu.default_ec       === EMPTY_fmi2Real              ? inst.fmu.default_ec       : copy(inst.fmu.default_ec)
        inst.default_ec_idcs    = inst.fmu.default_ec_idcs  === EMPTY_fmi2ValueReference    ? inst.fmu.default_ec_idcs  : copy(inst.fmu.default_ec_idcs)
        inst.default_u          = inst.fmu.default_u        === EMPTY_fmi2Real              ? inst.fmu.default_u        : copy(inst.fmu.default_u)
        inst.default_y          = inst.fmu.default_y        === EMPTY_fmi2Real              ? inst.fmu.default_y        : copy(inst.fmu.default_y)
        inst.default_y_refs     = inst.fmu.default_y_refs   === EMPTY_fmi2ValueReference    ? inst.fmu.default_y_refs   : copy(inst.fmu.default_y_refs)
        inst.default_dx         = inst.fmu.default_dx       === EMPTY_fmi2Real              ? inst.fmu.default_dx       : copy(inst.fmu.default_dx)
        inst.default_dx_refs    = inst.fmu.default_dx_refs  === EMPTY_fmi2ValueReference    ? inst.fmu.default_dx_refs  : copy(inst.fmu.default_dx_refs)

        return inst
    end

    function FMU2Component(compAddr::fmi2Component, fmu::F) where {F}
        inst = FMU2Component(fmu)
        inst.compAddr = compAddr
       
        return inst
    end
end
export FMU2Component

""" 
Overload the Base.show() function for custom printing of the FMU2Component.
"""
Base.show(io::IO, c::FMU2Component) = print(io,
"FMU:            $(c.fmu.modelDescription.modelName)
InstanceName:   $(isdefined(c, :instanceName) ? c.instanceName : "[not defined]")
Address:        $(c.compAddr)
State:          $(c.state)
Logging:        $(c.loggingOn)
FMU time:       $(c.t)
FMU states:     $(c.x)"
)

"""
A mutable struct representing the excution configuration of a FMU.
For FMUs that have issues with calls like `fmi2Reset` or `fmi2FreeInstance`, this is pretty useful.
"""
mutable struct FMU2ExecutionConfiguration <: FMUExecutionConfiguration
    terminate::Bool     # call fmi2Terminate before every training step / simulation
    reset::Bool         # call fmi2Reset before every training step / simulation
    setup::Bool         # call setup functions before every training step / simulation
    instantiate::Bool   # call fmi2Instantiate before every training step / simulation
    freeInstance::Bool  # call fmi2FreeInstance after every training step / simulation

    loggingOn::Bool 
    externalCallbacks::Bool
    
    force::Bool     # default value for forced actions
    
    handleStateEvents::Bool                 # handle state events during simulation/training
    handleTimeEvents::Bool                  # handle time events during simulation/training

    assertOnError::Bool                     # wheter an exception is thrown if a fmi2XXX-command fails (>= fmi2StatusError)
    assertOnWarning::Bool                   # wheter an exception is thrown if a fmi2XXX-command warns (>= fmi2StatusWarning)

    autoTimeShift::Bool                     # wheter to shift all time-related functions for simulation intervals not starting at 0.0
    inplace_eval::Bool                      # wheter FMU/Component evaluation should happen in place

    sensealg                                # algorithm for sensitivity estimation over solve call ([ToDo] Datatype/Nothing)
    rootSearchInterpolationPoints::UInt     # number of root search interpolation points
    useVectorCallbacks::Bool                # whether to vector (faster) or scalar (slower) callbacks

    maxNewDiscreteStateCalls::UInt          # max calls for fmi2NewDiscreteStates before throwing an exception
    maxStateEventsPerSecond::UInt           # max state events allowed to occur per second (more is interpreted as event chattering)

    eval_t_gradients::Bool                  # if time gradients ∂ẋ_∂t and ∂y_∂t should be sampled (not part of the FMI standard)
    JVPBuiltInDerivatives::Bool             # use built-in directional derivatives for JVP-sensitivities over FMU without caching the jacobian (because this is done in the FMU, but not per default)

    sensitivity_strategy::Symbol            # build up strategy for jacobians/gradients, available is `:FMIDirectionalDerivative`, `:FiniteDiff`

    set_p_every_step::Bool                  # whether parameters are set for every simulation step - this is uncommon, because parameters are (often) set just one time: during/after intialization

    # deprecated 
    concat_eval::Bool                       # wheter FMU/Component evaluation should return a tuple (y, dx, ec) or a conacatenation [y..., dx..., ec...]
    isolatedStateDependency
    
    function FMU2ExecutionConfiguration()
        inst = new()

        inst.terminate = true 
        inst.reset = true
        inst.setup = true
        inst.instantiate = false 
        inst.freeInstance = false

        inst.force = false

        inst.loggingOn = false
        inst.externalCallbacks = true
        
        inst.handleStateEvents = true
        inst.handleTimeEvents = true
        
        inst.assertOnError = false
        inst.assertOnWarning = false

        inst.autoTimeShift = false
        
        inst.sensealg = nothing # auto
        
        inst.rootSearchInterpolationPoints = 10
        inst.useVectorCallbacks = true

        inst.maxNewDiscreteStateCalls = 100
        inst.maxStateEventsPerSecond = 100

        inst.eval_t_gradients = false
        inst.JVPBuiltInDerivatives = false
        inst.sensitivity_strategy = :FMIDirectionalDerivative

        inst.set_p_every_step = false

        # deprecated 
        inst.concat_eval = true 
        inst.isolatedStateDependency = false

        return inst 
    end
end
export FMU2ExecutionConfiguration

# default for a "healthy" FMU - this is the fastetst 
FMU2_EXECUTION_CONFIGURATION_RESET = FMU2ExecutionConfiguration()
FMU2_EXECUTION_CONFIGURATION_RESET.terminate = true
FMU2_EXECUTION_CONFIGURATION_RESET.reset = true
FMU2_EXECUTION_CONFIGURATION_RESET.setup = true
FMU2_EXECUTION_CONFIGURATION_RESET.instantiate = false
FMU2_EXECUTION_CONFIGURATION_RESET.freeInstance = false
export FMU2_EXECUTION_CONFIGURATION_RESET

# if your FMU has a problem with "fmi2Reset" - this is default
FMU2_EXECUTION_CONFIGURATION_NO_RESET = FMU2ExecutionConfiguration() 
FMU2_EXECUTION_CONFIGURATION_NO_RESET.terminate = false
FMU2_EXECUTION_CONFIGURATION_NO_RESET.reset = false
FMU2_EXECUTION_CONFIGURATION_NO_RESET.setup = true
FMU2_EXECUTION_CONFIGURATION_NO_RESET.instantiate = true
FMU2_EXECUTION_CONFIGURATION_NO_RESET.freeInstance = true
export FMU2_EXECUTION_CONFIGURATION_NO_RESET

# if your FMU has a problem with "fmi2Reset" and "fmi2FreeInstance" - this is for weak FMUs (but slower)
FMU2_EXECUTION_CONFIGURATION_NO_FREEING = FMU2ExecutionConfiguration() 
FMU2_EXECUTION_CONFIGURATION_NO_FREEING.terminate = false
FMU2_EXECUTION_CONFIGURATION_NO_FREEING.reset = false
FMU2_EXECUTION_CONFIGURATION_NO_FREEING.setup = true
FMU2_EXECUTION_CONFIGURATION_NO_FREEING.instantiate = true
FMU2_EXECUTION_CONFIGURATION_NO_FREEING.freeInstance = false
export FMU2_EXECUTION_CONFIGURATION_NO_FREEING

# do nothing, this is useful e.g. for set/get state applications
FMU2_EXECUTION_CONFIGURATION_NOTHING = FMU2ExecutionConfiguration() 
FMU2_EXECUTION_CONFIGURATION_NOTHING.terminate = false
FMU2_EXECUTION_CONFIGURATION_NOTHING.reset = false
FMU2_EXECUTION_CONFIGURATION_NOTHING.setup = false
FMU2_EXECUTION_CONFIGURATION_NOTHING.instantiate = false
FMU2_EXECUTION_CONFIGURATION_NOTHING.freeInstance = false
export FMU2_EXECUTION_CONFIGURATION_NOTHING

FMU2_EXECUTION_CONFIGURATIONS = (FMU2_EXECUTION_CONFIGURATION_NO_FREEING, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NOTHING)
export FMU2_EXECUTION_CONFIGURATIONS

"""
The mutable struct representing a FMU (and a container for all its instances) in the FMI 2.0.2 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 2.0.2 function pointers.
"""
mutable struct FMU2 <: FMU
    modelName::String
    fmuResourceLocation::String
    logLevel::FMULogLevel

    modelDescription::fmi2ModelDescription
   
    type::fmi2Type
    components::Array{FMU2Component, 1} 
    
    # c-functions
    cInstantiate::Ptr{Cvoid}
    cGetTypesPlatform::Ptr{Cvoid}
    cGetVersion::Ptr{Cvoid}
    cFreeInstance::Ptr{Cvoid}
    cSetDebugLogging::Ptr{Cvoid}
    cSetupExperiment::Ptr{Cvoid}
    cEnterInitializationMode::Ptr{Cvoid}
    cExitInitializationMode::Ptr{Cvoid}
    cTerminate::Ptr{Cvoid}
    cReset::Ptr{Cvoid}
    cGetReal::Ptr{Cvoid}
    cSetReal::Ptr{Cvoid}
    cGetInteger::Ptr{Cvoid}
    cSetInteger::Ptr{Cvoid}
    cGetBoolean::Ptr{Cvoid}
    cSetBoolean::Ptr{Cvoid}
    cGetString::Ptr{Cvoid}
    cSetString::Ptr{Cvoid}
    cGetFMUstate::Ptr{Cvoid}
    cSetFMUstate::Ptr{Cvoid}
    cFreeFMUstate::Ptr{Cvoid}
    cSerializedFMUstateSize::Ptr{Cvoid}
    cSerializeFMUstate::Ptr{Cvoid}
    cDeSerializeFMUstate::Ptr{Cvoid}
    cGetDirectionalDerivative::Ptr{Cvoid}

    # Co Simulation function calls
    cSetRealInputDerivatives::Ptr{Cvoid}
    cGetRealOutputDerivatives::Ptr{Cvoid}
    cDoStep::Ptr{Cvoid}
    cCancelStep::Ptr{Cvoid}
    cGetStatus::Ptr{Cvoid}
    cGetRealStatus::Ptr{Cvoid}
    cGetIntegerStatus::Ptr{Cvoid}
    cGetBooleanStatus::Ptr{Cvoid}
    cGetStringStatus::Ptr{Cvoid}

    # Model Exchange function calls
    cEnterContinuousTimeMode::Ptr{Cvoid}
    cGetContinuousStates::Ptr{Cvoid}
    cGetDerivatives::Ptr{Cvoid}
    cSetTime::Ptr{Cvoid}
    cSetContinuousStates::Ptr{Cvoid}
    cCompletedIntegratorStep::Ptr{Cvoid}
    cEnterEventMode::Ptr{Cvoid}
    cNewDiscreteStates::Ptr{Cvoid}
    cGetEventIndicators::Ptr{Cvoid}
    cGetNominalsOfContinuousStates::Ptr{Cvoid}

    # paths of zipped and unzipped FMU folders
    path::String
    binaryPath::String
    zipPath::String

    # execution configuration
    executionConfig::FMU2ExecutionConfiguration

    # events
    hasStateEvents::Union{Bool, Nothing}
    hasTimeEvents::Union{Bool, Nothing} 
    isZeroState::Bool

    # c-libraries
    libHandle::Ptr{Nothing}
    callbackLibHandle::Ptr{Nothing} # for external callbacks
    cFunctionPtrs::Dict{String, Ptr{Nothing}}

    # multi-threading
    threadComponents::Dict{Integer, Union{FMU2Component, Nothing}}

    # indices of event indicators to be handled, if `nothing` all are handled
    handleEventIndicators::Union{Vector{fmi2ValueReference}, Nothing}   

    # START: experimental section (to FMIFlux.jl) - probably deprecated soon
    dependencies::Matrix{Union{fmi2DependencyKind, Nothing}}
    # END: experimental section

    # parameters that need sensitivities and/or are catched by optimizers (like in FMIFlux.jl)
    default_t::Real
    default_p_refs::AbstractVector{<:fmi2ValueReference}
    default_p::AbstractVector{<:Real}
    default_ec::AbstractVector{<:Real}
    default_ec_idcs::AbstractVector{<:fmi2ValueReference}
    default_dx::AbstractVector{<:Real}
    default_dx_refs::AbstractVector{<:fmi2ValueReference}
    default_u::AbstractVector{<:Real}
    default_y::AbstractVector{<:Real}
    default_y_refs::AbstractVector{<:fmi2ValueReference}

    # Constructor
    function FMU2(logLevel::FMULogLevel=FMULogLevelWarn) 
        inst = new()
        inst.components = []
        
        inst.callbackLibHandle = C_NULL
        inst.modelName = ""
        inst.logLevel = logLevel

        inst.hasStateEvents = nothing 
        inst.hasTimeEvents = nothing

        inst.executionConfig = FMU2_EXECUTION_CONFIGURATION_NO_RESET
        inst.threadComponents = Dict{Integer, Union{FMU2Component, Nothing}}()
        inst.cFunctionPtrs = Dict{String, Ptr{Nothing}}()

        inst.handleEventIndicators = nothing

        # parameters that need sensitivities and/or are catched by optimizers (like in FMIFlux.jl)
        inst.default_t = -1.0
        inst.default_p_refs = EMPTY_fmi2ValueReference
        inst.default_p = EMPTY_fmi2Real
        inst.default_ec = EMPTY_fmi2Real
        inst.default_ec_idcs = EMPTY_fmi2ValueReference
        inst.default_u = EMPTY_fmi2Real
        inst.default_y = EMPTY_fmi2Real
        inst.default_y_refs = EMPTY_fmi2ValueReference
        inst.default_dx = EMPTY_fmi2Real
        inst.default_dx_refs = EMPTY_fmi2ValueReference

        return inst 
    end
end
export FMU2

""" 
Overload the Base.show() function for custom printing of the FMU2.
"""
function Base.show(io::IO, fmu::FMU2) 
    print(io, "Model name:\t$(fmu.modelDescription.modelName)\nType:\t\t$(fmu.type)")
end

"""
    ToDo: Doc String 
"""
function hasCurrentComponent(fmu::FMU2)
    tid = Threads.threadid()
    return haskey(fmu.threadComponents, tid) && fmu.threadComponents[tid] != nothing
end
export hasCurrentComponent

"""
    ToDo: Doc String 
"""
function getCurrentComponent(fmu::FMU2)
    tid = Threads.threadid()
    @assert hasCurrentComponent(fmu) ["No FMU instance allocated (in current thread with ID `$(tid)`), have you already called `fmi2Instantiate!`?"]
    return fmu.threadComponents[tid]
end
export getCurrentComponent

"""
    ToDo: Doc String 
"""
struct FMU2InputFunction{F, T}
    fct!::F 
    vrs::Vector{fmi2ValueReference}
    buffer::Vector{<:T}

    function FMU2InputFunction{T}(fct, vrs::Array{fmi2ValueReference}) where {T}
        buffer = zeros(T, length(vrs))

        _fct = nothing 

        if hasmethod(fct, Tuple{T, AbstractArray{<:T,1}})
            _fct = (c, x, t, u) -> fct(t, u)
        elseif hasmethod(fct, Tuple{Union{FMU2Component, Nothing}, T, AbstractArray{<:T,1}})
            _fct = (c, x, t, u) -> fct(c, t, u)
        elseif hasmethod(fct, Tuple{Union{FMU2Component, Nothing}, AbstractArray{<:T,1}, AbstractArray{<:T,1}})
            _fct = (c, x, t, u) -> fct(c, x, u)
        elseif hasmethod(fct, Tuple{AbstractArray{<:T,1}, T, AbstractArray{<:T,1}})
            _fct = (c, x, t, u) -> fct(x, t, u)
        else 
            _fct = fct
        end
        @assert hasmethod(_fct, Tuple{FMU2Component, Union{AbstractArray{<:T,1}, Nothing}, T, AbstractArray{<:T,1}}) "The given input function does not fit the needed input function pattern for FMUs, which are: \n- `inputFunction!(t::T, u::AbstractArray{<:T})`\n- `inputFunction!(comp::FMU2Component, t::T, u::AbstractArray{<:T})`\n- `inputFunction!(comp::FMU2Component, x::Union{AbstractArray{<:T,1}, Nothing}, u::AbstractArray{<:T})`\n- `inputFunction!(x::Union{AbstractArray{<:T,1}, Nothing}, t::T, u::AbstractArray{<:T})`\n- `inputFunction!(comp::FMU2Component, x::Union{AbstractArray{<:T,1}, Nothing}, t::T, u::AbstractArray{<:T})`\nwhere T=$(T)"

        return new{typeof(_fct), T}(_fct, vrs, buffer)
    end

    function FMU2InputFunction(fct, vrs::Array{fmi2ValueReference}) 
        return FMU2InputFunction{fmi2Real}(fct, vrs) 
    end
end
export FMU2InputFunction

"""
    ToDo: Doc String 
"""
function eval!(ipf::FMU2InputFunction, c, x, t)
    ipf.fct!(c, x, t, ipf.buffer)
    return ipf.buffer
end
export eval!
