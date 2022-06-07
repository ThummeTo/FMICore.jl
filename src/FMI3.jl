#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - the `fmi3InstanceState`-enum which mirrors the internal FMU state (state-machine, not the system state)
# - the `FMU3Instance`-struct 
# - the `FMU3`-struct
# - string/enum-converters for FMI-attribute-structs (e.g. `fmi3StatusToString`, ...)

# this is a custom type to catch the internal state of the instance

@enum fmi3InstanceState begin
    fmi3InstanceStateInstantiated       # after instantiation
    fmi3InstanceStateInitializationMode # after finishing initialization
    fmi3InstanceStateEventMode
    fmi3InstanceStateStepMode
    fmi3InstanceStateClockActivationMode
    fmi3InstanceStateContinuousTimeMode
    fmi3InstanceStateConfigurationMode
    fmi3InstanceStateReconfigurationMode
    fmi3InstanceStateTerminated 
    fmi3InstanceStateError 
    fmi3InstanceStateFatal
end

"""
ToDo.
"""
mutable struct FMU3InstanceEnvironment
    logStatusOK::Bool
    logStatusWarning::Bool
    logStatusDiscard::Bool
    logStatusError::Bool
    logStatusFatal::Bool
    logStatusPending::Bool

    function FMU3InstanceEnvironment()
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

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.2.1. Header Files and Naming of Functions

The mutable struct represents a pointer to an FMU specific data structure that contains the information needed to process the model equations or to process the co-simulation of the model/subsystem represented by the FMU.
"""
mutable struct FMU3Instance
    compAddr::Ptr{Nothing}
    fmu # ::FMU3
    state::fmi3InstanceState
    instanceEnvironment::FMU3InstanceEnvironment

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

    # linearization jacobians
    A::Union{Matrix{fmi3Float64}, Nothing}
    B::Union{Matrix{fmi3Float64}, Nothing}
    C::Union{Matrix{fmi3Float64}, Nothing}
    D::Union{Matrix{fmi3Float64}, Nothing}

    jacobianUpdate!             # function for a custom jacobian constructor (optimization)
    skipNextDoStep::Bool    # allows skipping the next `fmi3DoStep` like it is not called
    senseFunc::Symbol       # :auto, :full, :sample, :directionalDerivatives, :adjointDerivatives

    # custom

    rootsFound::Array{fmi3Int32}
    stateEvent::fmi3Boolean
    timeEvent::fmi3Boolean
    stepEvent::fmi3Boolean

    # constructor

    function FMU3Instance()
        inst = new()
        inst.state = fmi3InstanceStateInstantiated
        inst.t = -Inf
        inst.t_offset = 0.0

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
        inst.skipNextDoStep = false

        inst.A = nothing
        inst.B = nothing
        inst.C = nothing
        inst.D = nothing
        return inst
    end

    function FMU3Instance(compAddr, fmu)
        inst = FMU3Instance()
        inst.compAddr = compAddr
        inst.fmu = fmu
        return inst
    end
end

""" 
Overload the Base.show() function for custom printing of the FMU2Component.
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
=======
A mutable struct representing the excution configuration of a FMU.
For FMUs that have issues with calls like `fmi3Reset` or `fmi3FreeInstance`, this is pretty useful.
"""
mutable struct FMU3ExecutionConfiguration <: FMUExecutionConfig
    terminate::Bool     # call fmi3Terminate before every training step / simulation
    reset::Bool         # call fmi3Reset before every training step / simulation
    setup::Bool         # call setup functions before every training step / simulation
    instantiate::Bool   # call fmi3Instantiate before every training step / simulation
    freeInstance::Bool  # call fmi3FreeInstance after every training step / simulation

    loggingOn::Bool 
    externalCallbacks::Bool    

    handleStateEvents::Bool                 # handle state events during simulation/training
    handleTimeEvents::Bool                  # handle time events during simulation/training

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

# default for a "healthy" FMU - this is the fastetst 
FMU3_EXECUTION_CONFIGURATION_RESET = FMU3ExecutionConfiguration()
FMU3_EXECUTION_CONFIGURATION_RESET.terminate = true
FMU3_EXECUTION_CONFIGURATION_RESET.reset = true
FMU3_EXECUTION_CONFIGURATION_RESET.instantiate = false
FMU3_EXECUTION_CONFIGURATION_RESET.freeInstance = false

# if your FMU has a problem with "fmi3Reset" - this is default
FMU3_EXECUTION_CONFIGURATION_NO_RESET = FMU3ExecutionConfiguration() 
FMU3_EXECUTION_CONFIGURATION_NO_RESET.terminate = false
FMU3_EXECUTION_CONFIGURATION_NO_RESET.reset = false
FMU3_EXECUTION_CONFIGURATION_NO_RESET.instantiate = true
FMU3_EXECUTION_CONFIGURATION_NO_RESET.freeInstance = true

# if your FMU has a problem with "fmi3Reset" and "fmi3FreeInstance" - this is for weak FMUs (but slower)
FMU3_EXECUTION_CONFIGURATION_NO_FREEING = FMU3ExecutionConfiguration() 
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.terminate = false
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.reset = false
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.instantiate = true
FMU3_EXECUTION_CONFIGURATION_NO_FREEING.freeInstance = false

"""
ToDo 
"""
struct FMU3Event <: FMUEvent
    t::Union{Float32, Float64}
    indicator::UInt
    
    x_left::Union{Array{Float64, 1}, Array{Float32, 1}, Nothing}
    x_right::Union{Array{Float64, 1}, Array{Float32, 1}, Nothing}

    function FMU3Event(t::Union{Float32, Float64}, indicator::UInt = 0, x_left::Union{Array{Float64, 1}, Array{Float32, 1}, Nothing} = nothing, x_right::Union{Array{Float64, 1}, Array{Float32, 1}, Nothing} = nothing)
        inst = new(t, indicator, x_left, x_right)
        return inst 
    end
end

""" 
ToDo 
"""
mutable struct FMU3Solution <: FMUSolution
    fmu                                             # FMU2
    success::Bool

    states                                          # ODESolution 

    values
    valueReferences::Union{Array, Nothing}          # Array{fmi3ValueReference}

    events::Array{FMU2Event, 1}
    
    function FMU3Solution(fmu)
        inst = new()

        inst.fmu = fmu
        inst.success = false
        inst.states = nothing 
        inst.values = nothing
        inst.valueReferences = nothing

        inst.events = []
        
        return inst
    end
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.1. Header Files and Naming of Functions

The mutable struct representing an FMU in the FMI 3.0 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 3.0 function pointers
"""
mutable struct FMU3 <: FMU
    modelName::String
    instanceName::String
    fmuResourceLocation::String

    modelDescription::fmi3ModelDescription

    type::fmi3Type
    instanceEnvironment::fmi3InstanceEnvironment
    instances::Array # {fmi3Instance}   

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

    # START: experimental section (to FMIFlux.jl)
    dependencies::Matrix
    # linearization jacobians
    A::Matrix{fmi3Float64}
    B::Matrix{fmi3Float64}
    C::Matrix{fmi3Float64}
    D::Matrix{fmi3Float64}

    # END: experimental section

    # Constructor
    function FMU3() 
        inst = new()
        inst.instances = []

        inst.hasStateEvents = nothing 
        inst.hasTimeEvents = nothing

        inst.executionConfig = FMU3_EXECUTION_CONFIGURATION_NO_RESET
        return inst 
    end
end

""" Overload the Base.show() function for custom printing of the FMU3"""
Base.show(io::IO, fmu::FMU3) = print(io,
"Model name:       $(fmu.modelName)
Instance name:     $(fmu.instanceName)
Model description: $(fmu.modelDescription)
Type:              $(fmu.type)
Instances:        $(fmu.instances)"
)

"""
Formats the fmi3Status into a String.
"""
function fmi3StatusToString(status::fmi3Status)
    if status == fmi3StatusOK
        return "OK"
    elseif status == fmi3StatusWarning
        return "Warning"
    elseif status == fmi3StatusDiscard
        return "Discard"
    elseif status == fmi3StatusError
        return "Error"
    elseif status == fmi3StatusFatal
        return "Fatal"
    else
        return "Unknown"
    end
end

"""
Formats the fmi3Status into a Integer.
"""
function fmi3StatusToString(status::Integer)
    if status == fmi3StatusOK
        return "OK"
    elseif status == fmi3StatusWarning
        return "Warning"
    elseif status == fmi3StatusDiscard
        return "Discard"
    elseif status == fmi3StatusError
        return "Error"
    elseif status == fmi3StatusFatal
        return "Fatal"
    else
        return "Unknown"
    end
end

function fmi3CausalityToString(c::fmi3Causality)
    if c == fmi3CausalityParameter
        return "parameter"
    elseif c == fmi3CausalityCalculatedParameter
        return "calculatedParameter"
    elseif c == fmi3CausalityInput
        return "input"
    elseif c == fmi3CausalityOutput
        return "output"
    elseif c == fmi3CausalityLocal
        return "local"
    elseif c == fmi3CausalityIndependent
        return "independent"
    elseif c == fmi3CausalityStructuralParameter
        return "structuralParameter"
    else 
        @assert false "fmi3CausalityToString(...): Unknown causality."
    end
end

function fmi3StringToCausality(s::String)
    if s == "parameter"
        return fmi3CausalityParameter
    elseif s == "calculatedParameter"
        return fmi3CausalityCalculatedParameter
    elseif s == "input"
        return fmi3CausalityInput
    elseif s == "output"
        return fmi3CausalityOutput
    elseif s == "local"
        return fmi3CausalityLocal
    elseif s == "independent"
        return fmi3CausalityIndependent
    elseif s == "structuralParameter"
        return fmi3CausalityStructuralParameter
    else 
        @assert false "fmi3StringToCausality($(s)): Unknown causality."
    end
end

function fmi3VariabilityToString(c::fmi3Variability)
    if c == fmi3VariabilityConstant
        return "constant"
    elseif c == fmi3VariabilityFixed
        return "fixed"
    elseif c == fmi3VariabilityTunable
        return "tunable"
    elseif c == fmi3VariabilityDiscrete
        return "discrete"
    elseif c == fmi3VariabilityContinuous
        return "continuous"
    else 
        @assert false "fmi3VariabilityToString(...): Unknown variability."
    end
end

function fmi3StringToVariability(s::String)
    if s == "constant"
        return fmi3VariabilityConstant
    elseif s == "fixed"
        return fmi3VariabilityFixed
    elseif s == "tunable"
        return fmi3VariabilityTunable
    elseif s == "discrete"
        return fmi3VariabilityDiscrete
    elseif s == "continuous"
        return fmi3VariabilityContinuous
    else 
        @assert false "fmi3StringToVariability($(s)): Unknown variability."
    end
end

function fmi3InitialToString(c::fmi3Initial)
    if c == fmi3InitialApprox
        return "approx"
    elseif c == fmi3InitialExact
        return "exact"
    elseif c == fmi3InitialCalculated
        return "calculated"
    else 
        @assert false "fmi3InitialToString(...): Unknown initial."
    end
end

function fmi3StringToInitial(s::String)
    if s == "approx"
        return fmi3InitialApprox
    elseif s == "exact"
        return fmi3InitialExact
    elseif s == "calculated"
        return fmi3InitialCalculated
    else 
        @assert false "fmi3StringToInitial($(s)): Unknown initial."
    end
end

function fmi3TypeToString(c::fmi3Type)
    if c == fmi3TypeCoSimulation
        return "coSimulation"
    elseif c == fmi3TypeModelExchange
        return "modelExchange"
    elseif c == fmi3TypeScheduledExecution
        return "scheduledExecution"
    else 
        @assert false "fmi3TypeToString(...): Unknown type."
    end
end

function fmi3StringToType(s::String)
    if s == "coSimulation"
        return fmi3TypeCoSimulation
    elseif s == "modelExchange"
        return fmi3TypeModelExchange
    elseif s == "scheduledExecution"
        return fmi3TypeScheduledExecution
    else 
        @assert false "fmi3StringToInitial($(s)): Unknown type."
    end
end

function fmi3IntervalQualifierToString(c::fmi3IntervalQualifier)
    if c == fmi3IntervalQualifierIntervalNotYetKnown
        return "intervalNotYetKnown"
    elseif c == fmi3IntervalQualifierIntervalUnchanged
        return "intervalUnchanged"
    elseif c == fmi3IntervalQualifierIntervalChanged
        return "intervalChanged"
    else 
        @assert false "fmi3IntervalQualifierToString(...): Unknown intervalQualifier."
    end
end

function fmi3StringToIntervalQualifier(s::String)
    if s == "intervalNotYetKnown"
        return fmi3IntervalQualifierIntervalNotYetKnown
    elseif s == "intervalUnchanged"
        return fmi3IntervalQualifierIntervalUnchanged
    elseif s == "intervalChanged"
        return fmi3IntervalQualifierIntervalChanged
    else 
        @assert false "fmi3StringToIntervalQualifier($(s)): Unknown intervalQualifier."
    end
end

function fmi3DependencyKindToString(c::fmi3DependencyKind)
    if c == fmi3DependencyKindIndependent
        return "independent"
    elseif c == fmi3DependencyKindConstant
        return "constant"
    elseif c == fmi3DependencyKindFixed
        return "fixed"
    elseif c == fmi3DependencyKindTunable
        return "tunable"
    elseif c == fmi3DependencyKindDiscrete
        return "discrete"
    elseif c == fmi3DependencyKindDependent
        return "dependent"
    else 
        @assert false "fmi3DependencyKindToString(...): Unknown dependencyKind."
    end
end

function fmi3StringToDependencyKind(s::AbstractString)
    if s == "independent"
        return fmi3DependencyKindIndependent
    elseif s == "constant"
        return fmi3DependencyKindConstant
    elseif s == "fixed"
        return fmi3DependencyKindFixed
    elseif s == "tunable"
        return fmi3DependencyKindTunable
    elseif s == "discrete"
        return fmi3DependencyKindDiscrete
    elseif s == "dependent"
        return fmi3DependencyKindDependent
    else 
        @assert false "fmi3StringToDependencyKind($(s)): Unknown dependencyKind."
    end
end

function fmi3VariableNamingConventionToString(c::fmi3VariableNamingConvention)
    if c == fmi3VariableNamingConventionFlat
        return "flat"
    elseif c == fmi3VariableNamingConventionStructured
        return "structured"
    else 
        @assert false "fmi3VariableNamingConventionToString(...): Unknown variableNamingConvention."
    end
end

function fmi3StringToVariableNamingConvention(s::String)
    if s == "flat"
        return fmi3VariableNamingConventionFlat
    elseif s == "structured"
        return fmi3VariableNamingConventionStructured
    else 
        @assert false "fmi3StringToVariableNamingConvention($(s)): Unknown variableNamingConvention."
    end
end