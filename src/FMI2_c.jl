#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - fmi2xxx-structs and -functions from the FMI2-specification 
# - helper-structs that are not part of the FMI2-specification, but help to parse the model description nicely (e.g. `fmi2ModelDescriptionDefaultExperiment`, ...)

"""
Source: FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

FMI2 Data Types
To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section.
All definitions in this section are provided in the header file “fmi2TypesPlatform.h”.
"""
const fmi2Char = Cuchar
const fmi2String = Ptr{fmi2Char}
const fmi2Boolean = Cint
const fmi2Real = Creal      # defined in FMICore.jl
const fmi2Integer = Cint
const fmi2Byte = Char
const fmi2ValueReference = Cuint
const fmi2FMUstate = Ptr{Cvoid}
const fmi2Component = Ptr{Cvoid}
const fmi2ComponentEnvironment = Ptr{Cvoid}
const fmi2Enum = Array{Array{String}} # TODO: correct it

"""
Source: FMISpec2.0.2[p.18]: 2.1.3 Status Returned by Functions

Status returned by functions. The status has the following meaning:
fmi2OK – all well
fmi2Warning – things are not quite right, but the computation can continue. Function “logger” was called in the model (see below), and it is expected that this function has shown the prepared information message to the user.
fmi2Discard – this return status is only possible if explicitly defined for the corresponding function
(ModelExchange: fmi2SetReal, fmi2SetInteger, fmi2SetBoolean, fmi2SetString, fmi2SetContinuousStates, fmi2GetReal, fmi2GetDerivatives, fmi2GetContinuousStates, fmi2GetEventIndicators;
CoSimulation: fmi2SetReal, fmi2SetInteger, fmi2SetBoolean, fmi2SetString, fmi2DoStep, fmiGetXXXStatus):
For “model exchange”: It is recommended to perform a smaller step size and evaluate the model equations again, for example because an iterative solver in the model did not converge or because a function is outside of its domain (for example sqrt(<negative number>)). If this is not possible, the simulation has to be terminated.
For “co-simulation”: fmi2Discard is returned also if the slave is not able to return the required status information. The master has to decide if the simulation run can be continued. In both cases, function “logger” was called in the FMU (see below) and it is expected that this function has shown the prepared information message to the user if the FMU was called in debug mode (loggingOn = fmi2True). Otherwise, “logger” should not show a message.
fmi2Error – the FMU encountered an error. The simulation cannot be continued with this FMU instance. If one of the functions returns fmi2Error, it can be tried to restart the simulation from a formerly stored FMU state by calling fmi2SetFMUstate.
This can be done if the capability flag canGetAndSetFMUstate is true and fmi2GetFMUstate was called before in non-erroneous state. If not, the simulation cannot be continued and fmi2FreeInstance or fmi2Reset must be called afterwards.4 Further processing is possible after this call; especially other FMU instances are not affected. Function “logger” was called in the FMU (see below), and it is expected that this function has shown the prepared information message to the user.
fmi2Fatal – the model computations are irreparably corrupted for all FMU instances. [For example, due to a run-time exception such as access violation or integer division by zero during the execution of an fmi function]. Function “logger” was called in the FMU (see below), and it is expected that this function has shown the prepared information message to the user. It is not possible to call any other function for any of the FMU instances.
fmi2Pending – this status is returned only from the co-simulation interface, if the slave executes the function in an asynchronous way. That means the slave starts to compute but returns immediately. The master has to call fmi2GetStatus(..., fmi2DoStepStatus) to determine if the slave has finished the computation. Can be returned only by fmi2DoStep and by fmi2GetStatus (see section 4.2.3).
"""
const fmi2Status = Cuint
const fmi2StatusOK      = Cuint(0)
const fmi2StatusWarning = Cuint(1)
const fmi2StatusDiscard = Cuint(2)
const fmi2StatusError   = Cuint(3)
const fmi2StatusFatal   = Cuint(4)
const fmi2StatusPending = Cuint(5)

"""
Source: FMISpec2.0.2[p.19-22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The struct contains pointers to functions provided by the environment to be used by the FMU. It is not allowed to change these functions between fmi2Instantiate(..) and fmi2Terminate(..) calls. Additionally, a pointer to the environment is provided (componentEnvironment) that needs to be passed to the “logger” function, in order that the logger function can utilize data from the environment, such as mapping a valueReference to a string. In the unlikely case that fmi2Component is also needed in the logger, it has to be passed via argument componentEnvironment. Argument componentEnvironment may be a null pointer. The componentEnvironment pointer is also passed to the stepFinished(..) function in order that the environment can provide an efficient way to identify the slave that called stepFinished(..).
"""
mutable struct fmi2CallbackFunctions
    logger::Ptr{Cvoid}
    allocateMemory::Ptr{Cvoid}
    freeMemory::Ptr{Cvoid}
    stepFinished::Ptr{Cvoid}
    componentEnvironment::Ptr{Cvoid}
end

"""
A not further specified annotation struct.
"""
mutable struct fmi2Annotation
    # No implementation
end

"""
Source: FMISpec2.0.2[p.48]: 2.2.7 Definition of Model Variables (ModelVariables)

Enumeration that defines the causality of the variable. Allowed values of this enumeration:

"parameter": Independent parameter (a data value that is constant during the simulation and is provided by the environment and cannot be used in connections). variability must be "fixed" or "tunable". initial must be exact or not present (meaning exact).
"calculatedParameter": A data value that is constant during the simulation and is computed during initialization or when tunable parameters change. variability must be "fixed" or "tunable". initial must be "approx", "calculated" or not present (meaning calculated).
"input": The variable value can be provided from another model or slave. It is not allowed to define initial.
"output": The variable value can be used by another model or slave. The algebraic relationship to the inputs is defined via the dependencies attribute of <fmiModelDescription><ModelStructure><Outputs><Unknown>.
"local": Local variable that is calculated from other variables or is a continuous-time state (see section 2.2.8). It is not allowed to use the variable value in another model or slave.
"independent": The independent variable (usually “time”). All variables are a function of this independent variable. variability must be "continuous". At most one ScalarVariable of an FMU can be defined as "independent". If no variable is defined as "independent", it is implicitly present with name = "time" and unit = "s". If one variable is defined as "independent", it must be defined as "Real" without a "start" attribute. It is not allowed to call function fmi2SetReal on an "independent" variable. Instead, its value is initialized with fmi2SetupExperiment and after initialization set by fmi2SetTime for ModelExchange and by arguments currentCommunicationPoint and communicationStepSize of fmi2DoStep for CoSimulation. [The actual value can be inquired with fmi2GetReal.]
The default of causality is “local”. A continuous-time state must have causality = "local" or "output", see also section 2.2.8.
[causality = "calculatedParameter" and causality = "local" with variability = "fixed" or "tunable" are similar. The difference is that a calculatedParameter can be used in another model or slave, whereas a local variable cannot. For example, when importing an FMU in a Modelica environment, a "calculatedParameter" should be imported in a public section as final parameter, whereas a "local" variable should be imported in a protected section of the model.]
Added prefix "fmi2" to help with redefinition of constans in enums.
"""
const fmi2Causality = Cuint
const fmi2CausalityParameter              = Cuint(0)
const fmi2CausalityCalculatedParameter    = Cuint(1)
const fmi2CausalityInput                  = Cuint(2)
const fmi2CausalityOutput                 = Cuint(3)
const fmi2CausalityLocal                  = Cuint(4)
const fmi2CausalityIndependent            = Cuint(5)

"""
Source: FMISpec2.0.2[p.49]: 2.2.7 Definition of Model Variables (ModelVariables)

Enumeration that defines the time dependency of the variable, in other words, it defines the time instants when a variable can change its value.

"constant": The value of the variable never changes.
"fixed": The value of the variable is fixed after initialization, in other words, after fmi2ExitInitializationMode was called the variable value does not change anymore.
"tunable": The value of the variable is constant between external events (ModelExchange) and between Communication Points (Co-Simulation) due to changing variables with causality = "parameter" or "input" and variability = "tunable". Whenever a parameter or input signal with variability = "tunable" changes, an event is triggered externally (ModelExchange), or the change is performed at the next Communication Point (Co-Simulation) and the variables with variability = "tunable" and causality = "calculatedParameter" or "output" must be newly computed.
"discrete": ModelExchange: The value of the variable is constant between external and internal events (= time, state, step events defined implicitly in the FMU). Co-Simulation: By convention, the variable is from a “real” sampled data system and its value is only changed at Communication Points (also inside the slave).
"continuous": Only a variable of type = “Real” can be “continuous”. ModelExchange: No restrictions on value changes. Co-Simulation: By convention, the variable is from a differential
The default is “continuous”.
Added prefix "fmi2" to help with redefinition of constans in enums.
"""
const fmi2Variability = Cuint
const fmi2VariabilityConstant   = Cuint(0)
const fmi2VariabilityFixed      = Cuint(1)
const fmi2VariabilityTunable    = Cuint(2)
const fmi2VariabilityDiscrete   = Cuint(3)
const fmi2VariabilityContinuous = Cuint(4)

"""
Source: FMISpec2.0.2[p.48]: 2.2.7 Definition of Model Variables (ModelVariables)

Enumeration that defines how the variable is initialized. It is not allowed to provide a value for initial if causality = "input" or "independent":

"exact": The variable is initialized with the start value (provided under Real, Integer, Boolean, String or Enumeration).
"approx": The variable is an iteration variable of an algebraic loop and the iteration at initialization starts with the start value.
"calculated": The variable is calculated from other variables during initialization. It is not allowed to provide a “start” value.
If initial is not present, it is defined by the table below based on causality and variability. If initial = exact or approx, or causality = ″input″, a start value must be provided. If initial = calculated, or causality = ″independent″, it is not allowed to provide a start value.
If fmiSetXXX is not called on a variable with causality = ″input″, then the FMU must use the start value as value of this input.
Added prefix "fmi2" to help with redefinition of constans in enums.
"""
const fmi2Initial = Cuint
const fmi2InitialExact      = Cuint(0)
const fmi2InitialApprox     = Cuint(1)
const fmi2InitialCalculated = Cuint(2)

"""
Source: FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section.
All definitions in this section are provided in the header file “fmi2TypesPlatform.h”.
"""
const fmi2True = fmi2Boolean(true)
const fmi2False = fmi2Boolean(false)

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Argument fmuType defines the type of the FMU:
- fmi2ModelExchange: FMU with initialization and events; between events simulation of continuous systems is performed with external integrators from the environment.
- fmi2CoSimulation: Black box interface for co-simulation.
"""
const fmi2Type = Cuint
const fmi2TypeModelExchange = Cuint(0)
const fmi2TypeCoSimulation  = Cuint(1)

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionReal 
    # mandatory
    # (nothing)

    # optional
    declaredType::Union{String, Nothing}
    quantity::Union{String, Nothing}
    unit::Union{String, Nothing}
    displayUnit::Union{String, Nothing}
    relativeQuantity::Union{Bool, Nothing}
    min::Union{Real, Nothing}
    max::Union{Real, Nothing}
    nominal::Union{Real, Nothing}
    unbounded::Union{Bool, Nothing}
    start::Union{Real, Nothing}
    derivative::Union{UInt, Nothing}

    # constructor 
    function fmi2ModelDescriptionReal() 
        inst = new()

        inst.start = nothing
        inst.derivative = nothing
        inst.quantity = nothing
        inst.unit = nothing
        inst.displayUnit = nothing
        inst.relativeQuantity = nothing
        inst.min = nothing
        inst.max = nothing
        inst.nominal = nothing
        inst.unbounded = nothing
        inst.start = nothing
        inst.derivative = nothing

        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionInteger 
    # optional
    start::Union{fmi2Integer, Nothing}
    declaredType::Union{String, Nothing}
    # ToDo: remaining attributes
    
    # constructor 
    function fmi2ModelDescriptionInteger()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionBoolean 
    # optional
    start::Union{fmi2Boolean, Nothing}
    declaredType::Union{String, Nothing}
    # ToDo: remaining attributes
    
    # constructor 
    function fmi2ModelDescriptionBoolean()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionString
    # optional
    start::Union{String, Nothing}
    declaredType::Union{String, Nothing}
    # ToDo: remaining attributes
    
    # constructor 
    function fmi2ModelDescriptionString()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionEnumeration
    # mandatory 
    declaredType::Union{String, Nothing}

    # optional
    start::Union{fmi2Enum, Nothing}
    # ToDo: remaining attributes
    
    # constructor 
    function fmi2ModelDescriptionEnumeration() 
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

"""
Source: FMISpec2.0.2[p.46]: 2.2.7 Definition of Model Variables (ModelVariables)

The fmi2ScalarVariable specifies the type and argument of every exposed variable in the fmu
"""
mutable struct fmi2ScalarVariable
    # attributes (mandatory)
    name::String
    valueReference::fmi2ValueReference
    
    # attributes (optional)
    description::Union{String, Nothing}
    causality::Union{fmi2Causality, Nothing}
    variability::Union{fmi2Variability, Nothing}
    initial::Union{fmi2Initial, Nothing}
    canHandleMultipleSetPerTimeInstant::Union{fmi2Boolean, Nothing}
    annotations::Union{fmi2Annotation, Nothing}

    _Real::Union{fmi2ModelDescriptionReal, Nothing}
    _Integer::Union{fmi2ModelDescriptionInteger, Nothing}
    _Boolean::Union{fmi2ModelDescriptionBoolean, Nothing}
    _String::Union{fmi2ModelDescriptionString, Nothing}
    _Enumeration::Union{fmi2ModelDescriptionEnumeration, Nothing}

    # Constructor for not further specified ScalarVariables
    function fmi2ScalarVariable(name::String, valueReference::fmi2ValueReference, causality::Union{fmi2Causality, Nothing}, variability::Union{fmi2Variability, Nothing}, initial::Union{fmi2Initial, Nothing})
        inst = new()
        inst.name = name 
        inst.valueReference = valueReference
        inst.description = nothing  # ""
        inst.causality = causality
        if inst.causality == nothing    
            inst.causality = fmi2CausalityLocal # this is the default according FMI-spec p. 48
        end
        inst.variability = variability
        if inst.variability == nothing 
            inst.variability =  fmi2VariabilityContinuous   # this is the default according FMI-spec p. 49  
        end
        inst.initial = initial
        if inst.initial == nothing 
            # setting default value for initial  according FMI-spec p. 51
            if inst.causality != nothing && inst.variability != nothing
                if inst.causality == fmi2CausalityParameter
                    if inst.variability == fmi2VariabilityFixed || inst.variability == fmi2VariabilityTunable
                        inst.initial = fmi2InitialExact
                    else
                        @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                elseif inst.causality == fmi2CausalityCalculatedParameter
                    if inst.variability == fmi2VariabilityFixed || inst.variability == fmi2VariabilityTunable
                        inst.initial = fmi2InitialCalculated
                    else
                        @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                elseif inst.causality == fmi2CausalityInput
                    if inst.variability == fmi2VariabilityDiscrete || inst.variability == fmi2VariabilityContinuous
                        # everything allright, it's not allowed to define `initial` in this case
                    else
                        @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                elseif inst.causality == fmi2CausalityOutput
                    if inst.variability == fmi2VariabilityConstant
                        inst.initial = fmi2InitialExact
                    elseif inst.variability == fmi2VariabilityDiscrete || inst.variability == fmi2VariabilityContinuous
                        inst.initial = fmi2InitialCalculated
                    else
                        @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                elseif inst.causality == fmi2CausalityLocal
                    if inst.variability == fmi2VariabilityConstant
                        inst.initial = fmi2InitialExact
                    elseif inst.variability == fmi2VariabilityFixed || inst.variability == fmi2VariabilityTunable
                        inst.initial = fmi2InitialCalculated
                    elseif inst.variability == fmi2VariabilityDiscrete || inst.variability == fmi2VariabilityContinuous
                        inst.initial = fmi2InitialCalculated
                    else
                        @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                elseif inst.causality == fmi2CausalityIndependent
                    if inst.variability == fmi2VariabilityContinuous
                        # everything allright, it's not allowed to define `initial` in this case
                    else
                        @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                end
            else
                @warn "Causality: $(fmi2CausalityToString(inst.causality))   Variability: $(fmi2VariabilityToString(inst.variability))   Cannot pick default value for `initial` if one of them is `nothing`."
            end
        end

        inst.canHandleMultipleSetPerTimeInstant = nothing
        inst.annotations = nothing

        inst._Real = nothing 
        inst._Integer = nothing
        inst._Boolean = nothing
        inst._String = nothing 
        inst._Enumeration = nothing

        return inst
    end
end

""" 
Overload the Base.show() function for custom printing of the fmi2ScalarVariable.
"""
Base.show(io::IO, var::fmi2ScalarVariable) = print(io,
"Name: '$(var.name)' (reference: $(var.valueReference))")

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

CoSimulation specific Enum representing state of fmu after fmi2DoStep returned fmi2Pending.
"""
const fmi2StatusKind = Cuint
const fmi2StatusKindDoStepStatus        = Cuint(0)
const fmi2StatusKindPendingStatus       = Cuint(1)
const fmi2StatusKindLastSuccessfulTime  = Cuint(2)
const fmi2StatusKindTerminated          = Cuint(3)

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

If return argument fmi2eventInfo.newDiscreteStatesNeeded = fmi2True, the FMU should stay in Event Mode, and the FMU requires to set new inputs to the FMU (fmi2SetXXX on inputs) to compute and get the outputs (fmi2GetXXX on outputs) and to call fmi2NewDiscreteStates again. Depending on the connection with other FMUs, the environment shall
- call fmi2Terminate, if terminateSimulation = fmi2True is returned by at least one FMU.
- call fmi2EnterContinuousTimeMode if all FMUs return newDiscreteStatesNeeded = fmi2False.
- stay in Event Mode otherwise.
When the FMU is terminated, it is assumed that an appropriate message is printed by the logger function (see section 2.1.5) to explain the reason for the termination.
If nominalsOfContinuousStatesChanged = fmi2True, then the nominal values of the states have changed due to the function call and can be inquired with fmi2GetNominalsOfContinuousStates.
If valuesOfContinuousStatesChanged = fmi2True. then at least one element of the continuous state vector has changed its value due to the function call. The new values of the states can be retrieved with fmi2GetContinuousStates or individually for each state for which reinit = "true" by calling getReal. If no element of the continuous state vector has changed its value, valuesOfContinuousStatesChanged must return fmi2False. [If fmi2True would be returned in this case, an infinite event loop may occur.]
If nextEventTimeDefined = fmi2True, then the simulation shall integrate at most until time = nextEventTime, and shall call fmi2EnterEventMode at this time instant. If integration is stopped before nextEventTime, for example, due to a state event, the definition of nextEventTime becomes obsolete.
"""
mutable struct fmi2EventInfo
    newDiscreteStatesNeeded::fmi2Boolean
    terminateSimulation::fmi2Boolean
    nominalsOfContinuousStatesChanged::fmi2Boolean
    valuesOfContinuousStatesChanged::fmi2Boolean
    nextEventTimeDefined::fmi2Boolean
    nextEventTime::fmi2Real

    # constructor
    function fmi2EventInfo() 
        inst = new()
        inst.newDiscreteStatesNeeded = fmi2False
        inst.terminateSimulation = fmi2False
        inst.nominalsOfContinuousStatesChanged = fmi2False
        inst.valuesOfContinuousStatesChanged = fmi2False
        inst.nextEventTimeDefined = fmi2False
        inst.nextEventTime = 0.0
        return inst
    end
end

""" 
ToDo 
"""
mutable struct fmi2Unit
    # ToDo 
end

""" 
ToDo 
"""
mutable struct fmi2SimpleType
    # ToDo 
end

# Custom helper, not part of the FMI-Spec. 
const fmi2DependencyKind            = Cuint
const fmi2DependencyKindDependent   = Cuint(0)
const fmi2DependencyKindConstant    = Cuint(1)
const fmi2DependencyKindFixed       = Cuint(2)
const fmi2DependencyKindTunable     = Cuint(3)
const fmi2DependencyKindDiscrete    = Cuint(4)

# Custom helper, not part of the FMI-Spec. 
const fmi2VariableNamingConvention              = Cuint
const fmi2VariableNamingConventionFlat          = Cuint(0)
const fmi2VariableNamingConventionStructured    = Cuint(1)

""" 
ToDo 
"""
mutable struct fmi2VariableDependency
    # mandatory 
    index::UInt

    # optional
    dependencies::Union{Array{UInt, 1}, Nothing}
    dependenciesKind::Union{Array{fmi2DependencyKind, 1}, Nothing}

    # Constructor 
    function fmi2VariableDependency(index)
        inst = new()
        inst.index = index
        inst.dependencies = nothing
        inst.dependenciesKind = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionDefaultExperiment
    startTime::Union{Real,Nothing}
    stopTime::Union{Real,Nothing}
    tolerance::Union{Real,Nothing}
    stepSize::Union{Real,Nothing}

    # Constructor 
    function fmi2ModelDescriptionDefaultExperiment()
        inst = new()
        inst.startTime = nothing
        inst.stopTime = nothing
        inst.tolerance = nothing
        inst.stepSize = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec. 
fmi2Unknown = fmi2VariableDependency

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionModelStructure
    outputs::Union{Array{fmi2VariableDependency, 1}, Nothing}
    derivatives::Union{Array{fmi2VariableDependency, 1}, Nothing}
    initialUnknowns::Union{Array{fmi2Unknown, 1}, Nothing}

    # Constructor 
    function fmi2ModelDescriptionModelStructure()
        inst = new()
        inst.outputs = nothing
        inst.derivatives = nothing
        inst.initialUnknowns = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec.
mutable struct fmi2ModelDescriptionModelExchange
    # mandatory
    modelIdentifier::String

    # optional
    canGetAndSetFMUstate::Union{Bool, Nothing}
    canSerializeFMUstate::Union{Bool, Nothing}
    providesDirectionalDerivative::Union{Bool, Nothing}

    # ToDo: Further attributes 3.3.1

    # constructor 
    function fmi2ModelDescriptionModelExchange() 
        inst = new()
        return inst 
    end

    function fmi2ModelDescriptionModelExchange(modelIdentifier::String) 
        inst = fmi2ModelDescriptionModelExchange() 
        inst.modelIdentifier = modelIdentifier
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec.
mutable struct fmi2ModelDescriptionCoSimulation
    # mandatory
    modelIdentifier::String

    # optional
    canHandleVariableCommunicationStepSize::Union{Bool, Nothing}
    canInterpolateInputs::Union{Bool, Nothing}
    maxOutputDerivativeOrder::Union{UInt, Nothing}
    canGetAndSetFMUstate::Union{Bool, Nothing}
    canSerializeFMUstate::Union{Bool, Nothing}
    providesDirectionalDerivative::Union{Bool, Nothing}

    # ToDo: Further attributes 4.3.1

    # constructor 
    function fmi2ModelDescriptionCoSimulation() 
        inst = new()
        return inst 
    end

    function fmi2ModelDescriptionCoSimulation(modelIdentifier::String) 
        inst = fmi2ModelDescriptionCoSimulation()
        inst.modelIdentifier = modelIdentifier
        return inst 
    end
end

"""
Source: FMISpec2.0.2[p.34]: 2.2.1 Definition of an FMU (fmiModelDescription)

The “ModelVariables” element of fmiModelDescription is the central part of the model description. It provides the static information of all exposed variables.
"""
mutable struct fmi2ModelDescription 
    # attributes (mandatory)
    fmiVersion::String
    modelName::String
    guid # String gor Base.UUID

    # attributes (optional)
    description::Union{String, Nothing}
    author::Union{String, Nothing}
    version::Union{String, Nothing}
    copyright::Union{String, Nothing}
    license::Union{String, Nothing}
    generationTool::Union{String, Nothing}
    generationDateAndTime # DateTime
    variableNamingConvention::Union{fmi2VariableNamingConvention, Nothing}
    numberOfEventIndicators::Union{UInt, Nothing}

    unitDefinitions::Array{fmi2Unit, 1} 
    typeDefinitions::Array{fmi2SimpleType, 1} 
    logCategories::Array # ToDo: Array type

    defaultExperiment::Union{fmi2ModelDescriptionDefaultExperiment, Nothing}

    vendorAnnotations::Array # ToDo: Array type
    modelVariables::Array{fmi2ScalarVariable, 1} 
    modelStructure::fmi2ModelDescriptionModelStructure

    modelExchange::Union{fmi2ModelDescriptionModelExchange, Nothing}
    coSimulation::Union{fmi2ModelDescriptionCoSimulation, Nothing}

    # additionals
    valueReferences::Array{fmi2ValueReference}
    inputValueReferences::Array{fmi2ValueReference}
    outputValueReferences::Array{fmi2ValueReference}
    stateValueReferences::Array{fmi2ValueReference}
    derivativeValueReferences::Array{fmi2ValueReference}
    parameterValueReferences::Array{fmi2ValueReference}

    stringValueReferences::Dict{String, fmi2ValueReference}     # String-ValueReference pairs of MD

    # ToDo: from here on refactoring is needed

    enumerations::fmi2Enum

    # additional fields (non-FMI-specific)
    valueReferenceIndicies::Dict{UInt, UInt}

    # Constructor for uninitialized struct
    function fmi2ModelDescription()
        inst = new()
        inst.fmiVersion = ""
        inst.modelName = ""
        inst.guid = ""

        inst.modelExchange = nothing 
        inst.coSimulation = nothing
        inst.defaultExperiment = nothing

        inst.modelVariables = Array{fmi2ScalarVariable, 1}()
        inst.modelStructure = fmi2ModelDescriptionModelStructure()
        inst.numberOfEventIndicators = nothing
        inst.enumerations = []

        inst.valueReferences = []
        inst.inputValueReferences = []
        inst.outputValueReferences = []
        inst.stateValueReferences = []
        inst.derivativeValueReferences = []
        inst.parameterValueReferences = []

        return inst 
    end
end

""" 
Overload the Base.show() function for custom printing of the fmi2ModelDescription.
"""
Base.show(io::IO, desc::fmi2ModelDescription) = print(io,
"Model name:      $(desc.modelName)
FMI version:     $(desc.fmiVersion)
GUID:            $(desc.guid)
Description:     $(desc.description)
Model variables: [$(length(desc.modelVariables))]"
)

### FUNCTIONS ###

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function returns a new instance of an FMU.
"""
function fmi2Instantiate(cfunc::Ptr{Nothing},
                         instanceName::fmi2String,
                         fmuType::fmi2Type,
                         fmuGUID::fmi2String,
                         fmuResourceLocation::fmi2String,
                         functions::Ptr{fmi2CallbackFunctions},
                         visible::fmi2Boolean,
                         loggingOn::fmi2Boolean)

    status = ccall(cfunc,
          Ptr{Cvoid},
          (fmi2String, fmi2Type, fmi2String, fmi2String, Ptr{Cvoid}, fmi2Boolean, fmi2Boolean),
          instanceName, fmuType, fmuGUID, fmuResourceLocation, functions, visible, loggingOn)

    @debug "fmi2Instantiate(instanceName: $(instanceName), fmuType: $(fmuType), fmuGUID: $(fmuGUID), fmuResourceLocation: $(fmuResourceLocation), functions: $(functions), visible: $(visible), loggingOn: $(loggingOn)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Disposes the given instance, unloads the loaded model, and frees all the allocated memory and other resources that have been allocated by the functions of the FMU interface.
If a null pointer is provided for “c”, the function call is ignored (does not have an effect).

Removes the component from the FMUs component list.
"""
function fmi2FreeInstance!(cfunc::Ptr{Nothing}, c::fmi2Component)

    ccall(cfunc, Cvoid, (fmi2Component,), c)
    @debug "fmi2FreeInstance(c: $(c)) → [nothing]"
    return nothing
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the string to uniquely identify the “fmi2TypesPlatform.h” header file used for compilation of the functions of the FMU.
The standard header file, as documented in this specification, has fmi2TypesPlatform set to “default” (so this function usually returns “default”).
"""
function fmi2GetTypesPlatform(cfunc::Ptr{Nothing})
    str = ccall(cfunc, fmi2String, ())
    @debug "fmi2GetTypesPlatform() → $(str)"
    return str
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the version of the “fmi2Functions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0”
"""
function fmi2GetVersion(cfunc::Ptr{Nothing})
    str = ccall(cfunc, fmi2String, ())
    @debug "fmi2GetVersion() → $(str)"
    return str
end

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetDebugLogging(cfunc::Ptr{Nothing}, c::fmi2Component, logginOn::fmi2Boolean, nCategories::Csize_t, categories::Union{Ptr{fmi2String}, AbstractArray{fmi2String}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Component, Csize_t, Ptr{fmi2String}),
          c, logginOn, nCategories, categories)
    @debug "fmi2SetDebugLogging(c: $(c), logginOn: $(loggingOn), nCategories: $(nCategories), categories: $(categories)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to setup the experiment. This function must be called after fmi2Instantiate and before fmi2EnterInitializationMode is called.The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetupExperiment(cfunc::Ptr{Nothing}, 
                             c::fmi2Component,
                             toleranceDefined::fmi2Boolean,
                             tolerance::fmi2Real,
                             startTime::fmi2Real,
                             stopTimeDefined::fmi2Boolean,
                             stopTime::fmi2Real)

    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Boolean, fmi2Real, fmi2Real, fmi2Boolean, fmi2Real),
          c, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
    @debug "fmi2SetupExperiment(c: $(c), toleranceDefined: $(toleranceDefined), tolerance: $(tolerance), startTime: $(startTime), stopTimeDefined: $(stopTimeDefined), stopTime: $(stopTime)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <ScalarVariable initial = "exact" or "approx"> can be set with the “fmi2SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.2.7). Setting other variables is not allowed. Furthermore, fmi2SetupExperiment must be called at least once before calling fmi2EnterInitializationMode, in order that startTime is defined.
"""
function fmi2EnterInitializationMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2EnterInitializationMode(c: $(c)) → $(status)" 
    return status
end

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to exit Initialization Mode.
"""
function fmi2ExitInitializationMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2ExitInitializationMode(c: $(c)) → $(status)" 
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU that the simulation run is terminated.
"""
function fmi2Terminate(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc, 
          fmi2Status, 
          (fmi2Component,), 
          c)
    @debug "fmi2Terminate(c: $(c)) → $(status)" 
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi2Instantiate would have been called.
"""
function fmi2Reset(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc, 
          fmi2Status, 
          (fmi2Component,), 
          c)
    @debug "fmi2Reset(c: $(c)) → $(status)" 
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetReal!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}),
          c, vr, nvr, value)
    @debug "fmi2GetReal(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)" 
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetReal(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}),
          c, vr, nvr, value)
    @debug "fmi2SetReal(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value))"
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetInteger!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Integer}, Ptr{fmi2Integer}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}),
          c, vr, nvr, value)
    @debug "fmi2GetInteger(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetInteger(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Integer}, Ptr{fmi2Integer}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}),
          c, vr, nvr, value)
    @debug "fmi2SetInteger(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetBoolean!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Boolean}, Ptr{fmi2Boolean}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}),
          c, vr, nvr, value)
    @debug "fmi2GetBoolean(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetBoolean(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Boolean}, Ptr{fmi2Boolean}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}),
          c, vr, nvr, value)
    @debug "fmi2SetBoolean(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetString!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2String}, Ptr{fmi2String}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String}),
          c, vr, nvr, value)
    @debug "fmi2GetString(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetString(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2String}, Ptr{fmi2String}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String}),
          c, vr, nvr, value)
    @debug "fmi2SetString(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi2GetFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2FMUstate}),
          c, FMUstate)
    @debug "fmi2GetFMUstate!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi2SetFMUstate(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::fmi2FMUstate)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2FMUstate),
          c, FMUstate)
    @debug "fmi2SetFMUstate(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2FreeFMUstate frees all memory and other resources allocated with the fmi2GetFMUstate call for this FMUstate.
"""
function fmi2FreeFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2FMUstate}),
          c, FMUstate)
    @debug "fmi2FreeFMUstate!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializedFMUstateSize returns the size of the byte vector, in order that FMUstate can be stored in it.
"""
function fmi2SerializedFMUstateSize!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::fmi2FMUstate, size::Ref{Csize_t})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2FMUstate, Ptr{Csize_t}),
          c, FMUstate, size)
    @debug "fmi2SerializedFMUstateSize(c: $(c), FMUstate: $(FMUstate), size: $(size)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi2SerializeFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::fmi2FMUstate, serialzedState::AbstractArray{fmi2Byte}, size::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2FMUstate, Ptr{fmi2Byte}, Csize_t),
          c, FMUstate, serialzedState, size)
    @debug "fmi2SerializeFMUstate(c: $(c), FMUstate: $(FMUstate), serialzedState: $(serializedState), size: $(size)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi2DeSerializeFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, serializedState::AbstractArray{fmi2Byte}, size::Csize_t, FMUstate::Ref{fmi2FMUstate})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Byte}, Csize_t, Ptr{fmi2FMUstate}),
          c, serializedState, size, FMUstate)
    @debug "fmi2DeSerializeFMUstate(c: $(c), serializedState: $(serializedState), size: $(size), FMUstate: $(FMUstate)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.26]: 2.1.9 Getting Partial Derivatives

This function computes the directional derivatives of an FMU.

    ΔvUnknown = ∂h / ∂vKnown ⋅ ΔvKnown
"""
function fmi2GetDirectionalDerivative!(cfunc::Ptr{Nothing}, 
                                       c::fmi2Component,
                                       vUnknown_ref::AbstractArray{fmi2ValueReference},
                                       nUnknown::Csize_t,
                                       vKnown_ref::AbstractArray{fmi2ValueReference},
                                       nKnown::Csize_t,
                                       ΔvKnown::AbstractArray{fmi2Real},
                                       ΔvUnknown::AbstractArray{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}, Ptr{fmi2Real}),
          c, vUnknown_ref, nUnknown, vKnown_ref, nKnown, ΔvKnown, ΔvUnknown)
    @debug "fmi2GetDirectionalDerivative(c: $(c), vUnknown_ref: $(vUnknown_ref), nUnknown: $(nUnknown), vKnown_ref: $(vKnown_ref), nKnown: $(nKnown), ΔvKnown: $(ΔvKnown), ΔvUnknown: $(ΔvUnknown)) → $(status)"
    return status
end

# Functions specificly for isCoSimulation

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Sets the n-th time derivative of real input variables.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2SetRealInputDerivatives(cfunc::Ptr{Nothing}, c::fmi2Component, vr::AbstractArray{fmi2ValueReference}, nvr::Csize_t, order::AbstractArray{fmi2Integer}, value::AbstractArray{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}, Ptr{fmi2Real}),
          c, vr, nvr, order, value)
    @debug "fmi2SetRealInputDerivatives(c: $(c), vr: $(vr), nvr: $(nvr), order: $(order), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Retrieves the n-th derivative of output values.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2GetRealOutputDerivatives!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::AbstractArray{fmi2ValueReference}, nvr::Csize_t, order::AbstractArray{fmi2Integer}, value::AbstractArray{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}, Ptr{fmi2Real}),
          c, vr, nvr, order, value)
    @debug "fmi2GetRealOutputDerivatives(c: $(c), vr: $(vr), nvr: $(nvr), order: $(order), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.104]: 4.2.2 Computation

The computation of a time step is started.
"""
function fmi2DoStep(cfunc::Ptr{Nothing}, c::fmi2Component, currentCommunicationPoint::fmi2Real, communicationStepSize::fmi2Real, noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    status = ccall(cfunc, fmi2Status,
          (fmi2Component, fmi2Real, fmi2Real, fmi2Boolean),
          c, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint)
    @debug "fmi2DoStep(c: $(c), currentCommunicationPoint: $(currentCommunicationPoint), communicationStepSize: $(communicationStepSize), noSetFMUStatePriorToCurrentPoint: $(noSetFMUStatePriorToCurrentPoint)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.105]: 4.2.2 Computation

Can be called if fmi2DoStep returned fmi2Pending in order to stop the current asynchronous execution.
"""
function fmi2CancelStep(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc, 
          fmi2Status, 
          (fmi2Component,), 
          c)
    @debug "fmi2CancelStep(c: $(c)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Status})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Status}),
          c, s, value)
    @debug "fmi2GetStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetRealStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Real}),
          c, s, value)
    @debug "fmi2GetRealStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetIntegerStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Integer})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Integer}),
          c, s, value)
    @debug "fmi2GetIntegerStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetBooleanStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Boolean})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Boolean}),
          c, s, value)
    @debug "fmi2GetBooleanStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStringStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2String})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2String}),
          c, s, value)
    @debug "fmi2GetStringStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end

# Model Exchange specific Functions

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi2SetTime(cfunc::Ptr{Nothing}, c::fmi2Component, time::fmi2Real)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Real),
          c, time)
    @debug "fmi2SetTime(c: $(c), time: $(time)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi2SetContinuousStates(cfunc::Ptr{Nothing}, c::fmi2Component, x::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, nx::Csize_t)
    status = ccall(cfunc,
         fmi2Status,
         (fmi2Component, Ptr{fmi2Real}, Csize_t),
         c, x, nx)
    @debug "fmi2SetContinuousStates(c: $(c), x: $(x), nx: $(nx)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The model enters Event Mode from the Continuous-Time Mode and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi2EnterEventMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2EnterEventMode(c: $(c)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The FMU is in Event Mode and the super dense time is incremented by this call.
"""
function fmi2NewDiscreteStates!(cfunc::Ptr{Nothing}, c::fmi2Component, eventInfo::Ptr{fmi2EventInfo})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2EventInfo}),
          c, eventInfo)
    @debug "fmi2NewDiscreteStates(c: $(c), eventInfo: $(eventInfo)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi2EnterContinuousTimeMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2EnterContinuousTimeMode(c: $(c)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

This function must be called by the environment after every completed step of the integrator provided the capability flag completedIntegratorStepNotNeeded = false.
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated
"""
function fmi2CompletedIntegratorStep!(cfunc::Ptr{Nothing}, 
                                      c::fmi2Component,
                                      noSetFMUStatePriorToCurrentPoint::fmi2Boolean,
                                      enterEventMode::Ptr{fmi2Boolean},
                                      terminateSimulation::Ptr{fmi2Boolean})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Boolean, Ptr{fmi2Boolean}, Ptr{fmi2Boolean}),
          c, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation)
    @debug "fmi2CompletedIntegratorStep(c: $(c), noSetFMUStatePriorToCurrentPoint: $(noSetFMUStatePriorToCurrentPoint), enterEventMode: $(enterEventMode), terminateSimulation: $(terminateSimulation)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute state derivatives at the current time instant and for the current states.
"""
function fmi2GetDerivatives!(cfunc::Ptr{Nothing}, 
                            c::fmi2Component,
                            derivatives::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}},
                            nx::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, derivatives, nx)
    @debug "fmi2GetDerivatives(c: $(c), derivatives: $(derivatives), nx: $(nx)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute event indicators at the current time instant and for the current states.
"""
function fmi2GetEventIndicators!(cfunc::Ptr{Nothing}, c::fmi2Component, eventIndicators::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, ni::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, eventIndicators, ni)
    @debug "fmi2GetEventIndicators(c: $(c), eventIndicators: $(eventIndicators), ni: $(ni)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the new (continuous) state vector x.
"""
function fmi2GetContinuousStates!(cfunc::Ptr{Nothing}, c::fmi2Component,
                                 x::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}},
                                 nx::Csize_t)
    status = ccall(cfunc, 
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, x, nx)
    @debug "fmi2GetContinuousStates(c: $(c), x: $(x), nx: $(nx)) → $(status)"
    return status
end

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the nominal values of the continuous states.
"""
function fmi2GetNominalsOfContinuousStates!(cfunc::Ptr{Nothing}, c::fmi2Component, x_nominal::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, nx::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, x_nominal, nx)
    @debug "fmi2GetNominalsOfContinuousStates(c: $(c), x_nominal: $(x_nominal), nx: $(nx)) → $(status)"
    return status
end
