#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - the `fmi3InstanceState`-enum which mirrors the internal FMU state (state-machine, not the system state)
# - the `FMU3Instance`-struct 
# - the `FMU3`-struct
# - string/enum-converters for FMI-attribute-structs (e.g. `fmi3StatusToString`, ...)

"""
ToDo.
"""
mutable struct FMU3InstanceEnvironment
    logStatusOK::Bool
    logStatusWarning::Bool
    logStatusDiscard::Bool
    logStatusError::Bool
    logStatusFatal::Bool

    function FMU3InstanceEnvironment()
        inst = new()
        inst.logStatusOK = true
        inst.logStatusWarning = true
        inst.logStatusDiscard = true
        inst.logStatusError = true
        inst.logStatusFatal = true
        return inst
    end
end
export FMU3InstanceEnvironment

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.2.1. Header Files and Naming of Functions

The mutable struct represents a pointer to an FMU specific data structure that contains the information needed to process the model equations or to process the co-simulation of the model/subsystem represented by the FMU.
"""
mutable struct FMU3Instance{F} # type is always FMU3, but this would cause a circular dependency
    compAddr::fmi3Instance
    fmu::F
    state::fmi3InstanceState
    instanceEnvironment::FMU3InstanceEnvironment
    problem
    type::Union{fmi3Type, Nothing}

    loggingOn::Bool
    instanceName::String
    continuousStatesChanged::fmi3Boolean

    t::fmi3Float64             # the system time
    t_offset::fmi3Float64      # time offset between simulation environment and FMU
    x::Union{Array{fmi3Float64, 1}, Nothing}   # the system states (or sometimes u)
    ẋ::Union{Array{fmi3Float64, 1}, Nothing}   # the system state derivative (or sometimes u̇)
    ẍ::Union{Array{fmi3Float64, 1}, Nothing}   # the system state second derivative
    #u::Array{fmi3Float64, 1}   # the system inputs
    #y::Array{fmi3Float64, 1}   # the system outputs
    #p::Array{fmi3Float64, 1}   # the system parameters
    z::Array{fmi3Float64, 1}   # the system event indicators
    z_prev::Union{Nothing, Array{fmi3Float64, 1}}   # the last system event indicators

    realValues::Dict    

    x_vrs::Array{fmi3ValueReference, 1}   # the system state value references 
    ẋ_vrs::Array{fmi3ValueReference, 1}   # the system state derivative value references
    u_vrs::Array{fmi3ValueReference, 1}   # the system input value references
    y_vrs::Array{fmi3ValueReference, 1}   # the system output value references
    p_vrs::Array{fmi3ValueReference, 1}   # the system parameter value references

    # deprecated
    jac_ẋy_x::Matrix{fmi3Float64}
    jac_ẋy_u::Matrix{fmi3Float64}
    jac_x::Array{fmi3Float64}
    jac_u::Union{Array{fmi3Float64}, Nothing}
    jac_t::fmi3Float64
    senseFunc::Symbol       # :auto, :full, :sample, :directionalDerivatives, :adjointDerivatives

    # linearization jacobians
    A::Union{Matrix{fmi3Float64}, Nothing}
    B::Union{Matrix{fmi3Float64}, Nothing}
    C::Union{Matrix{fmi3Float64}, Nothing}
    D::Union{Matrix{fmi3Float64}, Nothing}

    jacobianUpdate!             # function for a custom jacobian constructor (optimization)
    skipNextDoStep::Bool    # allows skipping the next `fmi3DoStep` like it is not called
    
    # custom

    rootsFound::Array{fmi3Int32}
    stateEvent::fmi3Boolean
    timeEvent::fmi3Boolean
    stepEvent::fmi3Boolean

    # constructor

    function FMU3Instance{F}() where {F}
        inst = new()
        inst.state = fmi3InstanceStateInstantiated
        inst.t = -Inf
        inst.t_offset = 0.0
        inst.problem = nothing
        inst.type = nothing
        
        # deprecated
        inst.senseFunc = :auto
        
        inst.x = nothing
        inst.ẋ = nothing
        inst.ẍ = nothing
        inst.z_prev = nothing

        inst.realValues = Dict()
        inst.x_vrs = Array{fmi3ValueReference, 1}()
        inst.ẋ_vrs = Array{fmi3ValueReference, 1}() 
        inst.u_vrs = Array{fmi3ValueReference, 1}()  
        inst.y_vrs = Array{fmi3ValueReference, 1}()  
        inst.p_vrs = Array{fmi3ValueReference, 1}() 

        # initialize further variables 
        inst.jac_x = Array{fmi3Float64, 1}()
        inst.jac_u = nothing
        inst.jac_t = -1.0
        inst.jac_ẋy_x = zeros(fmi3Float64, 0, 0)
        inst.jac_ẋy_u = zeros(fmi3Float64, 0, 0)
        inst.A = nothing
        inst.B = nothing
        inst.C = nothing
        inst.D = nothing

        # initialize further variables
        inst.skipNextDoStep = false

        return inst
    end

    function FMU3Instance(compAddr::fmi3Instance, fmu::F) where {F}
        inst = FMU3Instance{F}()
        inst.compAddr = compAddr
        inst.fmu = fmu
        return inst
    end
end
export FMU3Instance

""" 
Overload the Base.show() function for custom printing of the FMU3Instance.
"""
Base.show(io::IO, c::FMU3Instance) = print(io,
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
For FMUs that have issues with calls like `fmi3Reset` or `fmi3FreeInstance`, this is pretty useful.
"""
mutable struct FMU3ExecutionConfiguration <: FMUExecutionConfiguration
    terminate::Bool     # call fmi3Terminate before every training step / simulation
    reset::Bool         # call fmi3Reset before every training step / simulation
    setup::Bool         # call setup functions before every training step / simulation
    instantiate::Bool   # call fmi3Instantiate before every training step / simulation
    freeInstance::Bool  # call fmi3FreeInstance after every training step / simulation

    loggingOn::Bool 
    externalCallbacks::Bool    

    handleStateEvents::Bool                 # handle state events during simulation/training
    handleTimeEvents::Bool                  # handle time events during simulation/training
    handleEventIndicators::Union{Array{Integer}, Nothing}   # indices of event indicators to be handled, if `nothing` all are handled

    assertOnError::Bool                     # wheter an exception is thrown if a fmi3XXX-command fails (>= fmi3StatusError)
    assertOnWarning::Bool                   # wheter an exception is thrown if a fmi3XXX-command warns (>= fmi3StatusWarning)

    autoTimeShift::Bool                     # wheter to shift all time-related functions for simulation intervals not starting at 0.0

    sensealg                                # algorithm for sensitivity estimation over solve call
    useComponentShadow::Bool                # whether FMU outputs/derivatives/jacobians should be cached for frule/rrule (useful for ForwardDiff)
    rootSearchInterpolationPoints::UInt     # number of root search interpolation points
    inPlace::Bool                           # whether faster in-place-fx should be used
    useVectorCallbacks::Bool                # whether to vector (faster) or scalar (slower) callbacks

    maxNewDiscreteStateCalls::UInt          # max calls for fmi3NewDiscreteStates before throwing an exception

    function FMU3ExecutionConfiguration()
        inst = new()

        inst.terminate = true 
        inst.reset = true
        inst.setup = true
        inst.instantiate = false 
        inst.freeInstance = false

        inst.loggingOn = false
        inst.externalCallbacks = false 

        inst.handleStateEvents = true
        inst.handleTimeEvents = true
        inst.handleEventIndicators = nothing

        inst.assertOnError = false
        inst.assertOnWarning = false

        inst.autoTimeShift = true

        inst.sensealg = nothing # auto
        inst.useComponentShadow = false
        inst.rootSearchInterpolationPoints = 100
        inst.inPlace = true
        inst.useVectorCallbacks = true

        inst.maxNewDiscreteStateCalls = 100

        return inst 
    end
end
export FMU3ExecutionConfiguration

# default for a "healthy" FMU - this is the fastetst 
FMU3_EXECUTION_CONFIGURATION_RESET = FMU3ExecutionConfiguration()
FMU3_EXECUTION_CONFIGURATION_RESET.terminate = true
FMU3_EXECUTION_CONFIGURATION_RESET.reset = true
FMU3_EXECUTION_CONFIGURATION_RESET.instantiate = false
FMU3_EXECUTION_CONFIGURATION_RESET.freeInstance = false
export FMU3_EXECUTION_CONFIGURATION_RESET

# if your FMU has a problem with "fmi3Reset" - this is default
FMU3_EXECUTION_CONFIGURATION_NO_RESET = FMU3ExecutionConfiguration() 
FMU3_EXECUTION_CONFIGURATION_NO_RESET.terminate = false
FMU3_EXECUTION_CONFIGURATION_NO_RESET.reset = false
FMU3_EXECUTION_CONFIGURATION_NO_RESET.instantiate = true
FMU3_EXECUTION_CONFIGURATION_NO_RESET.freeInstance = true
export FMU3_EXECUTION_CONFIGURATION_NO_RESET

# if your FMU has a problem with "fmi3Reset" and "fmi3FreeInstance" - this is for weak FMUs (but slower)
FMU3_EXECUTION_CONFIGURATION_NO_FREEING = FMU3ExecutionConfiguration() 
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.terminate = false
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.reset = false
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.instantiate = true
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.freeInstance = false
export FMU3_EXECUTION_CONFIGURATION_NO_FREEING

"""
Container for event related information. 
"""
struct FMU3Event <: FMUEvent
    t::fmi3Float64                          # event time point
    indicator::UInt                   # index of event indicator ("0" for time events)

    x_left::Union{Array{fmi3Float64, 1}, Nothing}                # state before the event
    x_right::Union{Array{fmi3Float64, 1}, Nothing}               # state after the event (if discontinuous)

    indicatorValue::Union{fmi3Float64, Nothing}         # value of the event indicator that triggered the event (should be really close to zero)

    function FMU3Event(t::fmi3Float64, 
                        indicator::UInt = 0, 
                        x_left::Union{Array{fmi3Float64, 1}, Nothing} = nothing, 
                        x_right::Union{Array{fmi3Float64, 1}, Nothing} = nothing,
                        indicatorValue::Union{fmi3Float64, Nothing} = nothing)
        inst = new(t, indicator, x_left, x_right, indicatorValue)
        return inst 
    end
end
export FMU3Event

""" 
Overload the Base.show() function for custom printing of the FMU3.
"""
Base.show(io::IO, e::FMU3Event) = print(io, e.indicator == 0 ? "Time-Event @ $(round(e.t; digits=4))s" : "State-Event #$(e.indicator) @ $(round(e.t; digits=4))s")


""" 
ToDo 
"""
mutable struct FMU3Solution{F} <: FMUSolution where {F}
    fmu::F                                             # FMU3
    success::Bool

    states                                          # TODO: ODESolution 

    values                                          # TODO: datatype
    valueReferences::Union{Array, Nothing}          # TODO: Array{fmi3ValueReference}

    events::Array{FMU3Event, 1}
    
    function FMU3Solution(fmu::F) where {F}
        inst = new{F}()

        inst.fmu = fmu
        inst.success = false
        inst.states = nothing 
        inst.values = nothing
        inst.valueReferences = nothing

        inst.events = []
        
        return inst
    end
end
export FMU3Solution

""" 
Overload the Base.show() function for custom printing of the FMU3.
"""
function Base.show(io::IO, sol::FMU3Solution) 
    print(io, "Model name:\n\t$(sol.fmu.modelDescription.modelName)\nSuccess:\n\t$(sol.success)\n")

    if sol.states !== nothing
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

    if sol.values !== nothing
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

    if sol.events !== nothing
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
Source: FMISpec3.0, Version D5ef1c1: 2.2.1. Header Files and Naming of Functions

The mutable struct representing an FMU in the FMI 3.0 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 3.0 function pointers
"""
mutable struct FMU3 <: FMU
    modelName::String
    fmuResourceLocation::String

    modelDescription::fmi3ModelDescription

    type::fmi3Type
    instances::Array{FMU3Instance,1}   

    # c-functions
    cInstantiateModelExchange::Ptr{Cvoid}
    cInstantiateCoSimulation::Ptr{Cvoid}
    cInstantiateScheduledExecution::Ptr{Cvoid}

    cGetVersion::Ptr{Cvoid}
    cFreeInstance::Ptr{Cvoid}
    cSetDebugLogging::Ptr{Cvoid}
    cEnterConfigurationMode::Ptr{Cvoid}
    cExitConfigurationMode::Ptr{Cvoid}
    cEnterInitializationMode::Ptr{Cvoid}
    cExitInitializationMode::Ptr{Cvoid}
    cTerminate::Ptr{Cvoid}
    cReset::Ptr{Cvoid}
    cGetFloat32::Ptr{Cvoid}
    cSetFloat32::Ptr{Cvoid}
    cGetFloat64::Ptr{Cvoid}
    cSetFloat64::Ptr{Cvoid}
    cGetInt8::Ptr{Cvoid}
    cSetInt8::Ptr{Cvoid}
    cGetUInt8::Ptr{Cvoid}
    cSetUInt8::Ptr{Cvoid}
    cGetInt16::Ptr{Cvoid}
    cSetInt16::Ptr{Cvoid}
    cGetUInt16::Ptr{Cvoid}
    cSetUInt16::Ptr{Cvoid}
    cGetInt32::Ptr{Cvoid}
    cSetInt32::Ptr{Cvoid}
    cGetUInt32::Ptr{Cvoid}
    cSetUInt32::Ptr{Cvoid}
    cGetInt64::Ptr{Cvoid}
    cSetInt64::Ptr{Cvoid}
    cGetUInt64::Ptr{Cvoid}
    cSetUInt64::Ptr{Cvoid}
    cGetBoolean::Ptr{Cvoid}
    cSetBoolean::Ptr{Cvoid}
    cGetString::Ptr{Cvoid}
    cSetString::Ptr{Cvoid}
    cGetBinary::Ptr{Cvoid}
    cSetBinary::Ptr{Cvoid}
    cGetFMUState::Ptr{Cvoid}
    cSetFMUState::Ptr{Cvoid}
    cFreeFMUState::Ptr{Cvoid}
    cSerializedFMUStateSize::Ptr{Cvoid}
    cSerializeFMUState::Ptr{Cvoid}
    cDeSerializeFMUState::Ptr{Cvoid}
    cGetDirectionalDerivative::Ptr{Cvoid}
    cGetAdjointDerivative::Ptr{Cvoid}
    cEvaluateDiscreteStates::Ptr{Cvoid}
    cGetNumberOfVariableDependencies::Ptr{Cvoid}
    cGetVariableDependencies::Ptr{Cvoid}

    # Co Simulation function calls
    cGetOutputDerivatives::Ptr{Cvoid}
    cEnterStepMode::Ptr{Cvoid}
    cDoStep::Ptr{Cvoid}

    # Model Exchange function calls
    cGetNumberOfContinuousStates::Ptr{Cvoid}
    cGetNumberOfEventIndicators::Ptr{Cvoid}
    cGetContinuousStates::Ptr{Cvoid}
    cGetNominalsOfContinuousStates::Ptr{Cvoid}
    cEnterContinuousTimeMode::Ptr{Cvoid}
    cSetTime::Ptr{Cvoid}
    cSetContinuousStates::Ptr{Cvoid}
    cGetContinuousStateDerivatives::Ptr{Cvoid}
    cGetEventIndicators::Ptr{Cvoid}
    cCompletedIntegratorStep::Ptr{Cvoid}
    cEnterEventMode::Ptr{Cvoid}
    cUpdateDiscreteStates::Ptr{Cvoid}

    # Scheduled Execution function calls
    cSetIntervalDecimal::Ptr{Cvoid}
    cSetIntervalFraction::Ptr{Cvoid}
    cGetIntervalDecimal::Ptr{Cvoid}
    cGetIntervalFraction::Ptr{Cvoid}
    cGetShiftDecimal::Ptr{Cvoid}
    cGetShiftFraction::Ptr{Cvoid}
    cActivateModelPartition::Ptr{Cvoid}

    # paths of ziped and unziped FMU folders
    path::String
    binaryPath::String
    zipPath::String

    # execution configuration
    executionConfig::FMU3ExecutionConfiguration
    hasStateEvents::Union{Bool, Nothing} 
    hasTimeEvents::Union{Bool, Nothing} 

    # c-libraries
    libHandle::Ptr{Nothing}
    callbackLibHandle::Ptr{Nothing}

    # START: experimental section (to FMIFlux.jl)
    dependencies::Matrix{Union{fmi3DependencyKind, Nothing}}
    # linearization jacobians deprecated
    # A::Matrix{fmi3Float64}
    # B::Matrix{fmi3Float64}
    # C::Matrix{fmi3Float64}
    # D::Matrix{fmi3Float64}

    # END: experimental section

    # Constructor
    function FMU3() 
        inst = new()
        inst.instances = []
        inst.callbackLibHandle = C_NULL
        inst.modelName = ""

        inst.hasStateEvents = nothing 
        inst.hasTimeEvents = nothing

        inst.executionConfig = FMU3_EXECUTION_CONFIGURATION_NO_RESET
        return inst 
    end
end
export FMU3

""" Overload the Base.show() function for custom printing of the FMU3"""
Base.show(io::IO, fmu::FMU3) = print(io,
"Model name:       $(fmu.modelName)
Type:              $(fmu.type)"
)
