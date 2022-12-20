#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

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
export fmi3VariableDependency

# Custom helper, not part of the FMI-Spec. 
fmi3Unknown = fmi3VariableDependency

# TODO fmi3DatatypeVariable not part of FMI2
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
export fmi3DatatypeVariable

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

# TODO add missing variable types
"""
Source: FMISpec3.0, Version D5ef1c1: 2.4.7. Definition of Model Variables
                                     
A fmi3ModelVariable describes the the type, name, valueRefence and optional information for every variable in the Modeldescription.
"""
mutable struct fmi3ModelVariable
    # mandatory
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

    _Float::Union{fmi3ModelDescriptionFloat, Nothing}
    _Integer::Union{fmi3ModelDescriptionInteger, Nothing}
    _Boolean::Union{fmi3ModelDescriptionBoolean, Nothing}
    _String::Union{fmi3ModelDescriptionString, Nothing}
    _Enumeration::Union{fmi3ModelDescriptionEnumeration, Nothing}

    # Constructor for not further specified ModelVariable
    function fmi3ModelVariable(name::String, valueReference::fmi3ValueReference, causality::Union{fmi3Causality, Nothing}, variability::Union{fmi3Variability, Nothing}, initial::Union{fmi3Initial, Nothing})
        inst = new()
        inst.name = name 
        inst.valueReference = valueReference
        inst.datatype = fmi3DatatypeVariable()
        inst.description = nothing # ""
        inst.causality = causality
        if inst.causality === nothing
            inst.causality = fmi3CausalityLocal # default according to fmi specs
        end
        inst.variability = variability
        if inst.variability === nothing
            inst.variability = fmi3VariabilityContinuous # default according to fmi specs
        end
        inst.initial = initial
        if inst.initial === nothing
            if inst.causality !== nothing && inst.variability !== nothing
                if  inst.causality == fmi3CausalityParameter || inst.causality == fmi3CausalityStructuralParameter
                    if inst.variability == fmi3VariabilityFixed || inst.variability == fmi3VariabilityTunable
                        inst.initial = fmi3InitialExact
                    else
                        @warn "Causality: $(fmi3CausalityToString(inst.causality))   Variability: $(fmi3VariabilityToString(inst.variability))   This combination is not allowed."
                    end
                elseif inst.causality == fmi3CausalityCalculatedParameter && (inst.variability == fmi3VariabilityFixed || inst.variability == fmi3VariabilityTunable)
                        inst.initial = fmi3InitialCalculated
                elseif inst.causality == fmi3CausalityInput && (inst.variability == fmi3VariabilityDiscrete || inst.variability == fmi3VariabilityContinuous)
                        inst.initial = fmi3InitialExact
                elseif  inst.variability == fmi3VariabilityConstant && (inst.causality == fmi3CausalityOutput || inst.causality == fmi3CausalityLocal)
                        inst.initial = fmi3InitialExact 
                elseif inst.causality == fmi3CausalityOutput && (inst.variability == fmi3VariabilityDiscrete || inst.variability == fmi3VariabilityContinuous)
                        inst.initial = fmi3InitialCalculated
                elseif inst.causality == fmi3CausalityLocal
                        inst.initial = fmi3InitialCalculated
                else
                        @warn "Causality: $(fmi3CausalityToString(inst.causality))   Variability: $(fmi3VariabilityToString(inst.variability))   This combination is not allowed."
                end
            else
                @warn "Causality: $(fmi3CausalityToString(inst.causality))   Variability: $(fmi3VariabilityToString(inst.variability))   Cannot pick default value for `initial` if one of them is `nothing`."
            end
        end
        
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
export fmi3ModelVariable

""" 
Overload the Base.show() function for custom printing of the fmi3ModelVariable.
"""
Base.show(io::IO, var::fmi3ModelVariable) = print(io,
"Name: '$(var.name)' (reference: $(var.valueReference))")

""" 
ToDo 
"""
mutable struct fmi3Unit
    # ToDo 
end
export fmi3Unit

""" 
ToDo 
"""
mutable struct fmi3SimpleType
    # ToDo 
end
export fmi3SimpleType

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
    numberOfEventIndicators::Union{UInt, Nothing}

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
    enumerations::fmi3Enum

    # additional fields (non-FMI-specific)
    valueReferenceIndicies::Dict{UInt,UInt}

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
export fmi3ModelDescription

# Overload the Base.show() function for custom printing of the fmi3ModelDescription.
function Base.show(io::IO, desc::fmi3ModelDescription) 
    print(io,
        "Model name:            $(desc.modelName)
        FMI version:            $(desc.fmiVersion)
        Instantiation Token:    $(desc.instantiationToken)
        Description:            $(desc.description)
        Model variables:        $(desc.modelVariables)")
end