#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - the `fmi2ComponentState`--enum which mirrors the internal FMU state (state-machine, not the system state)
# - the `FMU2ComponentEnvironment`- and `FMU2Component`-struct 
# - the `FMU2`-struct
# - string/enum-converters for FMI-attribute-structs (e.g. `fmi2StatusToString`, ...)

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
Base.show(io::IO, e::FMU2Event) = print(io, e.indicator == 0 ? "Time-Event @ $(round(e.t; digits=4))s" : "State-Event #$(e.indicator) @ $(round(e.t; digits=4))s")

""" 
ToDo 
"""
mutable struct FMU2Solution{C} <: FMUSolution where {C}
    component::C # FMU2Component
    success::Bool

    states                                          # ToDo: ODESolution 

    values                                          # ToDo: DataType
    valueReferences::Union{Array, Nothing}          # ToDo: Array{fmi2ValueReference}

    events::Array{FMU2Event, 1}

    evals_∂ẋ_∂x::Integer
    evals_∂y_∂x::Integer
    evals_∂ẋ_∂u::Integer
    evals_∂y_∂u::Integer
    evals_∂ẋ_∂t::Integer
    evals_∂y_∂t::Integer
    evals_∂ẋ_∂p::Integer
    evals_∂y_∂p::Integer
    
    function FMU2Solution{C}() where {C}
        inst = new{C}()

        inst.success = false
        inst.states = nothing 
        inst.values = nothing
        inst.valueReferences = nothing

        inst.events = []

        inst.evals_∂ẋ_∂x = 0
        inst.evals_∂y_∂x = 0
        inst.evals_∂ẋ_∂u = 0
        inst.evals_∂y_∂u = 0
        inst.evals_∂ẋ_∂t = 0
        inst.evals_∂y_∂t = 0
        inst.evals_∂ẋ_∂p = 0
        inst.evals_∂y_∂p = 0
        
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

    print(io, "Jacobian-Evaluations:\n")
    print(io, "\t∂ẋ_∂x: $(sol.evals_∂ẋ_∂x)\n")
    print(io, "\t∂ẋ_∂u: $(sol.evals_∂ẋ_∂u)\n")
    print(io, "\t∂y_∂x: $(sol.evals_∂y_∂x)\n")
    print(io, "\t∂y_∂u: $(sol.evals_∂y_∂u)\n")
    print(io, "Gradient-Evaluations:\n")
    print(io, "\t∂ẋ_∂t: $(sol.evals_∂ẋ_∂t)\n")
    print(io, "\t∂y_∂t: $(sol.evals_∂y_∂t)\n")
    
    if sol.states != nothing
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

    if sol.values != nothing
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

    if sol.events != nothing
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
ToDo.
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
mutable struct FMU2Component{F} 
    compAddr::fmi2Component
    fmu::F # type is always FMU2, but this would cause a circular dependency
    state::fmi2ComponentState
    componentEnvironment::FMU2ComponentEnvironment
    problem # ODEProblem, but this is no dependency of FMICore.jl
    type::Union{fmi2Type, Nothing}
    solution::FMU2Solution
    force::Bool
    
    loggingOn::fmi2Boolean
    visible::fmi2Boolean
    callbackFunctions::fmi2CallbackFunctions
    instanceName::String
    continuousStatesChanged::fmi2Boolean
    eventInfo::Union{fmi2EventInfo, Nothing}
    
    t::fmi2Real             # the system time
    t_offset::fmi2Real      # time offset between simulation environment and FMU
    x::Union{Array{fmi2Real, 1}, Nothing}   # the system states (or sometimes u)
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
    A::Union{FMUJacobian, Nothing}
    B::Union{FMUJacobian, Nothing}
    C::Union{FMUJacobian, Nothing}
    D::Union{FMUJacobian, Nothing}
    E::Union{FMUJacobian, Nothing}
    F::Union{FMUJacobian, Nothing}

    # deprecated
    realValues::Dict
    senseFunc::Symbol
    jac_ẋy_x::Union{Matrix{fmi2Real}, Nothing}
    jac_ẋy_u::Union{Matrix{fmi2Real}, Nothing}
    jac_x::Union{Array{fmi2Real}, Nothing}
    jac_u::Union{Array{fmi2Real}, Nothing}
    jac_t::Union{fmi2Real, Nothing}

    jacobianUpdate!         # function for a custom jacobian constructor (optimization)
    skipNextDoStep::Bool    # allows skipping the next `fmi2DoStep` like it is not called

    # constructor
    function FMU2Component{F}() where {F}
        inst = new()
        inst.state = fmi2ComponentStateInstantiated
        inst.t = -Inf
        inst.t_offset = 0.0
        inst.eventInfo = fmi2EventInfo()
        inst.problem = nothing
        inst.type = nothing

        inst.loggingOn = fmi2False
        inst.visible = fmi2False
        inst.instanceName = ""
        inst.continuousStatesChanged = fmi2False
        
        inst.x = nothing
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

        inst.A = nothing
        inst.B = nothing
        inst.C = nothing
        inst.D = nothing

        # initialize further variables 
        inst.skipNextDoStep = false
        inst.jacobianUpdate! = nothing
        
        # deprecated
        inst.senseFunc = :auto
        inst.realValues = Dict()
        inst.jac_x = Array{fmi2Real, 1}()
        inst.jac_u = nothing
        inst.jac_t = -1.0
        inst.jac_ẋy_x = zeros(fmi2Real, 0, 0)
        inst.jac_ẋy_u = zeros(fmi2Real, 0, 0)

        return inst
    end

    function FMU2Component(fmu::F) where {F}
        inst = FMU2Component{F}()
        inst.fmu = fmu
        
        return inst
    end

    function FMU2Component(compAddr::fmi2Component, fmu::F) where {F}
        inst = FMU2Component{F}()
        inst.compAddr = compAddr
        inst.fmu = fmu
        
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
    handleEventIndicators::Union{Array{Integer}, Nothing}   # indices of event indicators to be handled, if `nothing` all are handled

    assertOnError::Bool                     # wheter an exception is thrown if a fmi2XXX-command fails (>= fmi2StatusError)
    assertOnWarning::Bool                   # wheter an exception is thrown if a fmi2XXX-command warns (>= fmi2StatusWarning)

    autoTimeShift::Bool                     # wheter to shift all time-related functions for simulation intervals not starting at 0.0
    concat_y_dx::Bool                       # wheter FMU/Component evaluation should return a tuple (y, dx) or a conacatenation (y..., dx...)

    sensealg                                # algorithm for sensitivity estimation over solve call (ToDo: Datatype)
    useComponentShadow::Bool                # whether FMU outputs/derivatives/jacobians should be cached for frule/rrule (useful for ForwardDiff)
    rootSearchInterpolationPoints::UInt     # number of root search interpolation points
    inPlace::Bool                           # whether faster in-place-fx should be used
    useVectorCallbacks::Bool                # whether to vector (faster) or scalar (slower) callbacks

    maxNewDiscreteStateCalls::UInt          # max calls for fmi2NewDiscreteStates before throwing an exception
    maxStateEventsPerSecond::UInt           # max state events allowed to occur per second (more is interpreted as event jittering)

    eval_t_gradients::Bool                  # if time gradients ∂ẋ_∂t and ∂y_∂t should be sampled (not part of the FMI standard)
    JVPBuiltInDerivatives::Bool             # use built-in directional derivatives for JVP-sensitivities over FMU without caching the jacobian (because this is done in the FMU, but not per default)

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
        inst.handleEventIndicators = nothing

        inst.assertOnError = false
        inst.assertOnWarning = false

        inst.autoTimeShift = false
        inst.concat_y_dx = true

        inst.sensealg = nothing # auto
        
        inst.rootSearchInterpolationPoints = 10
        inst.inPlace = true
        inst.useVectorCallbacks = true

        inst.maxNewDiscreteStateCalls = 100
        inst.maxStateEventsPerSecond = 100

        inst.eval_t_gradients = false
        inst.JVPBuiltInDerivatives = false

        # deprecated 
        inst.useComponentShadow = false

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

    # parameters that are catched by optimizers (like in FMIFlux.jl)
    optim_p_refs::AbstractVector{<:fmi2ValueReference}
    optim_p::AbstractVector{<:Real}

    # c-libraries
    libHandle::Ptr{Nothing}
    callbackLibHandle::Ptr{Nothing} # for external callbacks
    cFunctionPtrs::Dict{String, Ptr{Nothing}}

    # multi-threading
    threadComponents::Dict{Integer, Union{FMU2Component, Nothing}}

    # START: experimental section (to FMIFlux.jl)
    dependencies::Matrix{Union{fmi2DependencyKind, Nothing}}
    # END: experimental section

    # Constructor
    function FMU2(logLevel::FMULogLevel=FMULogLevelWarn) 
        inst = new()
        inst.components = []
        
        inst.callbackLibHandle = C_NULL
        inst.modelName = ""
        inst.logLevel = logLevel

        inst.hasStateEvents = nothing 
        inst.hasTimeEvents = nothing

        inst.optim_p_refs = Vector{fmi2ValueReference}()
        inst.optim_p = Vector{fmi2Real}()

        inst.executionConfig = FMU2_EXECUTION_CONFIGURATION_NO_RESET
        inst.threadComponents = Dict{Integer, Union{FMU2Component, Nothing}}()
        inst.cFunctionPtrs = Dict{String, Ptr{Nothing}}()

        return inst 
    end
end
export FMU2

""" 
Overload the Base.show() function for custom printing of the FMU2.
"""
Base.show(io::IO, fmu::FMU2) = print(io,
"Model name:        $(fmu.modelDescription.modelName)
Type:              $(fmu.type)"
)