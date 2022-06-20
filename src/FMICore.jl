#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMICore

# check float size (32 or 64 bits)
juliaArch = Sys.WORD_SIZE
@assert (juliaArch == 64 || juliaArch == 32) "FMICore: Unknown Julia Architecture with $(juliaArch)-bit, must be 64- or 32-bit."
Creal = Cdouble
if juliaArch == 32
    Creal = Cfloat
end

"""
The mutable struct representing an abstract (version unknown) FMU.
"""
abstract type FMU end
abstract type FMUSolution end
abstract type FMUExecutionConfig end 
abstract type FMUEvent end

include("FMI2_c.jl")
include("FMI2.jl")

include("FMI3_c.jl")
include("FMI3.jl")

### EXPORTING LISTS START ###

export FMU
export FMU2ExecutionConfiguration, FMU2_EXECUTION_CONFIGURATION_RESET, FMU2_EXECUTION_CONFIGURATION_NO_RESET, FMU2_EXECUTION_CONFIGURATION_NO_FREEING
export FMU3ExecutionConfiguration, FMU3_EXECUTION_CONFIGURATION_RESET, FMU3_EXECUTION_CONFIGURATION_NO_RESET, FMU3_EXECUTION_CONFIGURATION_NO_FREEING

# FMI2.jl
export FMU2, FMU2Component, FMU2ComponentEnvironment, FMU2Solution, FMU2Event 
export fmi2StatusToString
export fmi2CausalityToString, fmi2StringToCausality
export fmi2VariabilityToString, fmi2StringToVariability
export fmi2InitialToString, fmi2StringToInitial
export fmi2DependencyKindToString, fmi2StringToDependencyKind

# FMI2_c.jl 

# data types
export fmi2ValueReference, fmi2Component
export fmi2Char, fmi2String, fmi2Boolean, fmi2Real, fmi2Integer, fmi2Byte, fmi2FMUstate, fmi2ComponentEnvironment, fmi2Enum
export fmi2Status, fmi2StatusOK, fmi2StatusWarning, fmi2StatusDiscard, fmi2StatusError, fmi2StatusFatal, fmi2StatusPending
export fmi2CallbackFunctions
export fmi2Annotation
export fmi2Causality, fmi2CausalityParameter, fmi2CausalityCalculatedParameter, fmi2CausalityInput, fmi2CausalityOutput, fmi2CausalityLocal, fmi2CausalityIndependent
export fmi2Variability, fmi2VariabilityConstant, fmi2VariabilityFixed, fmi2VariabilityTunable, fmi2VariabilityDiscrete, fmi2VariabilityContinuous
export fmi2Initial, fmi2InitialExact, fmi2InitialApprox, fmi2InitialCalculated
export fmi2True, fmi2False
export fmi2Type, fmi2TypeModelExchange, fmi2TypeCoSimulation
export fmi2DatatypeVariable
export fmi2ScalarVariable
export fmi2StatusKind, fmi2StatusKindDoStepStatus, fmi2StatusKindPendingStatus, fmi2StatusKindLastSuccessfulTime, fmi2StatusKindTerminated
export fmi2EventInfo
export fmi2Unit, fmi2SimpleType
export fmi2DependencyKind, fmi2DependencyKindDependent, fmi2DependencyKindConstant, fmi2DependencyKindFixed, fmi2DependencyKindTunable, fmi2DependencyKindUnknown
export fmi2VariableNamingConvention, fmi2VariableNamingConventionFlat, fmi2VariableNamingConventionStructured
export fmi2VariableDependency
export fmi2DefaultExperiment, fmi2Unknown, fmi2ModelStructure
export fmi2ModelDescription 
export fmi2ComponentState, fmi2ComponentStateInstantiated, fmi2ComponentStateInitializationMode, fmi2ComponentStateEventMode, fmi2ComponentStateContinuousTimeMode, fmi2ComponentStateTerminated, fmi2ComponentStateError, fmi2ComponentStateFatal

# functions 
export fmi2Instantiate, fmi2FreeInstance!, fmi2GetTypesPlatform, fmi2GetVersion
export fmi2SetDebugLogging, fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2Terminate, fmi2Reset
export fmi2GetReal!, fmi2SetReal, fmi2GetInteger!, fmi2SetInteger, fmi2GetBoolean!, fmi2SetBoolean, fmi2GetString!, fmi2SetString
export fmi2GetFMUstate!, fmi2SetFMUstate, fmi2FreeFMUstate!, fmi2SerializedFMUstateSize!, fmi2SerializeFMUstate!, fmi2DeSerializeFMUstate!
export fmi2GetDirectionalDerivative!, fmi2SetRealInputDerivatives, fmi2GetRealOutputDerivatives!
export fmi2DoStep, fmi2CancelStep, fmi2GetStatus!, fmi2GetRealStatus!, fmi2GetIntegerStatus!, fmi2GetBooleanStatus!, fmi2GetStringStatus!
export fmi2SetTime, fmi2SetContinuousStates, fmi2EnterEventMode, fmi2NewDiscreteStates!, fmi2EnterContinuousTimeMode, fmi2CompletedIntegratorStep!
export fmi2GetDerivatives!, fmi2GetEventIndicators!, fmi2GetContinuousStates!, fmi2GetNominalsOfContinuousStates!

# FMI3.jl
export FMU3, FMU3Instance, FMU3InstanceEnvironment, FMU3Solution, FMU3Event
export fmi3StatusToString
export fmi3CausalityToString, fmi3StringToCausality
export fmi3VariabilityToString, fmi3StringToVariability
export fmi3InitialToString, fmi3StringToInitial
export fmi3TypeToString, fmi3StringToType
export fmi3IntervalQualifierToString, fmi3StringToIntervalQualifier
export fmi3DependencyKindToString, fmi3StringToDependencyKind
export fmi3VariableNamingConventionToString, fmi3StringToVariableNamingConvention

# FMI3_c.jl 

# data types
export fmi3ValueReference, fmi3ModelDescription, fmi3Instance, fmi3ModelVariable, fmi3DatatypeVariable
export fmi3False, fmi3True
export fmi3Status, fmi3StatusOK, fmi3StatusWarning, fmi3StatusDiscard, fmi3StatusError, fmi3StatusFatal
export fmi3Causality, fmi3CausalityParameter, fmi3CausalityCalculatedParameter, fmi3CausalityInput, fmi3CausalityOutput, fmi3CausalityLocal, fmi3CausalityIndependent, fmi3CausalityStructuralParameter 
export fmi3Initial, fmi3InitialExact, fmi3InitialApprox, fmi3InitialCalculated
export fmi3Variability, fmi3VariabilityConstant, fmi3VariabilityFixed, fmi3VariabilityTunable, fmi3VariabilityDiscrete, fmi3VariabilityContinuous
export fmi3Type, fmi3TypeModelExchange, fmi3TypeCoSimulation, fmi3TypeScheduledExecution
export fmi3Clock
export fmi3IntervalQualifier, fmi3IntervalQualifierIntervalChanged, fmi3IntervalQualifierIntervalNotYetKnown, fmi3IntervalQualifierIntervalUnchanged
export fmi3Char, fmi3String, fmi3Boolean, fmi3Binary, fmi3Float32, fmi3Float64, fmi3Int8, fmi3UInt8, fmi3Int16, fmi3UInt16, fmi3Int32, fmi3UInt32, fmi3Int64, fmi3UInt64, fmi3Byte, fmi3FMUState, fmi3InstanceEnvironment, fmi3Enum
export fmi3DependencyKind, fmi3DependencyKindDependent, fmi3DependencyKindIndependent, fmi3DependencyKindConstant, fmi3DependencyKindTunable, fmi3DependencyKindDiscrete, fmi3DependencyKindFixed, fmi3DependencyKindGetVariableDependencies
export fmi3VariableNamingConvention, fmi3VariableNamingConventionFlat, fmi3VariableNamingConventionStructured
export fmi3VariableDependency
export fmi3InstanceState, fmi3InstanceStateInstantiated, fmi3InstanceStateInitializationMode, fmi3InstanceStateEventMode, fmi3InstanceStateStepMode, fmi3InstanceStateClockActivationMode, fmi3InstanceStateContinuousTimeMode
export fmi3ConfigurationMode, fmi3ReconfigurationMode, fmi3InstanceStateTerminated, fmi3InstanceStateError, fmi3InstanceStateFatal

# functions 
export fmi3InstantiateCoSimulation, fmi3InstantiateModelExchange, fmi3InstantiateScheduledExecution, fmi3FreeInstance!, fmi3GetVersion
export fmi3SetDebugLogging, fmi3EnterInitializationMode, fmi3ExitInitializationMode, fmi3Terminate, fmi3Reset
export fmi3GetFloat32!, fmi3SetFloat32, fmi3GetFloat64!, fmi3SetFloat64
export fmi3GetInt8!, fmi3SetInt8, fmi3GetInt16!, fmi3SetInt16,fmi3GetInt32!, fmi3SetInt32, fmi3GetInt64!, fmi3SetInt64
export fmi3GetUInt8!, fmi3SetUInt8, fmi3GetUInt16!, fmi3SetUInt16,fmi3GetUInt32!, fmi3SetUInt32, fmi3GetUInt64!, fmi3SetUInt64
export fmi3GetBoolean!, fmi3SetBoolean, fmi3GetString!, fmi3SetString, fmi3GetBinary!, fmi3SetBinary, fmi3GetClock!, fmi3SetClock
export fmi3GetFMUState!, fmi3SetFMUState, fmi3FreeFMUState!, fmi3SerializedFMUStateSize!, fmi3SerializeFMUState!, fmi3DeSerializeFMUState!
export fmi3SetIntervalDecimal, fmi3SetIntervalFraction, fmi3GetIntervalDecimal!, fmi3GetIntervalFraction!, fmi3GetShiftDecimal!, fmi3GetShiftFraction!, fmi3ActivateModelPartition
export fmi3GetNumberOfVariableDependencies!, fmi3GetVariableDependencies!
export fmi3GetDirectionalDerivative!, fmi3GetAdjointDerivative!, fmi3GetOutputDerivatives!
export fmi3EnterConfigurationMode, fmi3ExitConfigurationMode
export fmi3GetNumberOfContinuousStates!, fmi3GetNumberOfEventIndicators!
export fmi3DoStep!, fmi3EnterStepMode
export fmi3SetTime, fmi3SetContinuousStates, fmi3EnterEventMode, fmi3UpdateDiscreteStates, fmi3EnterContinuousTimeMode, fmi3CompletedIntegratorStep!
export fmi3GetContinuousStateDerivatives, fmi3GetEventIndicators!, fmi3GetContinuousStates!, fmi3GetNominalsOfContinuousStates!, fmi3EvaluateDiscreteStates

### EXPORTING LISTS END ###

end # module
