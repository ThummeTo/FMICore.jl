#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - the `fmi3ComponentState`-enum which mirrors the internal FMU state (state-machine, not the system state)
# - the `FMU3Component`-struct 
# - the `FMU3`-struct
# - string/enum-converters for FMI-attribute-structs (e.g. `fmi3StatusToString`, ...)

# this is a custom type to catch the internal state of the component 
@enum fmi3ComponentState begin
    # ToDo
    fmi3ComponentToDo
end

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.2.1. Header Files and Naming of Functions

The mutable struct represents a pointer to an FMU specific data structure that contains the information needed to process the model equations or to process the co-simulation of the model/subsystem represented by the FMU.
"""
mutable struct FMU3Component
    compAddr::Ptr{Nothing}
    fmu
    state 
    
    loggingOn::Bool
    instanceName::String
    continuousStatesChanged::fmi3Boolean

    t::fmi3Float64             # the system time
    #x::Array{fmi3Float64, 1}   # the system states (or sometimes u)
    #ẋ::Array{fmi3Float64, 1}   # the system state derivative (or sometimes u̇)
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

    # FMIFlux 

    jac_dxy_x::Matrix{fmi3Float64}
    jac_dxy_u::Matrix{fmi3Float64}
    jac_x::Array{fmi3Float64}
    jac_t::fmi3Float64
    skipNextDoStep::Bool    # allows skipping the next `fmi2DoStep` like it is not called

    # custom

    rootsFound::Array{fmi3Int32}
    stateEvent::fmi3Boolean
    timeEvent::fmi3Boolean
    stepEvent::fmi3Boolean

    function fmi3Component(compAddr, fmu)
        inst = new()
        inst.compAddr = compAddr
        inst.fmu = fmu
        inst.t = 0.0

        inst.z_prev = nothing

        inst.realValues = Dict()
        inst.x_vrs = Array{fmi3ValueReference, 1}()
        inst.ẋ_vrs = Array{fmi3ValueReference, 1}() 
        inst.u_vrs = Array{fmi3ValueReference, 1}()  
        inst.y_vrs = Array{fmi3ValueReference, 1}()  
        inst.p_vrs = Array{fmi3ValueReference, 1}() 

        # initialize further variables 
        inst.jac_x = Array{fmi3Float64, 1}()
        inst.jac_t = -1.0
        inst.jac_dxy_x = zeros(fmi3Float64, 0, 0)
        inst.jac_dxy_u = zeros(fmi3Float64, 0, 0)
        inst.skipNextDoStep = false

        return inst
    end
end

""" Overload the Base.show() function for custom printing of the FMU2Component"""
Base.show(io::IO, fmu::FMU3Component) = print(io,
"FMU2:              $(fmu.fmu)
State:              $(fmu.state)
Logging:            $(fmu.loggingOn)
Instance name:      $(fmu.instanceName)
System time:        $(fmu.t)
Values:             $(fmu.realValues)"
)

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
    components::Array # {fmi3Component}   

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
    zipPath::String

    # c-libraries
    libHandle::Ptr{Nothing}

    # START: experimental section (to FMIFlux.jl)
    dependencies::Matrix

    # linearization jacobians
    A::Matrix{fmi2Real}
    B::Matrix{fmi2Real}
    C::Matrix{fmi2Real}
    D::Matrix{fmi2Real}

    # END: experimental section

    # Constructor
    function FMU3() 
        inst = new()
        inst.components = []
        return inst 
    end
end

""" Overload the Base.show() function for custom printing of the FMU3"""
Base.show(io::IO, fmu::FMU3) = print(io,
"Model name:        $(fmu.modelName)
Instance name:      $(fmu.instanceName)
Model description:  $(fmu.modelDescription)
Type:               $(fmu.type)
Components:         $(fmu.components)"
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

# ToDo: Equivalent of fmi2CausalityToString, fmi2StringToCausality, ...