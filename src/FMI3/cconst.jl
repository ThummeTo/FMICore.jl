#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    fmi3Float32 (alias for Cfloat)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Float32 = Cfloat
export fmi3Float32

"""
    fmi3Float64 (alias for Cdouble)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Float64 = Cdouble
export fmi3Float64

"""
    fmi3Int8 (alias for Cchar)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Int8 = Cchar # = int8_t
export fmi3Int8

"""
    fmi3UInt8 (alias for Cuchar)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3UInt8 = Cuchar # = uint8_t
export fmi3UInt8

"""
    fmi3Int16 (alias for Cshort)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Int16 = Cshort # = int16_t
export fmi3Int16

"""
    fmi3UInt16 (alias for Cushort)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3UInt16 = Cushort # = uint16_t
export fmi3UInt16

"""
    fmi3Int32 (alias for Cint)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Int32 = Cint # = int32_t
export fmi3Int32

"""
    fmi3UInt32 (alias for Cuint)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3UInt32 = Cuint # = uint32_t
export fmi3UInt32

"""
    fmi3Int64 (alias for Clonglong)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Int64 = Clonglong # = int64_t
export fmi3Int64

"""
    fmi3UInt64 (alias for Culonglong)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3UInt64 = Culonglong # = uint64_t
export fmi3UInt64

"""
    fmi3Boolean (alias for Cuchar)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Boolean = Cuchar # = bool
export fmi3Boolean

"""
    fmi3Char (alias for Cuchar)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Char = Cuchar # [Note] changed to `Cuchar` to work with pointer function
export fmi3Char

"""
    fmi3String (alias for Ptr{fmi3Char})

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3String = Ptr{fmi3Char}
export fmi3String

"""
    fmi3Byte (alias for Cuchar)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Byte = Cuchar
export fmi3Byte

"""
    fmi3Binary (alias for Ptr{fmi3Byte})

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Binary = Ptr{fmi3Byte}
export fmi3Binary

"""
    fmi3ValueReference (alias for Cuint)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3ValueReference = Cuint
export fmi3ValueReference

"""
    fmi3FMUState (alias for Ptr{Cvoid})

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3FMUState = Ptr{Cvoid}
export fmi3FMUState

"""
    fmi3Instance (alias for Ptr{Cvoid})

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Instance = Ptr{Cvoid}
export fmi3Instance

"""
    fmi3InstanceEnvironment (alias for Ptr{Cvoid})

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3InstanceEnvironment = Ptr{Cvoid}
export fmi3InstanceEnvironment

"""
    fmi3Clock (alias for Cint)

Source: FMISpec3.0-dev, Version D5ef1c1:2.2.2. Platform Dependent Definitions
"""
const fmi3Clock = Cint
export fmi3Clock

"""
Defines the status flag (an enumeration of type fmi3Status defined in file fmi3FunctionTypes.h) that is returned by functions to indicate the success of the function call:
The status has the following meaning:
- fmi3OK: The call was successful. The output argument values are defined.
- fmi3Warning: A non-critical problem was detected, but the computation can continue. The output argument values are defined. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings.
[In certain applications, e.g. in a prototyping environment, warnings may be acceptable. For production environments warnings should be treated like errors unless they can be safely ignored.]
- fmi3Discard: The call was not successful and the FMU is in the same state as before the call. The output argument values are not defined, but the computation can continue. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings. Advanced simulation algorithms can try alternative approaches to drive the simulation by calling the function with different arguments or calling another function. Otherwise the simulation algorithm has to treat this return code like fmi3Error and has to terminate the simulation.
[Examples for usage of fmi3Discard are handling of min/max violation, or signal numerical problems during model evaluation forcing smaller step sizes.]
- fmi3Error: The call failed. The output argument values are undefined and the simulation cannot be continued. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings. If a function returns fmi3Error, it is possible to restore a previously retrieved FMU state by calling fmi3SetFMUState. Otherwise fmi3FreeInstance or fmi3Reset must be called. When detecting illegal arguments or a function call not allowed in the current state according to the respective state machine, the FMU must return fmi3Error. Other instances of this FMU are not affected by the error.
- fmi3Fatal: The state of all instances of the model is irreparably corrupted. [For example, due to a runtime exception such as access violation or integer division by zero during the execution of an FMI function.] Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings, if still possible. It is not allowed to call any other function for any instance of the FMU.

Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
"""
const fmi3Status = Cuint
export fmi3Status

"""
fmi3OK: The call was successful. The output argument values are defined.

Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
"""
const fmi3StatusOK = Cuint(0)
export fmi3StatusOK

"""
fmi3Warning: A non-critical problem was detected, but the computation can continue. The output argument values are defined. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings.
[In certain applications, e.g. in a prototyping environment, warnings may be acceptable. For production environments warnings should be treated like errors unless they can be safely ignored.]


Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
"""
const fmi3StatusWarning = Cuint(1)
export fmi3StatusWarning

"""
fmi3Discard: The call was not successful and the FMU is in the same state as before the call. The output argument values are not defined, but the computation can continue. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings. Advanced simulation algorithms can try alternative approaches to drive the simulation by calling the function with different arguments or calling another function. Otherwise the simulation algorithm has to treat this return code like fmi3Error and has to terminate the simulation.
[Examples for usage of fmi3Discard are handling of min/max violation, or signal numerical problems during model evaluation forcing smaller step sizes.]

Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
"""
const fmi3StatusDiscard = Cuint(2)
export fmi3StatusDiscard

"""
fmi3Error: The call failed. The output argument values are undefined and the simulation cannot be continued. Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings. If a function returns fmi3Error, it is possible to restore a previously retrieved FMU state by calling fmi3SetFMUState. Otherwise fmi3FreeInstance or fmi3Reset must be called. When detecting illegal arguments or a function call not allowed in the current state according to the respective state machine, the FMU must return fmi3Error. Other instances of this FMU are not affected by the error.

Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
"""
const fmi3StatusError = Cuint(3)
export fmi3StatusError

"""
fmi3Fatal: The state of all instances of the model is irreparably corrupted. [For example, due to a runtime exception such as access violation or integer division by zero during the execution of an FMI function.] Function logMessage should be called by the FMU with further information before returning this status, respecting the current logging settings, if still possible. It is not allowed to call any other function for any instance of the FMU.

Source: FMISpec3.0, Version D5ef1c1: 2.2.3. Status Returned by Functions
"""
const fmi3StatusFatal = Cuint(4)
export fmi3StatusFatal

"""
A not further specified annotation struct.

Source: [ToDo]
"""
mutable struct fmi3Annotation
    # No implementation
end
export fmi3Annotation

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
const fmi3Causality = Cuint
export fmi3Causality

"""
[TODO]
"""
const fmi3CausalityParameter = Cuint(0)
export fmi3CausalityParameter

"""
[TODO]
"""
const fmi3CausalityCalculatedParameter = Cuint(1)
export fmi3CausalityCalculatedParameter

"""
[TODO]
"""
const fmi3CausalityInput = Cuint(2)
export fmi3CausalityInput

"""
[TODO]
"""
const fmi3CausalityOutput = Cuint(3)
export fmi3CausalityOutput

"""
[TODO]
"""
const fmi3CausalityLocal = Cuint(4)
export fmi3CausalityLocal

"""
[TODO]
"""
const fmi3CausalityIndependent = Cuint(5)
export fmi3CausalityIndependent

"""
[TODO]
"""
const fmi3CausalityStructuralParameter = Cuint(6)
export fmi3CausalityStructuralParameter

# [ToDo] refactor custom doc-strings for every element
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
const fmi3Variability = Cuint
const fmi3VariabilityConstant = Cuint(0)
const fmi3VariabilityFixed = Cuint(1)
const fmi3VariabilityTunable = Cuint(2)
const fmi3VariabilityDiscrete = Cuint(3)
const fmi3VariabilityContinuous = Cuint(4)
export fmi3Variability,
    fmi3VariabilityConstant,
    fmi3VariabilityFixed,
    fmi3VariabilityTunable,
    fmi3VariabilityDiscrete,
    fmi3VariabilityContinuous

# [ToDo] refactor custom doc-strings for every element
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
const fmi3Initial = Cuint
const fmi3InitialExact = Cuint(0)
const fmi3InitialApprox = Cuint(1)
const fmi3InitialCalculated = Cuint(2)
export fmi3Initial, fmi3InitialExact, fmi3InitialApprox, fmi3InitialCalculated

"""
    fmi2False

Equals a binary `false` in FMI3.

Source: [TODO]
"""
const fmi3False = fmi3Boolean(false)
export fmi3False

"""
    fmi2True

Equals a binary `true` in FMI3.

Source: [TODO]
"""
const fmi3True = fmi3Boolean(true)
export fmi3True

# [ToDo] refactor custom doc-strings for every element
"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Argument fmuType defines the type of the FMU:
- fmi3ModelExchange: FMU with initialization and events; between events simulation of continuous systems is performed with external integrators from the environment.
- fmi3CoSimulation: Black box interface for co-simulation.
- fmi3ScheduledExecution: Concurrent computation of model partitions on a single computational resource (e.g. CPU-core)
"""
const fmi3Type = Cuint
const fmi3TypeModelExchange = Cuint(0)
const fmi3TypeCoSimulation = Cuint(1)
const fmi3TypeScheduledExecution = Cuint(2)
export fmi3Type, fmi3TypeModelExchange, fmi3TypeCoSimulation, fmi3TypeScheduledExecution

# [ToDo] refactor custom doc-strings for every element
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9.4. Scheduled Execution
Enumeration that defines the IntervalQualifiers which describe how to treat the intervals and intervalCounters arguments. They have the following meaning:
fmi3IntervalNotYetKnown -  is returned for a countdown aperiodic Clock for which the next interval is not yet known. This qualifier value can only be returned directly after the Clock was active and previous calls to fmi3GetInterval never returned fmi3IntervalChanged (nor fmi3IntervalUnchanged). In Scheduled Execution this return value means that the corresponding model partition cannot be scheduled yet.

fmi3IntervalUnchanged - is returned if a previous call to fmi3GetInterval already returned a value qualified with fmi3IntervalChanged which has not changed since. In Scheduled Execution this means the corresponding model partition has already been scheduled.

fmi3IntervalChanged - is returned to indicate that the value for the interval has changed for this Clock. Any previously returned intervals (if any) are overwritten with the current value. The new Clock interval is relative to the time of the current Event Mode or Clock Update Mode in contrast to the interval of a periodic Clock, where the interval is defined as the time between consecutive Clock ticks. In Scheduled Execution this means that the corresponding model partition has to be scheduled or re-scheduled (if a previous call to fmi3GetInterval returned fmi3IntervalChanged).
"""
const fmi3IntervalQualifier = Cuint
const fmi3IntervalQualifierIntervalNotYetKnown = Cuint(0)
const fmi3IntervalQualifierIntervalUnchanged = Cuint(1)
const fmi3IntervalQualifierIntervalChanged = Cuint(2)
export fmi3IntervalQualifier,
    fmi3IntervalQualifierIntervalNotYetKnown,
    fmi3IntervalQualifierIntervalUnchanged,
    fmi3IntervalQualifierIntervalChanged

"""
[TODO]

Source: FMISpec3.0, Version D5ef1c1: 2.4.7.5.1. Variable Naming Conventions
"""
const fmi3VariableNamingConvention = Cuint
export fmi3VariableNamingConvention

"""
[TODO]

Source: FMISpec3.0, Version D5ef1c1: 2.4.7.5.1. Variable Naming Conventions
"""
const fmi3VariableNamingConventionFlat = Cuint(0)
export fmi3VariableNamingConventionFlat

"""
[TODO]

Source: FMISpec3.0, Version D5ef1c1: 2.4.7.5.1. Variable Naming Conventions
"""
const fmi3VariableNamingConventionStructured = Cuint(1)
export fmi3VariableNamingConventionStructured

# [ToDo] doc-string format
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
const fmi3DependencyKind = Cuint
const fmi3DependencyKindIndependent = Cuint(0)
const fmi3DependencyKindConstant = Cuint(1)
const fmi3DependencyKindFixed = Cuint(2)
const fmi3DependencyKindTunable = Cuint(3)
const fmi3DependencyKindDiscrete = Cuint(4)
const fmi3DependencyKindDependent = Cuint(5)
export fmi3DependencyKind,
    fmi3DependencyKindIndependent,
    fmi3DependencyKindConstant,
    fmi3DependencyKindFixed,
    fmi3DependencyKindTunable,
    fmi3DependencyKindDiscrete,
    fmi3DependencyKindDependent
