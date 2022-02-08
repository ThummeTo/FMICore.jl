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

include("FMI2_c.jl")
include("FMI2.jl")

include("FMI3_c.jl")
include("FMI3.jl")

### EXPORTING LISTS START ###

export FMU

# FMI2.jl
export FMU2, FMU2Component
export fmi2StatusToString
export fmi2CausalityToString, fmi2StringToCausality
export fmi2VariabilityToString, fmi2StringToVariability
export fmi2InitialToString, fmi2StringToInitial

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
export fmi2ComponentState, fmi2ComponentStateModelSetableFMUstate, fmi2ComponentStateModelUnderEvaluation, fmi2ComponentStateModelInitialized

# functions 
export fmi2CallbackLogger, fmi2CallbackAllocateMemory, fmi2CallbackFreeMemory, fmi2CallbackStepFinished
export fmi2Instantiate, fmi2FreeInstance!, fmi2GetTypesPlatform, fmi2GetVersion
export fmi2SetDebugLogging, fmi2SetupExperiment, fmi2EnterInitializationMode, fmi2ExitInitializationMode, fmi2Terminate, fmi2Reset
export fmi2GetReal!, fmi2SetReal, fmi2GetInteger!, fmi2SetInteger, fmi2GetBoolean!, fmi2SetBoolean, fmi2GetString!, fmi2SetString
export fmi2GetFMUstate!, fmi2SetFMUstate, fmi2FreeFMUstate!, fmi2SerializedFMUstateSize!, fmi2SerializeFMUstate!, fmi2DeSerializeFMUstate!
export fmi2GetDirectionalDerivative!, fmi2SetRealInputDerivatives, fmi2GetRealOutputDerivatives!
export fmi2DoStep, fmi2CancelStep, fmi2GetStatus!, fmi2GetRealStatus!, fmi2GetIntegerStatus!, fmi2GetBooleanStatus!, fmi2GetStringStatus!
export fmi2SetTime, fmi2SetContinuousStates, fmi2EnterEventMode, fmi2NewDiscreteStates!, fmi2EnterContinuousTimeMode, fmi2CompletedIntegratorStep!
export fmi2GetDerivatives!, fmi2GetEventIndicators!, fmi2GetContinuousStates!, fmi2GetNominalsOfContinuousStates!

# FMI3.jl
export FMU3, FMU3Component
export fmi3StatusToString

# FMI3_c.jl 

# data types
export fmi3ValueReference, fmi3ModelDescription, fmi3Component
export fmi3Clock
export fmi3IntervalQualifier, fmi3IntervalQualifierIntervalChanged, fmi3IntervalQualifierIntervalNotYetKnown, fmi3IntervalQualifierIntervalUnchanged
export fmi3Char, fmi3String, fmi3Boolean, fmi3Binary, fmi3Float32, fmi3Float64, fmi3Int8, fmi3UInt8, fmi3Int16, fmi3UInt16, fmi3Int32, fmi3UInt32, fmi3Int64, fmi3UInt64, fmi3Byte, fmi3FMUState, fmi3InstanceEnvironment, fmi3Enum
export fmi3DependencyKind, fmi3DependencyKindDependent, fmi3DependencyKindIndependent, fmi3DependencyKindConstant, fmi3DependencyKindTunable, fmi3DependencyKindDiscrete, fmi3DependencyKindFixed, fmi3DependencyKindGetVariableDependencies

# functions 
# ToDo 

### EXPORTING LISTS END ###

end # module
