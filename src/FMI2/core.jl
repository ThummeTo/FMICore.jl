#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# What is included in this file:
# - fmi2xxx-structs and -functions from the FMI2-specification 

"""
Source: FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

FMI2 Data Types
To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section.
All definitions in this section are provided in the header file “fmi2TypesPlatform.h”.
"""
const fmi2Char = Cuchar
const fmi2String = Ptr{fmi2Char}
const fmi2Boolean = Cint
const fmi2Real = Creal      # defined in FMICore.jl, dependent on the Julia architecture it's `cfloat` or `cdouble`
const fmi2Integer = Cint
const fmi2Byte = Char
const fmi2ValueReference = Cuint
const fmi2FMUstate = Ptr{Cvoid}
const fmi2Component = Ptr{Cvoid}
const fmi2ComponentEnvironment = Ptr{Cvoid}
const fmi2Enum = Array{Array{String}} # TODO: correct it
export fmi2Char, fmi2String, fmi2Boolean, fmi2Real, fmi2Integer, fmi2Byte, fmi2ValueReference, fmi2FMUstate, fmi2Component, fmi2ComponentEnvironment, fmi2Enum

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
export fmi2Status, fmi2StatusOK, fmi2StatusWarning, fmi2StatusDiscard, fmi2StatusError, fmi2StatusFatal, fmi2StatusPending

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
export fmi2CallbackFunctions

"""
A not further specified annotation struct.
"""
mutable struct fmi2Annotation
    # No implementation
end
export fmi2Annotation

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
export fmi2Causality, fmi2CausalityParameter, fmi2CausalityCalculatedParameter, fmi2CausalityInput, fmi2CausalityOutput, fmi2CausalityLocal, fmi2CausalityIndependent

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
export fmi2Variability, fmi2VariabilityConstant, fmi2VariabilityFixed, fmi2VariabilityTunable, fmi2VariabilityDiscrete, fmi2VariabilityContinuous 

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
export fmi2Initial, fmi2InitialExact, fmi2InitialApprox, fmi2InitialCalculated

"""
Source: FMISpec2.0.2[p.16]: 2.1.2 Platform Dependent Definitions

To simplify porting, no C types are used in the function interfaces, but the alias types are defined in this section.
All definitions in this section are provided in the header file “fmi2TypesPlatform.h”.
"""
const fmi2True = fmi2Boolean(true)
const fmi2False = fmi2Boolean(false)
export fmi2True, fmi2False

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Argument fmuType defines the type of the FMU:
- fmi2ModelExchange: FMU with initialization and events; between events simulation of continuous systems is performed with external integrators from the environment.
- fmi2CoSimulation: Black box interface for co-simulation.
"""
const fmi2Type = Cuint
const fmi2TypeModelExchange = Cuint(0)
const fmi2TypeCoSimulation  = Cuint(1)
export fmi2Type, fmi2TypeModelExchange, fmi2TypeCoSimulation

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

CoSimulation specific Enum representing state of FMU after fmi2DoStep returned fmi2Pending.
"""
const fmi2StatusKind = Cuint
const fmi2StatusKindDoStepStatus        = Cuint(0)
const fmi2StatusKindPendingStatus       = Cuint(1)
const fmi2StatusKindLastSuccessfulTime  = Cuint(2)
const fmi2StatusKindTerminated          = Cuint(3)
export fmi2StatusKind, fmi2StatusKindDoStepStatus, fmi2StatusKindPendingStatus, fmi2StatusKindLastSuccessfulTime, fmi2StatusKindTerminated

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
export fmi2EventInfo
