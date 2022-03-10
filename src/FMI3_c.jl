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
const fmi3Char = Cchar
const fmi3String = Ptr{fmi2Char}
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
    start::Union{String, Nothing}
    derivative::Union{UInt, Nothing}

    # constructor 
    fmi3ModelDescriptionReal() = new()
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionInteger 
    # optional
    start::Union{String, Nothing}
    
    # constructor 
    fmi3ModelDescriptionInteger() = new()
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionBoolean 
    # optional
    start::Union{String, Nothing}
    
    # constructor 
    fmi3ModelDescriptionBoolean() = new()
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionString
    # optional
    start::Union{String, Nothing}
    
    # constructor 
    fmi3ModelDescriptionString() = new()
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi3ModelDescriptionEnumeration
    # optional
    start::Union{String, Nothing}

    
    # constructor 
    fmi3ModelDescriptionEnumeration() = new()
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
    description::Union{String, nothing}

    causality::Union{fmi3Causality, Nothing}
    variability::Union{fmi3Variability, Nothing}
    initial::Union{fmi3Initial, nothing}
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
    # Constructor for not further specified Model variable
    # function fmi3ModelVariable(name::String, valueReference::fmi3ValueReference)
    #     new(name, valueReference, fmi3DatatypeVariable(), "", fmi3CausalityLocal::fmi3Causality, fmi3VariabilityContinuous::fmi3Variability)
    # end

    # # Constructor for fully specified Model Variable
    # function fmi3ModelVariable(name::String, valueReference::fmi3ValueReference, type, description, causalityString, variabilityString, dependencies, dependenciesKind)
    #     var = fmi3VariabilityDiscrete::fmi3Variability
    #     if type.datatype == fmi3Float32 || type.datatype == fmi3Float64
    #         var = fmi3VariabilityContinuous::fmi3Variability
    #     end
    #     cau = fmi3CausalityLocal::fmi3Causality
        
    #     # if !occursin("fmi3" * variabilityString, string(instances(fmi3Variability)))
    #     #     display("Error: variability not known")
    #     # else
    #     #     for i in 0:(length(instances(fmi3Variability))-1)
    #     #         if "fmi3" * variabilityString == string(fmi3Variability(i))
    #     #             var = fmi3Variability(i)
    #     #         end
    #     #     end
    #     # end

    #     # if !occursin("fmi3" * causalityString, string(instances(fmi3Causality)))
    #     #     display("Error: causalitiy not known")
    #     # else
    #     #     for i in 0:(length(instances(fmi3Causality))-1)
    #     #         if "fmi3" * causalityString == string(fmi3Causality(i))
    #     #             cau = fmi3Causality(i)
    #     #         end
    #     #     end
    #     # end

    #     new(name, valueReference, type, description, cau, var, dependencies, dependenciesKind)
    # end
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

""" 
ToDo 
"""
mutable struct fmi3VariableDependency
    # mandatory 
    index::UInt

    # optional
    dependencies::Union{Array{UInt, 1}, Nothing}
    dependenciesKind::Union{Array{fmi3DependencyKind, 1}, Nothing}

    # Constructor 
    function fmi3VariableDependency(index)
        inst = new()
        inst.index = index
        inst.dependencies = nothing
        inst.dependenciesKind = nothing
        return inst
    end
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
    function fmi2ModelDescriptionModelStructure()
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
    variableNamingConvention::Union{fmi2VariableNamingConvention, Nothing}

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
    scheduledExecution::Union{fmi3ModelDescriptionScheduledExecution}

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
    numberOfEventIndicators::Int
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
        inst.guid = ""

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

