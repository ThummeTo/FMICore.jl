#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - fmi3xxx-structs and -functions from the FMI3-specification 
# - helper-structs that are not part of the FMI3-specification, but help to parse the model description nicely (e.g. `fmi3ModelDescriptionDefaultExperiment`, ...)

"""
Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions

To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section. 
All definitions in this section are provided in the header file fmi3PlatformTypes.h. It is required to use this definition for all binary FMUs.
"""
const fmi3Float32 = Cfloat
const fmi3Float64 = Cdouble
const fmi3Int8 = Cchar
const fmi3UInt8 = Cuchar
const fmi3Int16 = Cshort
const fmi3UInt16 = Cushort
const fmi3Int32 = Cint
const fmi3UInt32 = Cuint
const fmi3Int64 = Clonglong
const fmi3UInt64 = Culonglong
const fmi3Boolean = Cuchar
const fmi3Char = Cuchar     # changed to Cuchar to work with pointer function
const fmi3String = Ptr{fmi3Char}
const fmi3Byte = Cuchar
const fmi3Binary = Ptr{fmi3Byte}
const fmi3ValueReference = Cuint
const fmi3FMUState = Ptr{Cvoid}
const fmi3Instance = Ptr{Cvoid}
const fmi3InstanceEnvironment = Ptr{Cvoid}
const fmi3Enum = Array{Array{String}} # TODO: correct it
const fmi3Clock = Cint

const fmi3False = fmi3Boolean(false)
const fmi3True = fmi3Boolean(true)

"""
A not further specified annotation struct.
"""
mutable struct fmi3Annotation
    # No implementation
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
Defines the status flag (an enumeration of type fmi3Status defined in file fmi3FunctionTypes.h) that is returned by functions to indicate the success of the function call:
The status has the following meaning:
fmi3OK - The call was successful. The output argument values are defined.

fmi3Warning - A non-critical problem was detected, but the computation can continue. The output argument values are defined. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings.
[In certain applications, e.g. in a prototyping environment, warnings may be acceptable. For production environments warnings should be treated like errors unless they can be safely ignored.]

fmi3Discard - The call was not successful and the FMU is in the same state as before the call. The output argument values are not defined, but the computation can continue. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings. Advanced simulation algorithms can try alternative approaches to drive the simulation by calling the function with different arguments or calling another function. Otherwise the simulation algorithm has to treat this return code like fmi3Error and has to terminate the simulation.
[Examples for usage of fmi3Discard are handling of min/max violation, or signal numerical problems during model evaluation forcing smaller step sizes.]

fmi3Error - The call failed. The output argument values are undefined and the simulation cannot be continued. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings. If a function returns fmi3Error, it is possible to restore a previously retrieved FMU state by calling fmi3SetFMUState. Otherwise fmi3FreeInstance or fmi3Reset must be called. When detecting illegal arguments or a function call not allowed in the current state according to the respective state machine, the FMU must return fmi3Error. Other instances of this FMU are not affected by the error.

fmi3Fatal - The state of all instances of the model is irreparably corrupted. [For example, due to a runtime exception such as access violation or integer division by zero during the execution of an FMI function.] Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings, if still possible. It is not allowed to call any other function for any instance of the FMU.
"""
const fmi3Status          = Cuint
const fmi3StatusOK        = Cuint(0)
const fmi3StatusWarning   = Cuint(1)  
const fmi3StatusDiscard   = Cuint(2)
const fmi3StatusError     = Cuint(3)
const fmi3StatusFatal     = Cuint(4)

"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.7.4. Variable Attributes
Enumeration that defines the causality of the variable. Allowed values of this enumeration:

parameter - A data value that is constant during the simulation (except for tunable parameters, see there) and is provided by the environment and cannot be used in connections, except for parameter propagation in terminals as described in Section 2.4.9.2.6. variability must be fixed or tunable. These parameters can be changed independently, unlike calculated parameters. initial must be exact or not present (meaning exact).

calculatedParameter - A data value that is constant during the simulation and is computed during initialization or when tunable parameters change. variability must be fixed or tunable. initial must be approx, calculated or not present (meaning calculated).

input - The variable value can be provided by the importer. [For example, the importer could forward the output of another FMU into this input.]

output -  The variable value can be used by the importer. [For example, this value can be forwarded to an input of another FMU.]
The algebraic relationship to the inputs can be defined via the dependencies attribute of <fmiModelDescription><ModelStructure><Output>.

local -  Local variables are:
- continuous states and their ContinuousStateDerivatives, ClockedStates, EventIndicators or InitialUnknowns. These variables are listed in the <fmiModelDescription><ModelStructure>.
- internal, intermediate variables or local clocks which can be read for debugging purposes and are not listed in the <fmiModelDescription><ModelStructure>.
Setting of local variables:
- In Initialization Mode and before, local variables need to be set if they do have start values or are listed as <InitialUnknown>.
- In super state Initialized, fmi3Set{VariableType} must not be called on any of the local variables. Only in Model Exchange, continuous states can be set with fmi3SetContinuousStates. Local variable values must not be used as input to another model or FMU.

independent - The independent variable (usually time [but could also be, for example, angle]). All variables are a function of this independent variable. variability must be continuous. Exactly one variable of an FMU must be defined as independent. 
For Model Exchange the value is the last value set by fmi3SetTime. For Co-Simulation the value of the independent variable is lastSuccessfulTime return by the last call to fmi3DoStep or the value of argument intermediateUpdateTime of fmi3CallbackIntermediateUpdate. For Scheduled Execution the value of the independent variable is not defined. [The main purpose of this variable in Scheduled Execution is to define a quantity and unit for the independent variable.] The initial value of the independent variable is the value of the argument startTime of fmi3EnterInitializationMode for both Co-Simulation and Model Exchange. 
If the unit for the independent variable is not defined, it is implicitly s (seconds). If one variable is defined as independent, it must be defined with a floating point type without a start attribute. It is not allowed to call function fmi3Set{VariableType} on an independent variable. Instead, its value is initialized with fmi3EnterInitializationMode and after initialization set by fmi3SetTime for Model Exchange and by arguments currentCommunicationPoint and communicationStepSize of fmi3DoStep for Co-Simulation FMUs. [The actual value can be inquired with fmi3Get{VariableType}.]

structuralParameter - The variable value can only be changed in Configuration Mode or Reconfiguration Mode. The variability attribute must be fixed or tunable. The initial attribute must be exact or not present (meaning exact). The start attribute is mandatory. A structural parameter must not have a <Dimension> element. A structural parameter may be referenced in <Dimension> elements. If a structural parameters is referenced in <Dimension> elements, it must be of type <UInt64> and its start attribute must be larger than 0. The min attribute might still be 0.

The default of causality is local.
A continuous-time state or an event indicator must have causality = local or output, see also Section 2.4.8.

[causality = calculatedParameter and causality = local with variability = fixed or tunable are similar. The difference is that a calculatedParameter can be used in another model or FMU, whereas a local variable cannot. For example, when importing an FMU in a Modelica environment, a calculatedParameter should be imported in a public section as final parameter, whereas a local variable should be imported in a protected section of the model.]

The causality of variables of type Clock must be either input or output.

Added prefix "fmi3" to help with redefinition of constans in enums.
"""
const fmi3Causality                     = Cuint
const fmi3CausalityParameter            = Cuint(0)
const fmi3CausalityCalculatedParameter  = Cuint(1)
const fmi3CausalityInput                = Cuint(2)
const fmi3CausalityOutput               = Cuint(3)
const fmi3CausalityLocal                = Cuint(4)
const fmi3CausalityIndependent          = Cuint(5)
const fmi3CausalityStructuralParameter  = Cuint(6)

"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.7.4. Variable Attributes
Enumeration that defines the time dependency of the variable, in other words, it defines the time instants when a variable can change its value. [The purpose of this attribute is to define when a result value needs to be inquired and to be stored. For example, discrete variables change their values only at event instants (ME) or at a communication point (CS and SE) and it is therefore only necessary to inquire them with fmi3Get{VariableType} and store them at event times.] Allowed values of this enumeration:
constant - The value of the variable never changes.

fixed - The value of the variable is fixed after initialization, in other words, after fmi3ExitInitializationMode was called the variable value does not change anymore.

tunable - The value of the variable is constant between events (ME) and between communication points (CS and SE) due to changing variables with causality = parameter and variability = tunable. Whenever a parameter with variability = tunable changes, an event is triggered externally (ME or CS if events are supported), or the change is performed at the next communication point (CS and SE) and the variables with variability = tunable and causality = calculatedParameter or output must be newly computed. [tunable inputs are not allowed, see Table 18.]

discrete -
Model Exchange: The value of the variable is constant between external and internal events (= time, state, step events defined implicitly in the FMU).
Co-Simulation: By convention, the variable is from a real sampled data system and its value is only changed at communication points (including event handling). During intermediateUpdate, discrete variables are not allowed to change. [If the simulation algorithm notices a change in a discrete variable during intermediateUpdate, the simulation algorithm will delay the change, raise an event with earlyReturnRequested == fmi3True and during the communication point it can change the discrete variable, followed by event handling.]

continuous - Only a variable of type == fmi3GetFloat32 or type == fmi3GetFloat64 can be continuous.
Model Exchange: No restrictions on value changes (see Section 4.1.1).

The default is continuous for variables of type <Float32> and <Float64>, and discrete for all other types.

For variables of type Clock and clocked variables the variability is always discrete or tunable.

[Note that the information about continuous states is defined with elements <ContinuousStateDerivative> in <ModelStructure>.]

Added prefix "fmi3" to help with redefinition of constans in enums.
"""
const fmi3Variability             = Cuint
const fmi3VariabilityConstant     = Cuint(0)
const fmi3VariabilityFixed        = Cuint(1)
const fmi3VariabilityTunable      = Cuint(2)
const fmi3VariabilityDiscrete     = Cuint(3)
const fmi3VariabilityContinuous   = Cuint(4)

"""
Source: FMISpec3.0, Version D5ef1c1:2.4.7.5. Type specific properties
Enumeration that defines how the variable is initialized, i.e. if a fmi3Set{VariableType} is allowed and how the FMU internally treats this value in Instantiated and Initialization Mode.
For the variable with causality = independent, the attribute initial must not be provided, because its start value is set with the startTime parameter of fmi3EnterInitializationMode.

The attribute initial for other variables can have the following values and meanings:

exact - The variable is initialized with the start value (provided under the variable type element).

approx - The start value provides an approximation that may be modified during initialization, e.g., if the FMU is part of an algebraic loop where the variable might be an iteration variable and start value is taken as initial value for an iterative solution process.

calculated - The variable is calculated from other variables during initialization. It is not allowed to provide a start value.

If initial is not present, it is defined by Table 22 based on causality and variability. If initial = exact or approx, or causality = input, a start value must be provided. If initial = calculated, or causality = independent, it is not allowed to provide a start value.

[The environment decides when to use the start value of a variable with causality = input. Examples: * Automatic tests of FMUs are performed, and the FMU is tested by providing the start value as constant input. * For a Model Exchange FMU, the FMU might be part of an algebraic loop. If the input variable is iteration variable of this algebraic loop, then initialization starts with its start value.]

If fmi3Set{VariableType} is not called on a variable with causality = input, then the FMU must use the start value as value of this input.

Added prefix "fmi3" to help with redefinition of constans in enums.
"""
const fmi3Initial           = Cuint
const fmi3InitialExact      = Cuint(0)
const fmi3InitialApprox     = Cuint(1)
const fmi3InitialCalculated = Cuint(2)

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Argument fmuType defines the type of the FMU:
- fmi3ModelExchange: FMU with initialization and events; between events simulation of continuous systems is performed with external integrators from the environment.
- fmi3CoSimulation: Black box interface for co-simulation.
- fmi3ScheduledExecution: Concurrent computation of model partitions on a single computational resource (e.g. CPU-core)
"""
const fmi3Type                      = Cuint
const fmi3TypeModelExchange         = Cuint(0)
const fmi3TypeCoSimulation          = Cuint(1)
const fmi3TypeScheduledExecution    = Cuint(2)

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9.4. Scheduled Execution
Enumeration that defines the IntervalQualifiers which describe how to treat the intervals and intervalCounters arguments. They have the following meaning:
fmi3IntervalNotYetKnown -  is returned for a countdown aperiodic Clock for which the next interval is not yet known. This qualifier value can only be returned directly after the Clock was active and previous calls to fmi3GetInterval never returned fmi3IntervalChanged (nor fmi3IntervalUnchanged). In Scheduled Execution this return value means that the corresponding model partition cannot be scheduled yet.

fmi3IntervalUnchanged - is returned if a previous call to fmi3GetInterval already returned a value qualified with fmi3IntervalChanged which has not changed since. In Scheduled Execution this means the corresponding model partition has already been scheduled.

fmi3IntervalChanged - is returned to indicate that the value for the interval has changed for this Clock. Any previously returned intervals (if any) are overwritten with the current value. The new Clock interval is relative to the time of the current Event Mode or Clock Update Mode in contrast to the interval of a periodic Clock, where the interval is defined as the time between consecutive Clock ticks. In Scheduled Execution this means that the corresponding model partition has to be scheduled or re-scheduled (if a previous call to fmi3GetInterval returned fmi3IntervalChanged).
"""
const fmi3IntervalQualifier                     = Cuint
const fmi3IntervalQualifierIntervalNotYetKnown  = Cuint(0)
const fmi3IntervalQualifierIntervalUnchanged    = Cuint(1)
const fmi3IntervalQualifierIntervalChanged      = Cuint(2)

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

Enumeration that defines the dependencies a single unknown variable vunknown can have in relation to a known variable vknown. They have the following meaning:
dependent - no particular structure, f(.., v_{known,i}, ..)

Only for floating point type unknowns v_{unknown}:

constant - constant factor, c ⋅ v_{known,i} where c is an expression that is evaluated before fmi3EnterInitializationMode is called.

Only for floating point type unknowns v_{unknown} in Event and Continuous-Time Mode (ME) and at communication points (CS and SE), and not for <InitialUnknown> for Initialization Mode:

fixed - fixed factor, p⋅v_{known,i} where p is an expression that is evaluated before fmi3ExitInitializationMode is called.

tunable - tunable factor, p⋅v_{known,i} where p is an expression that is evaluated before fmi3ExitInitializationMode is called and in Event Mode due to event handling (ME) or at a communication point (CS and SE)

discrete - discrete factor, d⋅v_{known,i} where d is an expression that is evaluated before fmi3ExitInitializationMode is called and in Event Mode due to an external or internal event or at a communication point (CS and SE).
"""
const fmi3DependencyKind            = Cuint
const fmi3DependencyKindIndependent = Cuint(0)
const fmi3DependencyKindConstant    = Cuint(1)
const fmi3DependencyKindFixed       = Cuint(2)
const fmi3DependencyKindTunable     = Cuint(3)
const fmi3DependencyKindDiscrete    = Cuint(4)
const fmi3DependencyKindDependent   = Cuint(5)


"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.7.5.1. Variable Naming Conventions
"""
const fmi3VariableNamingConvention              = Cuint
const fmi3VariableNamingConventionFlat          = Cuint(0)
const fmi3VariableNamingConventionStructured    = Cuint(1)


""" 
ToDo 
"""
mutable struct fmi3VariableDependency
    # mandatory 
    reference::fmi3ValueReference

    # optional
    dependencies::Union{Array{fmi3ValueReference, 1}, Nothing}
    dependenciesKind::Union{Array{fmi3DependencyKind, 1}, Nothing}

    # Constructor 
    function fmi3VariableDependency(reference)
        inst = new()
        inst.reference = reference
        inst.dependencies = nothing
        inst.dependenciesKind = nothing
        return inst
    end
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.7. Definition of Model Variables
                                     2.4.4. Definition of Types

"""
mutable struct fmi3DatatypeVariable
    # mandatory 
    # TODO clock
    datatype::Union{Nothing, Type{fmi3String}, Type{fmi3Float64}, Type{fmi3Float32}, Type{fmi3Int8}, Type{fmi3UInt8}, Type{fmi3Int16}, Type{fmi3UInt16}, Type{fmi3Int32}, Type{fmi3UInt32}, Type{fmi3Int64}, Type{fmi3UInt64}, Type{fmi3Boolean}, Type{fmi3Binary}, Type{fmi3Char}, Type{fmi3Byte}, Type{fmi3Enum}}

    # Optional
    canHandleMultipleSet::Union{fmi3Boolean, Nothing}
    intermediateUpdate::fmi3Boolean
    previous::Union{fmi3UInt32, Nothing}
    clocks
    declaredType::Union{String, Nothing}
    start::Union{String, fmi3String, fmi3Float32, fmi3Float64, fmi3Int8, fmi3UInt8, fmi3Int16, fmi3UInt16, fmi3Int32, fmi3UInt32, fmi3Int64, fmi3UInt64, fmi3Boolean, fmi3Binary, fmi3Char, fmi3Byte, fmi3Enum, Array{fmi3Float32}, Array{fmi3Float64}, Array{fmi3Int32}, Array{fmi3UInt32}, Array{fmi3Int64}, Array{fmi3UInt64},  Nothing}
    min::Union{fmi3Float64,fmi3Int32, fmi3UInt32, fmi3Int64, Nothing}
    max::Union{fmi3Float64,fmi3Int32, fmi3UInt32, fmi3Int64, Nothing}
    initial::Union{fmi3Initial, Nothing}
    quantity::Union{String, Nothing}
    unit::Union{String, Nothing}
    displayUnit::Union{String, Nothing}
    relativeQuantity::Union{fmi3Boolean, Nothing}
    nominal::Union{fmi3Float64, Nothing}
    unbounded::Union{fmi3Boolean, Nothing}
    derivative::Union{fmi3UInt32, Nothing}
    reinit::Union{fmi3Boolean, Nothing}
    mimeType::Union{String, Nothing}
    maxSize::Union{fmi3UInt32, Nothing}

    # # used by Clocks TODO
    # canBeDeactivated::Union{fmi3Boolean, Nothing}
    # priority::Union{fmi3UInt32, Nothing}
    # intervall
    # intervallDecimal::Union{fmi3Float32, Nothing}
    # shiftDecimal::Union{fmi3Float32, Nothing}
    # supportsFraction::Union{fmi3Boolean, Nothing}
    # resolution::Union{fmi3UInt64, Nothing}
    # intervallCounter::Union{fmi3UInt64, Nothing}
    # shitftCounter::Union{fmi3Int32, Nothing}

    # additional (not in spec)
    unknownIndex::Integer 
    dependencies::Array{Integer}
    dependenciesValueReferences::Array{fmi3ValueReference}

    # Constructor
    fmi3DatatypeVariable() = new()
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionFloat 
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
     # constructor 
     function fmi3ModelDescriptionFloat() 
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
mutable struct fmi3ModelDescriptionInteger 
     # optional
     start::Union{fmi3Int32, Nothing}
     declaredType::Union{String, Nothing}
    
    # constructor 
    function fmi3ModelDescriptionInteger()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionBoolean 
    # optional
    start::Union{fmi3Boolean, Nothing}
    declaredType::Union{String, Nothing}
    # ToDo: remaining attributes
    
    # constructor 
    function fmi3ModelDescriptionBoolean()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionString
     # optional
     start::Union{String, Nothing}
     declaredType::Union{String, Nothing}
     # ToDo: remaining attributes
     
     # constructor 
     function fmi3ModelDescriptionString()
         inst = new()
         inst.start = nothing 
         return inst 
     end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionEnumeration
    # mandatory 
    declaredType::Union{String, Nothing}

    # optional
    start::Union{fmi3Enum, Nothing}
    # ToDo: remaining attributes
    
    # constructor 
    function fmi3ModelDescriptionEnumeration() 
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.7. Definition of Model Variables
                                     
A fmi3ModelVariable describes the the type, name, valueRefence and optional information for every variable in the Modeldescription.
"""
mutable struct fmi3ModelVariable
    #mandatory
    name::String
    valueReference::fmi3ValueReference
    datatype::fmi3DatatypeVariable

    # Optional
    description::Union{String, Nothing}

    causality::Union{fmi3Causality, Nothing}
    variability::Union{fmi3Variability, Nothing}
    initial::Union{fmi3Initial, Nothing}
    canHandleMultipleSetPerTimeInstant::Union{fmi3Boolean, Nothing}
    annotations::Union{fmi3Annotation, Nothing}
    clocks::Union{Array{fmi3ValueReference}, Nothing}

    # dependencies 
    dependencies #::Array{fmi3Int32}
    dependenciesKind #::Array{fmi3String}

    _Float::Union{fmi3ModelDescriptionFloat, Nothing}
    _Integer::Union{fmi3ModelDescriptionInteger, Nothing}
    _Boolean::Union{fmi3ModelDescriptionBoolean, Nothing}
    _String::Union{fmi3ModelDescriptionString, Nothing}
    _Enumeration::Union{fmi3ModelDescriptionEnumeration, Nothing}

    # Constructor for not further specified ModelVariable
    function fmi3ModelVariable(name::String, valueReference::fmi3ValueReference)
        inst = new()
        inst.name = name 
        inst.valueReference = valueReference
        inst.datatype = fmi3DatatypeVariable()
        inst.description = ""
        inst.causality = fmi3CausalityLocal
        inst.variability = fmi3VariabilityContinuous
        inst.initial = fmi3InitialCalculated
        inst.canHandleMultipleSetPerTimeInstant = fmi3False
        inst.clocks = nothing
        inst.annotations = nothing

        inst._Float = nothing 
        inst._Integer = nothing
        inst._Boolean = nothing
        inst._String = nothing 
        inst._Enumeration = nothing

        return inst
    end
    
end

""" 
ToDo 
"""
mutable struct fmi3Unit
    # ToDo 
end

""" 
ToDo 
"""
mutable struct fmi3SimpleType
    # ToDo 
end


# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionDefaultExperiment
    startTime::Union{Real,Nothing}
    stopTime::Union{Real,Nothing}
    tolerance::Union{Real,Nothing}
    stepSize::Union{Real,Nothing}

    # Constructor 
    function fmi3ModelDescriptionDefaultExperiment()
        inst = new()
        inst.startTime = nothing
        inst.stopTime = nothing
        inst.tolerance = nothing
        inst.stepSize = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionLogCategories
    name::String
    description::Union{String,Nothing}

    # Constructor 
    function fmi3ModelDescriptionLogCategories(name::String)
        inst = new()
        inst.name = name
        inst.description = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionClockType
    name::String
    description::Union{String,Nothing}
    canBeDeactivated::Union{Bool, Nothing}
    priority::Union{UInt, Nothing}
    intervalVariability # TODO type
    intervalDecimal::Union{Real, Nothing}
    shiftDecimal::Union{Real, Nothing}
    supportsFraction::Union{Bool, Nothing}
    resolution::Union{UInt64, Nothing}
    intervalCounter::Union{UInt64, Nothing}
    shiftCounter::Union{UInt64, Nothing}

    # Constructor 
    function fmi3ModelDescriptionClockType(name::String)
        inst = new()
        inst.name = name
        inst.description = nothing
        inst.canBeDeactivated = nothing
        inst.priority = nothing
        inst.intervallDecimal = nothing
        inst.shiftDecimal = nothing
        inst.supportsFraction = nothing
        inst.resolution = nothing
        inst.intervalCounter = nothing
        inst.shiftCounter = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec. 
fmi3Unknown = fmi3VariableDependency

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionModelStructure
    outputs::Union{Array{fmi3VariableDependency, 1}, Nothing}
    continuousStateDerivatives::Union{Array{fmi3VariableDependency, 1}, Nothing}
    clockedStates::Union{Array{fmi3VariableDependency, 1}, Nothing}
    initialUnknowns::Union{Array{fmi3Unknown, 1}, Nothing}
    eventIndicators::Union{Array{fmi3VariableDependency, 1}, Nothing}

    # Constructor 
    function fmi3ModelDescriptionModelStructure()
        inst = new()
        inst.outputs = nothing
        inst.continuousStateDerivatives = nothing
        inst.clockedStates = nothing
        inst.initialUnknowns = nothing
        inst.eventIndicators = nothing
        return inst
    end
end

# Custom helper, not part of the FMI-Spec.
mutable struct fmi3ModelDescriptionModelExchange
    # mandatory
    modelIdentifier::String

    # optional
    needsExecutionTool::Union{Bool, Nothing}
    canBeInstantiatedOnlyOncePerProcess::Union{Bool, Nothing}
    canGetAndSetFMUstate::Union{Bool, Nothing}
    canSerializeFMUstate::Union{Bool, Nothing}
    providesDirectionalDerivatives::Union{Bool, Nothing}
    providesAdjointDerivatives::Union{Bool, Nothing}
    providesPerElementDependencies::Union{Bool, Nothing}
    needsCompletedIntegratorStep::Union{Bool, Nothing}
    providesEvaluateDiscreteStates::Union{Bool, Nothing}

    # constructor 
    function fmi3ModelDescriptionModelExchange() 
        inst = new()
        return inst 
    end

    function fmi3ModelDescriptionModelExchange(modelIdentifier::String) 
        inst = fmi3ModelDescriptionModelExchange() 
        inst.modelIdentifier = modelIdentifier
        inst.needsExecutionTool = nothing
        inst.canBeInstantiatedOnlyOncePerProcess = nothing
        inst.canGetAndSetFMUstate = nothing
        inst.canSerializeFMUstate = nothing
        inst.providesDirectionalDerivatives = nothing
        inst.providesAdjointDerivatives = nothing
        inst.providesPerElementDependencies = nothing
        inst.needsCompletedIntegratorStep = nothing
        inst.providesEvaluateDiscreteStates = nothing
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec.
mutable struct fmi3ModelDescriptionCoSimulation
    # mandatory
    modelIdentifier::String

    # optional
    needsExecutionTool::Union{Bool, Nothing}
    canBeInstantiatedOnlyOncePerProcess::Union{Bool, Nothing}
    canGetAndSetFMUstate::Union{Bool, Nothing}
    canSerializeFMUstate::Union{Bool, Nothing}
    providesDirectionalDerivatives::Union{Bool, Nothing}
    providesAdjointDerivatives::Union{Bool, Nothing}
    providesPerElementDependencies::Union{Bool, Nothing}
    needsCompletedIntegratorStep::Union{Bool, Nothing}
    providesEvaluateDiscreteStates::Union{Bool, Nothing}
    canHandleVariableCommunicationStepSize::Union{Bool, Nothing}
    fixedInternalStepSize::Union{Real, Nothing}
    recommendedIntermediateInputSmoothness::Union{Int, Nothing}
    maxOutputDerivativeOrder::Union{UInt, Nothing}
    providesIntermediateUpdate::Union{Bool, Nothing}
    mightReturnEarlyFromDoStep::Union{Bool, Nothing}
    canReturnEarlyAfterIntermediateUpdate::Union{Bool, Nothing}
    hasEventMode::Union{Bool, Nothing}
    canInterpolateInputs::Union{Bool, Nothing}

    # constructor 
    function fmi3ModelDescriptionCoSimulation() 
        inst = new()
        return inst 
    end

    function fmi3ModelDescriptionCoSimulation(modelIdentifier::String) 
        inst = fmi3ModelDescriptionCoSimulation()
        inst.modelIdentifier = modelIdentifier
        inst.needsExecutionTool = nothing
        inst.canBeInstantiatedOnlyOncePerProcess = nothing
        inst.canGetAndSetFMUstate = nothing
        inst.canSerializeFMUstate = nothing
        inst.providesDirectionalDerivatives = nothing
        inst.providesAdjointDerivatives = nothing
        inst.providesPerElementDependencies = nothing
        inst.needsCompletedIntegratorStep = nothing
        inst.providesEvaluateDiscreteStates = nothing
        inst.needsCompletedIntegratorStep = nothing
        inst.canHandleVariableCommunicationStepSize = nothing
        inst.fixedInternalStepSize = nothing
        inst.recommendedIntermediateInputSmoothness = nothing
        inst.maxOutputDerivativeOrder = nothing
        inst.providesIntermediateUpdate = nothing
        inst.mightReturnEarlyFromDoStep = nothing
        inst.canReturnEarlyAfterIntermediateUpdate = nothing
        inst.hasEventMode = nothing
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec.
mutable struct fmi3ModelDescriptionScheduledExecution
    # mandatory
    modelIdentifier::String

    # optional
    needsExecutionTool::Union{Bool, Nothing}
    canBeInstantiatedOnlyOncePerProcess::Union{Bool, Nothing}
    canGetAndSetFMUstate::Union{Bool, Nothing}
    canSerializeFMUstate::Union{Bool, Nothing}
    providesDirectionalDerivatives::Union{Bool, Nothing}
    providesAdjointDerivatives::Union{Bool, Nothing}
    providesPerElementDependencies::Union{Bool, Nothing}

    # constructor 
    function fmi3ModelDescriptionScheduledExecution() 
        inst = new()
        return inst 
    end

    function fmi3ModelDescriptionScheduledExecution(modelIdentifier::String) 
        inst = fmi3ModelDescriptionScheduledExecution() 
        inst.modelIdentifier = modelIdentifier
        inst.needsExecutionTool = nothing
        inst.canBeInstantiatedOnlyOncePerProcess = nothing
        inst.canGetAndSetFMUstate = nothing
        inst.canSerializeFMUstate = nothing
        inst.providesDirectionalDerivatives = nothing
        inst.providesAdjointDerivatives = nothing
        inst.providesPerElementDependencies = nothing
        return inst 
    end
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.1. Definition of an FMU

The central FMU data structure defining all variables of the FMU that are visible/accessible via the FMU functions.
"""
mutable struct fmi3ModelDescription
    # FMI model description
    fmiVersion::String
    modelName::String
    instantiationToken::String  # replaces GUID

    # optional
    description::Union{String, Nothing}
    author::Union{String, Nothing}
    version::Union{String, Nothing}
    copyright::Union{String, Nothing}
    license::Union{String, Nothing}
    generationTool::Union{String, Nothing}
    generationDateAndTime # DateTime
    variableNamingConvention::Union{fmi3VariableNamingConvention, Nothing}

    unitDefinitions::Array{fmi3Unit, 1} 
    typeDefinitions::Array{fmi3SimpleType, 1} 
    logCategories::Array # ToDo: Array type

    defaultExperiment::Union{fmi3ModelDescriptionDefaultExperiment, Nothing}
    clockType::Union{fmi3ModelDescriptionClockType, Nothing}

    vendorAnnotations::Array # ToDo: Array type
    modelVariables::Array{fmi3ModelVariable, 1} 
    modelStructure::fmi3ModelDescriptionModelStructure

    modelExchange::Union{fmi3ModelDescriptionModelExchange, Nothing}
    coSimulation::Union{fmi3ModelDescriptionCoSimulation, Nothing}
    scheduledExecution::Union{fmi3ModelDescriptionScheduledExecution, Nothing}

    # additionals
    valueReferences::Array{fmi3ValueReference}
    inputValueReferences::Array{fmi3ValueReference}
    outputValueReferences::Array{fmi3ValueReference}
    stateValueReferences::Array{fmi3ValueReference}
    derivativeValueReferences::Array{fmi3ValueReference}
    intermediateUpdateValueReferences::Array{fmi3ValueReference}
    parameterValueReferences::Array{fmi3ValueReference}
    stringValueReferences::Dict{String, fmi3ValueReference}
 
    numberOfContinuousStates::Int
    numberOfEventIndicators::Union{UInt, Nothing}
    enumerations::fmi3Enum

    defaultStartTime::fmi3Float64
    defaultStopTime::fmi3Float64
    defaultTolerance::fmi3Float64

    # additional fields (non-FMI-specific)
    valueReferenceIndicies::Dict{Integer,Integer}

    # Constructor for uninitialized struct
    function fmi3ModelDescription()
        inst = new()
        inst.fmiVersion = ""
        inst.modelName = ""
        inst.instantiationToken = ""

        inst.modelExchange = nothing 
        inst.coSimulation = nothing
        inst.scheduledExecution = nothing
        inst.defaultExperiment = nothing
        inst.clockType = nothing

        inst.modelVariables = Array{fmi3ModelVariable, 1}()
        inst.modelStructure = fmi3ModelDescriptionModelStructure()
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
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

This function instantiates a Model Exchange FMU (see Section 3). It is allowed to call this function only if modelDescription.xml includes a <ModelExchange> element.
"""
function fmi3InstantiateModelExchange(cfunc::Ptr{Nothing},
        instanceName::fmi3String,
        fmuInstantiationToken::fmi3String,
        fmuResourceLocation::fmi3String,
        visible::fmi3Boolean,
        loggingOn::fmi3Boolean,
        instanceEnvironment::fmi3InstanceEnvironment,
        logMessage::Ptr{Cvoid})

    compAddr = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cuint, Cuint, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, fmuInstantiationToken, fmuResourceLocation,
        visible, loggingOn, instanceEnvironment, logMessage)

    compAddr
end

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

This function instantiates a Co-Simulation FMU (see Section 4). It is allowed to call this function only if modelDescription.xml includes a <CoSimulation> element.
"""
function fmi3InstantiateCoSimulation(cfunc::Ptr{Nothing},
    instanceName::fmi3String,
    instantiationToken::fmi3String,
    resourcePath::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    eventModeUsed::fmi3Boolean,
    earlyReturnAllowed::fmi3Boolean,
    requiredIntermediateVariables::Array{fmi3ValueReference},
    nRequiredIntermediateVariables::Csize_t,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    intermediateUpdate::Ptr{Cvoid})

    compAddr = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cint, Cint, Cint, Cint, Ptr{fmi3ValueReference}, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, instantiationToken, resourcePath,
        visible, loggingOn, eventModeUsed, earlyReturnAllowed, requiredIntermediateVariables,
        nRequiredIntermediateVariables, instanceEnvironment, logMessage, intermediateUpdate)

    compAddr
end

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

This function instantiates a Scheduled Execution FMU (see Section 4). It is allowed to call this function only if modelDescription.xml includes a <ScheduledExecution> element.
"""
function fmi3InstantiateScheduledExecution(cfunc::Ptr{Nothing},
    instanceName::fmi3String,
    instantiationToken::fmi3String,
    resourcePath::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    clockUpdate::Ptr{Cvoid},
    lockPreemption::Ptr{Cvoid},
    unlockPreemption::Ptr{Cvoid})
    @assert false "Not tested!"
    compAddr = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cint, Cint, Cint, Cint, Ptr{fmi3ValueReference}, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, instantiationToken, resourcePath,
        visible, loggingOn, eventModeUsed, earlyReturnAllowed, requiredIntermediateVariables,
        nRequiredIntermediateVariables, instanceEnvironment, logMessage, clockUpdate, lockPreemption, unlockPreemption)

    compAddr
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.4. Inquire Version Number of Header Files

This function returns fmi3Version of the fmi3Functions.h header file which was used to compile the functions of the FMU. This function call is allowed always and in all interface types.

The standard header file as documented in this specification has version "3.0-beta.2", so this function returns "3.0-beta.2".
"""
function fmi3GetVersion(cfunc::Ptr{Nothing})
    ccall(cfunc, fmi3String, ())
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Disposes the given instance, unloads the loaded model, and frees all the allocated memory and other resources that have been allocated by the functions of the FMU interface. If a NULL pointer is provided for argument instance, the function call is ignored (does not have an effect).
"""
function fmi3FreeInstance!(cfunc::Ptr{Nothing}, c::fmi3Instance)

    ccall(cfunc, Cvoid, (Ptr{Cvoid},), c)

    nothing
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi3True, debug logging is enabled, otherwise it is switched off.
"""
function fmi3SetDebugLogging(cfunc::Ptr{Nothing}, c::fmi3Instance, logginOn::fmi3Boolean, nCategories::UInt, categories::Ptr{Nothing})
    status = ccall(cfunc,
                   fmi3Status,
                   (fmi3Instance, Cint, Csize_t, Ptr{Nothing}),
                   c, logginOn, nCategories, categories)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <Datatype initial = "exact" or "approx"> can be set with the “fmi3SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.4.7). Setting other variables is not allowed.
Also sets the simulation start and stop time.
"""
function fmi3EnterInitializationMode(cfunc::Ptr{Nothing}, c::fmi3Instance, toleranceDefined::fmi3Boolean,
    tolerance::fmi3Float64,
    startTime::fmi3Float64,
    stopTimeDefined::fmi3Boolean,
    stopTime::fmi3Float64)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, fmi3Boolean, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Float64),
          c, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Informs the FMU to exit Initialization Mode.
"""
function fmi3ExitInitializationMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.4. Super State: Initialized

Informs the FMU that the simulation run is terminated.
"""
function fmi3Terminate(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc, fmi3Status, (fmi3Instance,), c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi3InstantiateXXX would have been called.
"""
function fmi3Reset(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc, fmi3Status, (fmi3Instance,), c)
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetFloat32!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float32}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float32}, Csize_t),
          c, vr, nvr, value, nvalue)
end


"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetFloat32(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float32}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float32}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetFloat64!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float64}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c, vr, nvr, value, nvalue)
end


"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetFloat64(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float64}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt8!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int8}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int8}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt8(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int8}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int8}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt8!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt8}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt8}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt8(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt8}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt8}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt16!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int16}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int16}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt16(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int16}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int16}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt16!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt16}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt16}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt16(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt16}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt16}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt32!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int32}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt32(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int32}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt32!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt32}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt32}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt32(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt32}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt32}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt64!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int64}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int64}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt64(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int64}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int64}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt64!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt64}, nvalue::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Csize_t),
          c, vr, nvr, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt64(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt64}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetBoolean!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Boolean}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Boolean}, Csize_t),
          c, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetBoolean(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Boolean}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Boolean}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

# TODO change to fmi3String when possible to test
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetString!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{Ptr{Cchar}}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t,  Ptr{Cchar}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""     
function fmi3SetString(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::Union{AbstractArray{Ptr{Cchar}}, AbstractArray{Ptr{UInt8}}}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{Cchar}, Csize_t),
                c, vr, nvr, value, nvalue)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValues - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetBinary!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, valueSizes::AbstractArray{Csize_t}, value::AbstractArray{fmi3Binary}, nvalue::Csize_t)
    ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{Csize_t}, Ptr{fmi3Binary}, Csize_t),
                c, vr, nvr, valueSizes, value, nvalue)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetBinary(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, valueSizes::AbstractArray{Csize_t}, value::AbstractArray{fmi3Binary}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{Csize_t}, Ptr{fmi3Binary}, Csize_t),
                c, vr, nvr, valueSizes, value, nvalue)
    status
end

# TODO, Clocks not implemented so far thus not tested
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetClock!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Clock})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t,  Ptr{fmi3Clock}),
                c, vr, nvr, value)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetClock(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Clock})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Clock}),
                c, vr, nvr, value)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi3GetFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::Ref{fmi3FMUState})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3FMUState}),
                c, FMUstate)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi3SetFMUState(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::fmi3FMUState)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3FMUState),
                c, FMUstate)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3FreeFMUstate frees all memory and other resources allocated with the fmi3GetFMUstate call for this FMUstate.
"""
function fmi3FreeFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::Ref{fmi3FMUState})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3FMUState}),
                c, FMUstate)
    status
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3SerializedFMUstateSize returns the size of the byte vector which is needed to store FMUstate in it.
"""
function fmi3SerializedFMUStateSize!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::fmi3FMUState, size::Ref{Csize_t})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{Cvoid}, Ptr{Csize_t}),
                c, FMUstate, size)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi3SerializeFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::fmi3FMUState, serialzedState::AbstractArray{fmi3Byte}, size::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{Cvoid}, Ptr{Cchar}, Csize_t),
                c, FMUstate, serialzedState, size)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi3DeSerializeFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, serialzedState::AbstractArray{fmi3Byte}, size::Csize_t, FMUstate::Ref{fmi3FMUState})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{Cchar}, Csize_t, Ptr{fmi3FMUState}),
                c, serialzedState, size, FMUstate)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3SetIntervalDecimal sets the interval until the next clock tick
"""
# TODO: Clocks and dependencies functions
# ToDo: Function is untested!
function fmi3SetIntervalDecimal(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervals::AbstractArray{fmi3Float64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}),
                c, vr, nvr, intervals)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3SetIntervalFraction sets the interval until the next clock tick
Only allowed if the attribute 'supportsFraction' is set.
"""
# ToDo: Function is untested!
function fmi3SetIntervalFraction(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervalCounters::AbstractArray{fmi3UInt64}, resolutions::AbstractArray{fmi3UInt64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Ptr{fmi3UInt64}),
                c, vr, nvr, intervalCounters, resolutions)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetIntervalDecimal retrieves the interval until the next clock tick.

For input Clocks it is allowed to call this function to query the next activation interval.
For changing aperiodic Clock, this function must be called in every Event Mode where this clock was activated.
For countdown aperiodic Clock, this function must be called in every Event Mode.
Clock intervals are computed in fmi3UpdateDiscreteStates (at the latest), therefore, this function should be called after fmi3UpdateDiscreteStates.
For information about fmi3IntervalQualifiers, call ?fmi3IntervalQualifier
"""
# ToDo: Function is untested!
function fmi3GetIntervalDecimal!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervals::AbstractArray{fmi3Float64}, qualifiers::fmi3IntervalQualifier)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Ptr{fmi3IntervalQualifier}),
                c, vr, nvr, intervals, qualifiers)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetIntervalFraction retrieves the interval until the next clock tick.

For input Clocks it is allowed to call this function to query the next activation interval.
For changing aperiodic Clock, this function must be called in every Event Mode where this clock was activated.
For countdown aperiodic Clock, this function must be called in every Event Mode.
Clock intervals are computed in fmi3UpdateDiscreteStates (at the latest), therefore, this function should be called after fmi3UpdateDiscreteStates.
For information about fmi3IntervalQualifiers, call ?fmi3IntervalQualifier
"""
# ToDo: Function is untested!
function fmi3GetIntervalFraction!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervalCounters::AbstractArray{fmi3UInt64}, resolutions::AbstractArray{fmi3UInt64}, qualifiers::fmi3IntervalQualifier)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Ptr{fmi3UInt64}, Ptr{fmi3IntervalQualifier}),
                c, vr, nvr, intervalCounters, resolutions, qualifiers)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetShiftDecimal retrieves the delay to the first Clock tick from the FMU.
"""
# ToDo: Function is untested!
function fmi3GetShiftDecimal!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, shifts::AbstractArray{fmi3Float64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}),
                c, vr, nvr, shifts)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetShiftFraction retrieves the delay to the first Clock tick from the FMU.
"""
# ToDo: Function is untested!
function fmi3GetShiftFraction!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, shiftCounters::AbstractArray{fmi3UInt64}, resolutions::AbstractArray{fmi3UInt64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Ptr{fmi3UInt64}),
                c, vr, nvr, shiftCounters, resolutions)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 5.2.2. State: Clock Activation Mode

During Clock Activation Mode (see 5.2.2.) after fmi3ActivateModelPartition has been called for a calculated, tunable or changing Clock the FMU provides the information on when the Clock will tick again, i.e. when the corresponding model partition has to be scheduled the next time.

Each fmi3ActivateModelPartition call is associated with the computation of an exposed model partition of the FMU and therefore to an input Clock.
"""
# ToDo: Function is untested!
function fmi3ActivateModelPartition(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::fmi3ValueReference, activationTime::AbstractArray{fmi3Float64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3ValueReference, Ptr{fmi3Float64}),
                c, vr, activationTime)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The number of dependencies of a given variable, which may change if structural parameters are changed, can be retrieved by calling fmi3GetNumberOfVariableDependencies.

This information can only be retrieved if the 'providesPerElementDependencies' tag in the ModelDescription is set.
"""
# ToDo: Function is untested!
function fmi3GetNumberOfVariableDependencies!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::fmi3ValueReference, nvr::Ref{Csize_t})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3ValueReference, Ptr{Csize_t}),
                c, vr, nvr)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The actual dependencies (of type dependenciesKind) can be retrieved by calling the function fmi3GetVariableDependencies:

dependent - specifies the valueReference of the variable for which the dependencies should be returned.

nDependencies - specifies the number of dependencies that the calling environment allocated space for in the result buffers, and should correspond to value obtained by calling fmi3GetNumberOfVariableDependencies.

elementIndicesOfDependent - must point to a buffer of size_t values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the element index of the dependent variable that dependency information is provided for. The element indices start with 1. Using the element index 0 means all elements of the variable. (Note: If an array has more than one dimension the indices are serialized in the same order as defined for values in Section 2.2.6.1.)

independents -  must point to a buffer of fmi3ValueReference values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the value reference of the independent variable that this dependency entry is dependent upon.

elementIndicesIndependents - must point to a buffer of size_t values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the element index of the independent variable that this dependency entry is dependent upon. The element indices start with 1. Using the element index 0 means all elements of the variable. (Note: If an array has more than one dimension the indices are serialized in the same order as defined for values in Section 2.2.6.1.)

dependencyKinds - must point to a buffer of dependenciesKind values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the enumeration value describing the dependency of this dependency entry.
For more information about dependenciesKinds, call ?fmi3DependencyKind

If this function is called before the fmi3ExitInitializationMode call, it returns the initial dependencies. If this function is called after the fmi3ExitInitializationMode call, it returns the runtime dependencies. 
The retrieved dependency information of one variable becomes invalid as soon as a structural parameter linked to the variable or to any of its depending variables are set. As a consequence, if you change structural parameters affecting B or A, the dependency of B becomes invalid. The dependency information must change only if structural parameters are changed.

This information can only be retrieved if the 'providesPerElementDependencies' tag in the ModelDescription is set.
"""
# ToDo: Function is untested!
function fmi3GetVariableDependencies!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::fmi3ValueReference, elementIndiceOfDependents::AbstractArray{Csize_t}, independents::AbstractArray{fmi3ValueReference},  elementIndiceOfInpendents::AbstractArray{Csize_t}, dependencyKind::AbstractArray{fmi3DependencyKind}, ndependencies::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3ValueReference, Ptr{Csize_t}, Ptr{fmi3ValueReference}, Ptr{Csize_t}, Ptr{fmi3DependencyKind}, Csize_t),
                c, vr, elementIndiceOfDependents, independents, elementIndiceOfInpendents, dependencyKind, ndependencies)
end

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

This function computes the directional derivatives v_{sensitivity} = J ⋅ v_{seed} of an FMU.

unknowns - contains value references to the unknowns.

nUnknowns - contains the length of argument unknowns.

knowns - contains value references of the knowns.

nKnowns - contains the length of argument knowns.

seed - contains the components of the seed vector.

nSeed - contains the length of seed.

sensitivity - contains the components of the sensitivity vector.

nSensitivity - contains the length of sensitivity.

This function can only be called if the 'ProvidesDirectionalDerivatives' tag in the ModelDescription is set.
"""
function fmi3GetDirectionalDerivative!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                       unknowns::AbstractArray{fmi3ValueReference},
                                       nUnknowns::Csize_t,
                                       knowns::AbstractArray{fmi3ValueReference},
                                       nKnowns::Csize_t,
                                       seed::AbstractArray{fmi3Float64},
                                       nSeed::Csize_t,
                                       sensitivity::AbstractArray{fmi3Float64},
                                       nSensitivity::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c, unknowns, nUnknowns, knowns, nKnowns, seed, nSeed, sensitivity, nSensitivity)
    
end

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

This function computes the adjoint derivatives v^T_{sensitivity}= v^T_{seed} ⋅ J of an FMU.

unknowns - contains value references to the unknowns.

nUnknowns - contains the length of argument unknowns.

knowns - contains value references of the knowns.

nKnowns - contains the length of argument knowns.

seed - contains the components of the seed vector.

nSeed - contains the length of seed.

sensitivity - contains the components of the sensitivity vector.

nSensitivity - contains the length of sensitivity.

This function can only be called if the 'ProvidesAdjointDerivatives' tag in the ModelDescription is set.
"""
function fmi3GetAdjointDerivative!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                       unknowns::AbstractArray{fmi3ValueReference},
                                       nUnknowns::Csize_t,
                                       knowns::AbstractArray{fmi3ValueReference},
                                       nKnowns::Csize_t,
                                       seed::AbstractArray{fmi3Float64},
                                       nSeed::Csize_t,
                                       sensitivity::AbstractArray{fmi3Float64},
                                       nSensitivity::Csize_t)
    @assert fmi3ProvidesAdjointDerivatives(c.fmu) ["fmi3GetAdjointDerivative!(...): This FMU does not support build-in adjoint derivatives!"]
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c, unknowns, nUnknowns, knowns, nKnowns, seed, nSeed, sensitivity, nSensitivity)
    
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.12. Getting Derivatives of Continuous Outputs

Retrieves the n-th derivative of output values.

valueReferences - is a vector of value references that define the variables whose derivatives shall be retrieved. If multiple derivatives of a variable shall be retrieved, list the value reference multiple times.

nValueReferences - is the dimension of the arguments valueReferences and orders.

orders - contains the orders of the respective derivative (1 means the first derivative, 2 means the second derivative, …, 0 is not allowed). 
If multiple derivatives of a variable shall be retrieved, provide a list of them in the orders array, corresponding to a multiply occurring value reference in the valueReferences array.
The highest order of derivatives retrievable can be determined by the 'maxOutputDerivativeOrder' tag in the ModelDescription.

values - is a vector with the values of the derivatives. The order of the values elements is derived from a twofold serialization: the outer level corresponds to the combination of a value reference (e.g., valueReferences[k]) and order (e.g., orders[k]), and the inner level to the serialization of variables as defined in Section 2.2.6.1. The inner level does not exist for scalar variables.

nValues - is the size of the argument values. nValues only equals nValueReferences if all corresponding output variables are scalar variables.
"""
function fmi3GetOutputDerivatives!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nValueReferences::Csize_t, order::AbstractArray{fmi3Int32}, values::AbstractArray{fmi3Float64}, nValues::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Ptr{fmi3Float64}, Csize_t),
                c, vr, nValueReferences, order, values, nValues)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

If the importer needs to change structural parameters, it must move the FMU into Configuration Mode using fmi3EnterConfigurationMode.
"""
function fmi3EnterConfigurationMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance,),
            c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.6. State: Configuration Mode

Exits the Configuration Mode and returns to state Instantiated.
"""
function fmi3ExitConfigurationMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of continuous states.
This function can only be called in Model Exchange. 

fmi3GetNumberOfContinuousStates must be called after a structural parameter is changed. As long as no structural parameters changed, the number of states is given in the modelDescription.xml, alleviating the need to call this function.
"""
function fmi3GetNumberOfContinuousStates!(cfunc::Ptr{Nothing}, c::fmi3Instance, nContinuousStates::Ref{Csize_t})
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{Csize_t}),
            c, nContinuousStates)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of event indicators.
This function can only be called in Model Exchange. 

fmi3GetNumberOfEventIndicators must be called after a structural parameter is changed. As long as no structural parameters changed, the number of states is given in the modelDescription.xml, alleviating the need to call this function.
"""
function fmi3GetNumberOfEventIndicators!(cfunc::Ptr{Nothing}, c::fmi3Instance, nEventIndicators::Ref{Csize_t})
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{Csize_t}),
            c, nEventIndicators)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the states at the current time instant.

This function must be called if fmi3UpdateDiscreteStates returned with valuesOfContinuousStatesChanged == fmi3True. Not allowed in Co-Simulation and Scheduled Execution.
"""
function fmi3GetContinuousStates!(cfunc::Ptr{Nothing}, c::fmi3Instance, nominals::AbstractArray{fmi3Float64}, nContinuousStates::Csize_t)
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
            c, nominals, nContinuousStates)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the nominal values of the continuous states.

If fmi3UpdateDiscreteStates returned with nominalsOfContinuousStatesChanged == fmi3True, then at least one nominal value of the states has changed and can be inquired with fmi3GetNominalsOfContinuousStates.
Not allowed in Co-Simulation and Scheduled Execution.
"""
function fmi3GetNominalsOfContinuousStates!(cfunc::Ptr{Nothing}, c::fmi3Instance, x_nominal::AbstractArray{fmi3Float64}, nx::Csize_t)
    status = ccall(cfunc,
                    fmi3Status,
                    (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
                    c, x_nominal, nx)
end

# TODO not testable not supported by FMU
"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

This function is called to trigger the evaluation of fdisc to compute the current values of discrete states from previous values. 
The FMU signals the support of fmi3EvaluateDiscreteStates via the capability flag providesEvaluateDiscreteStates.
"""
function fmi3EvaluateDiscreteStates(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance,),
            c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function is called to signal a converged solution at the current super-dense time instant. fmi3UpdateDiscreteStates must be called at least once per super-dense time instant.
"""
function fmi3UpdateDiscreteStates(cfunc::Ptr{Nothing}, c::fmi3Instance, discreteStatesNeedUpdate::Ref{fmi3Boolean}, terminateSimulation::Ref{fmi3Boolean}, 
                                    nominalsOfContinuousStatesChanged::Ref{fmi3Boolean}, valuesOfContinuousStatesChanged::Ref{fmi3Boolean},
                                    nextEventTimeDefined::Ref{fmi3Boolean}, nextEventTime::Ref{fmi3Float64})
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Float64}),
            c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi3EnterContinuousTimeMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function must be called to change from Event Mode into Step Mode in Co-Simulation (see 4.2.).
"""
function fmi3EnterStepMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi3SetTime(cfunc::Ptr{Nothing}, c::fmi3Instance, time::fmi3Float64)
    c.t = time
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, fmi3Float64),
          c, time)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi3SetContinuousStates(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                 x::AbstractArray{fmi3Float64},
                                 nx::Csize_t)
    ccall(cfunc,
         fmi3Status,
         (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
         c, x, nx)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Compute first-oder state derivatives at the current time instant and for the current states.
"""
function fmi3GetContinuousStateDerivatives(cfunc::Ptr{Nothing}, c::fmi3Instance,
                            derivatives::AbstractArray{fmi3Float64},
                            nx::Csize_t)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
          c, derivatives, nx)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Compute event indicators at the current time instant and for the current states. EventIndicators signal Events by their sign change.
"""
function fmi3GetEventIndicators!(cfunc::Ptr{Nothing}, c::fmi3Instance, eventIndicators::AbstractArray{fmi3Float64}, ni::Csize_t)
    status = ccall(cfunc,
                    fmi3Status,
                    (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
                    c, eventIndicators, ni)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

This function must be called by the environment after every completed step of the integrator provided the capability flag needsCompletedIntegratorStep = true.
If enterEventMode == fmi3True, the event mode must be entered
If terminateSimulation == fmi3True, the simulation shall be terminated
"""
function fmi3CompletedIntegratorStep!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                      noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
                                      enterEventMode::Ref{fmi3Boolean},
                                      terminateSimulation::Ref{fmi3Boolean})
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}),
          c, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

The model enters Event Mode from the Continuous-Time Mode in ModelExchange oder Step Mode in CoSimulation and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi3EnterEventMode(cfunc::Ptr{Nothing}, c::fmi3Instance, stepEvent::fmi3Boolean, stateEvent::fmi3Boolean, rootsFound::AbstractArray{fmi3Int32}, nEventIndicators::Csize_t, timeEvent::fmi3Boolean)
    ccall(cfunc,
          fmi3Status,
          (fmi3Instance,fmi3Boolean, fmi3Boolean, Ptr{fmi3Int32}, Csize_t, fmi3Boolean),
          c, stepEvent, stateEvent, rootsFound, nEventIndicators, timeEvent)
end

"""
Source: FMISpec3.0, Version D5ef1c1: 4.2.1. State: Step Mode

The computation of a time step is started.
"""
function fmi3DoStep!(cfunc::Ptr{Nothing}, c::fmi3Instance, currentCommunicationPoint::fmi3Float64, communicationStepSize::fmi3Float64, noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
                    eventEncountered::Ref{fmi3Boolean}, terminateSimulation::Ref{fmi3Boolean}, earlyReturn::Ref{fmi3Boolean}, lastSuccessfulTime::Ref{fmi3Float64})
    @assert cfunc != C_NULL ["fmi3DoStep(...): This FMU does not support fmi3DoStep, probably it's a ME-FMU with no CS-support?"]

    ccall(cfunc, fmi3Status,
          (fmi3Instance, fmi3Float64, fmi3Float64, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Float64}),
          c, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
end

""" Overload the Base.show() function for custom printing of the fmi3ModelDescription"""
Base.show(io::IO, desc::fmi3ModelDescription) = print(io,
"Model name:     $(desc.modelName)
FMI version:     $(desc.fmiVersion)
GUID:            $(desc.instantiationToken)
Description:     $(desc.description)
Model variables: $(desc.modelVariables)"
)
