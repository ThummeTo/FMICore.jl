#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - the `fmi2ComponentState`-enum which mirrors the internal FMU state (state-machine, not the system state)
# - the `FMU2Component`-struct 
# - the `FMU2`-struct
# - string/enum-converters for FMI-attribute-structs (e.g. `fmi2StatusToString`, ...)

# this is a custom type to catch the internal state of the component 
@enum fmi2ComponentState begin
    fmi2ComponentStateModelSetableFMUstate
    fmi2ComponentStateModelUnderEvaluation
    fmi2ComponentStateModelInitialized
end

"""
The mutable struct represents an instantiated instance of an FMU in the FMI 2.0.2 Standard.
"""
mutable struct FMU2Component
    compAddr::Ptr{Nothing}
    fmu # ::FMU2
    state::fmi2ComponentState

    loggingOn::Bool
    callbackFunctions::fmi2CallbackFunctions
    instanceName::String
    continuousStatesChanged::fmi2Boolean
    
    t::fmi2Real             # the system time
    x::Union{Array{fmi2Real, 1}, Nothing}   # the system states (or sometimes u)
    ẋ::Union{Array{fmi2Real, 1}, Nothing}   # the system state derivative (or sometimes u̇)
    ẍ::Union{Array{fmi2Real, 1}, Nothing}   # the system state second derivative
    #u::Array{fmi2Real, 1}   # the system inputs
    #y::Array{fmi2Real, 1}   # the system outputs
    #p::Array{fmi2Real, 1}   # the system parameters
    z::Array{fmi2Real, 1}   # the system event indicators
    z_prev::Union{Nothing, Array{fmi2Real, 1}}   # the last system event indicators

    realValues::Dict    

    x_vrs::Array{fmi2ValueReference, 1}   # the system state value references 
    ẋ_vrs::Array{fmi2ValueReference, 1}   # the system state derivative value references
    u_vrs::Array{fmi2ValueReference, 1}   # the system input value references
    y_vrs::Array{fmi2ValueReference, 1}   # the system output value references
    p_vrs::Array{fmi2ValueReference, 1}   # the system parameter value references

    # FMIFlux 

    # deprecated
    jac_dxy_x::Matrix{fmi2Real}
    jac_dxy_u::Matrix{fmi2Real}
    jac_x::Array{fmi2Real}
    jac_t::fmi2Real

    # linearization jacobians
    A::Union{Matrix{fmi2Real}, Nothing}
    B::Union{Matrix{fmi2Real}, Nothing}
    C::Union{Matrix{fmi2Real}, Nothing}
    D::Union{Matrix{fmi2Real}, Nothing}

    jacobianFct             # function for a custom jacobian constructor (optimization)
    skipNextDoStep::Bool    # allows skipping the next `fmi2DoStep` like it is not called
    senseFunc::Symbol       # :auto, :full, :sample, :directionalDerivatives, :adjointDerivatives

    # constructor

    function FMU2Component()
        inst = new()
        inst.state = fmi2ComponentStateModelUnderEvaluation
        inst.t = -Inf

        inst.senseFunc = :auto

        inst.x = nothing
        inst.ẋ = nothing
        inst.ẍ = nothing
        inst.z_prev = nothing

        inst.realValues = Dict()
        inst.x_vrs = Array{fmi2ValueReference, 1}()
        inst.ẋ_vrs = Array{fmi2ValueReference, 1}() 
        inst.u_vrs = Array{fmi2ValueReference, 1}()  
        inst.y_vrs = Array{fmi2ValueReference, 1}()  
        inst.p_vrs = Array{fmi2ValueReference, 1}() 

        # initialize further variables 
        inst.jac_x = Array{fmi2Real, 1}()
        inst.jac_t = -1.0
        inst.jac_dxy_x = zeros(fmi2Real, 0, 0)
        inst.jac_dxy_u = zeros(fmi2Real, 0, 0)
        inst.skipNextDoStep = false

        inst.A = nothing
        inst.B = nothing
        inst.C = nothing
        inst.D = nothing

        return inst
    end

    function FMU2Component(compAddr, fmu)
        inst = FMU2Component()
        inst.compAddr = compAddr
        inst.fmu = fmu
        return inst
    end
end

"""
The mutable struct representing a FMU and all it instantiated instances in the FMI 2.0.2 Standard.
Also contains the paths to the FMU and ZIP folder as well als all the FMI 2.0.2 function pointers.
"""
mutable struct FMU2 <: FMU
    modelName::String
    instanceName::String
    fmuResourceLocation::String

    modelDescription::fmi2ModelDescription

    type::fmi2Type
    callbackFunctions::fmi2CallbackFunctions
    components::Array # {fmi2Component}

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

    # paths of ziped and unziped FMU folders
    path::String
    binaryPath::String
    zipPath::String

    # c-libraries
    libHandle::Ptr{Nothing}
    callbackLibHandle::Ptr{Nothing}

    # START: experimental section (to FMIFlux.jl)
    dependencies::Matrix{fmi2DependencyKind}

    # END: experimental section

    # Constructor
    function FMU2() 
        inst = new()
        inst.components = []
        inst.callbackLibHandle = C_NULL
        return inst 
    end
end

"""
Formats a fmi2Status to String.
"""
function fmi2StatusToString(status::fmi2Status)
    if status == fmi2StatusOK
        return "OK"
    elseif status == fmi2StatusWarning
        return "Warning"
    elseif status == fmi2StatusDiscard
        return "Discard"
    elseif status == fmi2StatusError
        return "Error"
    elseif status == fmi2StatusFatal
        return "Fatal"
    elseif status == fmi2StatusPending
        return "Pending"
    else
        return "Unknown"
    end
end

"""
Formats a fmi2Status to Integer.
"""
function fmi2StatusToString(status::Integer)
    if status == fmi2StatusOK
        return "OK"
    elseif status == fmi2StatusWarning
        return "Warning"
    elseif status == fmi2StatusDiscard
        return "Discard"
    elseif status == fmi2StatusError
        return "Error"
    elseif status == fmi2StatusFatal
        return "Fatal"
    elseif status == fmi2StatusPending
        return "Pending"
    else
        return "Unknown"
    end
end

function fmi2CausalityToString(c::fmi2Causality)
    if c == fmi2CausalityParameter
        return "parameter"
    elseif c == fmi2CausalityCalculatedParameter
        return "calculatedParameter"
    elseif c == fmi2CausalityInput
        return "input"
    elseif c == fmi2CausalityOutput
        return "output"
    elseif c == fmi2CausalityLocal
        return "local"
    elseif c == fmi2CausalityIndependent
        return "independent"
    else 
        @assert false "fmi2CausalityToString(...): Unknown causality."
    end
end

function fmi2StringToCausality(s::String)
    if s == "parameter"
        return fmi2CausalityParameter
    elseif s == "calculatedParameter"
        return fmi2CausalityCalculatedParameter
    elseif s == "input"
        return fmi2CausalityInput
    elseif s == "output"
        return fmi2CausalityOutput
    elseif s == "local"
        return fmi2CausalityLocal
    elseif s == "independent"
        return fmi2CausalityIndependent
    else 
        @assert false "fmi2StringToCausality($(s)): Unknown causality."
    end
end

function fmi2VariabilityToString(c::fmi2Variability)
    if c == fmi2VariabilityConstant
        return "constant"
    elseif c == fmi2VariabilityFixed
        return "fixed"
    elseif c == fmi2VariabilityTunable
        return "tunable"
    elseif c == fmi2VariabilityDiscrete
        return "discrete"
    elseif c == fmi2VariabilityContinuous
        return "continuous"
    else 
        @assert false "fmi2VariabilityToString(...): Unknown variability."
    end
end

function fmi2StringToVariability(s::String)
    if s == "constant"
        return fmi2VariabilityConstant
    elseif s == "fixed"
        return fmi2VariabilityFixed
    elseif s == "tunable"
        return fmi2VariabilityTunable
    elseif s == "discrete"
        return fmi2VariabilityDiscrete
    elseif s == "continuous"
        return fmi2VariabilityContinuous
    else 
        @assert false "fmi2StringToVariability($(s)): Unknown variability."
    end
end

function fmi2InitialToString(c::fmi2Initial)
    if c == fmi2InitialApprox
        return "approx"
    elseif c == fmi2InitialExact
        return "exact"
    elseif c == fmi2InitialCalculated
        return "calculated"
    else 
        @assert false "fmi2InitialToString(...): Unknown initial."
    end
end

function fmi2StringToInitial(s::String)
    if s == "approx"
        return fmi2InitialApprox
    elseif s == "exact"
        return fmi2InitialExact
    elseif s == "calculated"
        return fmi2InitialCalculated
    else 
        @assert false "fmi2StringToInitial($(s)): Unknown initial."
    end
end

