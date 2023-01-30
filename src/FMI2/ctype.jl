#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

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
export fmi2VariableDependency

# Custom helper, not part of the FMI-Spec. 
fmi2Unknown = fmi2VariableDependency

abstract type fmi2ModelDescriptionVariable end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionReal <: fmi2ModelDescriptionVariable
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
mutable struct fmi2ModelDescriptionInteger <: fmi2ModelDescriptionVariable
    # optional
    start::Union{fmi2Integer, Nothing}
    declaredType::Union{String, Nothing}

    quantity::Union{String, Nothing}
    min::Union{fmi2Integer, Nothing}
    max::Union{fmi2Integer, Nothing}
    # constructor 
    function fmi2ModelDescriptionInteger()
        inst = new()
        inst.start = nothing 
        inst.quantity = nothing
        inst.min = nothing
        inst.max = nothing
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionBoolean <: fmi2ModelDescriptionVariable 
    # optional
    start::Union{fmi2Boolean, Nothing}
    declaredType::Union{String, Nothing}
    
    # constructor 
    function fmi2ModelDescriptionBoolean()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionString <: fmi2ModelDescriptionVariable
    # optional
    start::Union{String, Nothing}
    declaredType::Union{String, Nothing}
    
    # constructor 
    function fmi2ModelDescriptionString()
        inst = new()
        inst.start = nothing 
        return inst 
    end
end

# Custom helper, not part of the FMI-Spec. 
mutable struct fmi2ModelDescriptionEnumeration <: fmi2ModelDescriptionVariable
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

# Constant definition of Union type for use in other type definitions. 
# Union definitions are more performant than abstractly typed fields.
const FMI2_MODEL_DESCRIPTION_VARIABLE = Union{
    fmi2ModelDescriptionReal,
    fmi2ModelDescriptionInteger,
    fmi2ModelDescriptionBoolean,
    fmi2ModelDescriptionString,
    fmi2ModelDescriptionEnumeration,
}

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

    # custom
    variable::Union{FMI2_MODEL_DESCRIPTION_VARIABLE, Nothing}

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

        inst.variable = nothing

        return inst
    end
end
export fmi2ScalarVariable

# overwrite `getproperty` to mimic existance of properties `Real`, `Integer`, `Boolean`, `String`, 'Enumeration'
function Base.getproperty(var::fmi2ScalarVariable, sym::Symbol)
    if sym == :Real 
        if !isa(var.variable, fmi2ModelDescriptionReal) 
            return nothing 
        end
        return Base.getfield(var, :variable)
    elseif sym == :Integer
        if !isa(var.variable, fmi2ModelDescriptionInteger) 
            return nothing 
        end
        return Base.getfield(var, :variable)
    elseif sym == :Boolean
        if !isa(var.variable, fmi2ModelDescriptionBoolean) 
            return nothing 
        end
        return Base.getfield(var, :variable)
    elseif sym == :String
        if !isa(var.variable, fmi2ModelDescriptionString) 
            return nothing 
        end
        return Base.getfield(var, :variable)
    elseif sym == :Enumeration
        if !isa(var.variable, fmi2ModelDescriptionEnumeration) 
            return nothing 
        end
        return Base.getfield(var, :variable)
    else
        return invoke(Base.getproperty, Tuple{Any, Symbol}, var, sym)
    end 
end

# overwrite `setproperty!` to mimic existance of properties `Real`, `Integer`, `Boolean`, `String`, 'Enumeration'
function Base.setproperty!(var::fmi2ScalarVariable, sym::Symbol, value)
    if sym ∈ (:Real, :Integer, :Boolean, :String, :Enumeration)
        Base.setfield!(var, :variable, value)
    else 
        return invoke(Base.setproperty!, Tuple{Any, Symbol, Any}, var, sym, value)
    end 

    return nothing
end

""" 
Overload the Base.show() function for custom printing of the fmi2ScalarVariable.
"""
Base.show(io::IO, var::fmi2ScalarVariable) = print(io,
"Name: '$(var.name)' (reference: $(var.valueReference))")

"Abstract supertype for attribute structures of an `fmi2SimpleType`."
abstract type fmi2SimpleTypeAttributeStruct end

"""
    fmi2SimpleTypeAttributesReal(
        quantity=nothing, unit=nothing, displayUnit=nothing, relativeQuantity=nothing,
        min=nothing, max=nothing, nominal=nothing, unbounded=nothing
    ) <: fmi2SimpleTypeAttributeStruct

Source: FMISpec2.0.3[p.40 - 43]: 2.2.3 Definition of Types (TypeDefinitions)

Mutable helper structure for the attributes of a Real fmi2SimpleType.
"""
Base.@kwdef mutable struct fmi2SimpleTypeAttributesReal <: fmi2SimpleTypeAttributeStruct
    quantity :: Union{Nothing, String} = nothing
    unit :: Union{Nothing, String} = nothing
    displayUnit :: Union{Nothing, String} = nothing
    relativeQuantity :: Union{Nothing, Bool} = nothing
    min :: Union{Nothing, fmi2Real} = nothing
    max :: Union{Nothing, fmi2Real} = nothing
    nominal :: Union{Nothing, fmi2Real} = nothing
    unbounded :: Union{Nothing, Bool} = nothing
end

"""
    fmi2SimpleTypeAttributesInteger(
        quantity=nothing, min=nothing, max=nothing
    ) <: fmi2SimpleTypeAttributeStruct

Source: FMISpec2.0.3[p.40 - 43]: 2.2.3 Definition of Types (TypeDefinitions)

Mutable helper structure for the attributes of an Integer fmi2SimpleType.
"""
Base.@kwdef mutable struct fmi2SimpleTypeAttributesInteger <: fmi2SimpleTypeAttributeStruct
    quantity :: Union{Nothing, String} = nothing
    min :: Union{Nothing, fmi2Real} = nothing
    max :: Union{Nothing, fmi2Real} = nothing
end

"""
    fmi2SimpleTypeAttributesString() <: fmi2SimpleTypeAttributeStruct

Source: FMISpec2.0.3[p.40 - 43]: 2.2.3 Definition of Types (TypeDefinitions)

Helper structure for the attributes of a String fmi2SimpleType.
"""
struct fmi2SimpleTypeAttributesString <: fmi2SimpleTypeAttributeStruct end

"""
    fmi2SimpleTypeAttributesBoolean() <: fmi2SimpleTypeAttributeStruct

Source: FMISpec2.0.3[p.40 - 43]: 2.2.3 Definition of Types (TypeDefinitions)

Helper structure for the attributes of a Boolean fmi2SimpleType.
"""
struct fmi2SimpleTypeAttributesBoolean <: fmi2SimpleTypeAttributeStruct end

"""
    fmi2SimpleTypeAttributesEnumeration() <: fmi2SimpleTypeAttributeStruct

Source: FMISpec2.0.3[p.40 - 43]: 2.2.3 Definition of Types (TypeDefinitions)

Helper structure for the attributes of an Enumeration fmi2SimpleType.
"""
struct fmi2SimpleTypeAttributesEnumeration <: fmi2SimpleTypeAttributeStruct end

""" 
Source: FMISpec2.0.3[p.40]: 2.2.3 Definition of Types (TypeDefinitions)

The fmi2SimpleType describes the attributes of a type definition.
"""
mutable struct fmi2SimpleType
    # mandatory
    name::String
    # one of 
    Real::Union{Nothing, fmi2SimpleTypeAttributesReal}
    Integer::Union{Nothing, fmi2SimpleTypeAttributesInteger}
    String::Union{Nothing, fmi2SimpleTypeAttributesString}
    Boolean::Union{Nothing, fmi2SimpleTypeAttributesBoolean}
    Enumeration::Union{Nothing, fmi2SimpleTypeAttributesEnumeration}

    # optional
    description::Union{String, Nothing}
end

function fmi2SimpleType(
    name::String, attr::A, description::Union{String, Nothing}=nothing
) where A<:fmi2SimpleTypeAttributeStruct
    @assert !isempty(name) "Positional argument `name::String` must not be empty."
    
    if attr isa fmi2SimpleTypeAttributesReal
        return fmi2SimpleType(name, attr, nothing, nothing, nothing, nothing, description)
    elseif attr isa fmi2SimpleTypeAttributesInteger
        return fmi2SimpleType(name, nothing, attr, nothing, nothing, nothing, description)
    elseif attr isa fmi2SimpleTypeAttributesString
        return fmi2SimpleType(name, nothing, nothing, attr, nothing, nothing, description)
    elseif attr isa fmi2SimpleTypeAttributesBoolean
        return fmi2SimpleType(name, nothing, nothing, nothing, attr, nothing, description)
    elseif attr isa fmi2SimpleTypeAttributesEnumeration
        return fmi2SimpleType(name, nothing, nothing, nothing, nothing, attr, description)
    end
    error("Positional argument `attr` not of valid type.")
end

export fmi2SimpleType

"""
Source: FMISpec2.0.3[p.35]: 2.2.2 Definition of Units (UnitDefinitions)

    BaseUnit(
        kg=0, m=0, s=0, A=0, K=0, mol=0, cd=0, rad=0, factor=1.0, offset=0.0)

Type for the optional “BaseUnit” field of an `fmi2Unit`.
"""
mutable struct BaseUnit
    # exponents of SI units
    # kilogram
    kg::fmi2Integer
    # meter
    m::fmi2Integer
    # second
    s::fmi2Integer
    # Ampere
    A::fmi2Integer
    # Kelvin
    K::fmi2Integer
    # mol
    mol::fmi2Integer
    # candela
    cd::fmi2Integer
    # radians
    rad::fmi2Integer

    factor::fmi2Real
    offset::fmi2Real

    function BaseUnit(
        kg::Real=fmi2Integer(0),
        m::Real=fmi2Integer(0),
        s::Real=fmi2Integer(0),
        A::Real=fmi2Integer(0),
        K::Real=fmi2Integer(0),
        mol::Real=fmi2Integer(0),
        cd::Real=fmi2Integer(0),
        rad::Real=fmi2Integer(0),
        factor::Real=1.0,
        offset::Real=0.0
    )
        # TODO should we do sanity checks here? E.g., check for at least 1 non-zero exponent?
        return new(kg, m, s, A, K, mol, cd, rad, factor, offset)
    end
end
const SI_UNIT_STRINGS = ("kg", "m", "s", "A", "K", "mol", "cd", "rad")

function Base.show(io::IO, unit::BaseUnit)
    if get(io, :compact, false)
        print(io, "BaseUnit")
    else    
        units = String[]
        
        for siUnit in SI_UNIT_STRINGS
            expon = getfield(unit, Symbol(siUnit))
            if !iszero(expon)
                push!(units, siUnit * "^{$(string(expon))}")
            end
        end

        unit_str = join(units, ", ")

        if unit.factor != 1
            unit_str *= ", factor=$(unit.factor)"
        end
        if !iszero(unit.offset)
            unit_str *= ", offset=$(unit.offset)"
        end

        print(io,"BaseUnit( $(unit_str) )")
    end
end

"""
Source: FMISpec2.0.3[p.35]: 2.2.2 Definition of Units (UnitDefinitions)

    DisplayUnit(name, factor=1.0, offset=0.0)

Type for the optional “DisplayUnit” field(s) of an `fmi2Unit`.
"""
mutable struct DisplayUnit
    # mandatory
    name::String
    # optional
    factor::fmi2Real
    offset::fmi2Real
    function DisplayUnit(name::String, factor::Real=1.0, offset::Real=0.0)
        return new(name, factor, offset)
    end
end

""" 
Source: FMISpec2.0.3[p.35]: 2.2.2 Definition of Units (UnitDefinitions)

Element “UnitDefinitions ” of fmiModelDescription.
"""
mutable struct fmi2Unit
    # mandatory
    name::String
    # optional
    baseUnit::Union{BaseUnit,Nothing}
    displayUnit::Union{Vector{DisplayUnit},Nothing}

    function fmi2Unit(
        name::String,
        baseUnit::Union{BaseUnit,Nothing}=nothing,
        displayUnit::Union{Vector{DisplayUnit},Nothing}=nothing,
    )
        return new(name, baseUnit, displayUnit)
    end
end
export fmi2Unit

"""
Source: FMISpec2.0.2[p.34]: 2.2.1 Definition of an FMU (fmiModelDescription)

The “ModelVariables” element of fmiModelDescription is the central part of the model description. It provides the static information of all exposed variables.
"""
mutable struct fmi2ModelDescription 
    # attributes (mandatory)
    fmiVersion::String
    modelName::String
    guid::Union{String, Base.UUID}

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
export fmi2ModelDescription 

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
