#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import Dates: DateTime

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
Mutable Struct representing existance and kind of dependencies of an Unknown on Known Variables in Continuous-Time and Event Mode (ME) and at Communication Points (CS)

See also FMI2.0.3 Spec fmi2VariableDependency [p.60]
"""
mutable struct fmi2VariableDependency
    # mandatory 
    index::UInt

    # optional
    dependencies::Union{Array{UInt,1},Nothing}
    dependenciesKind::Union{Array{fmi2DependencyKind,1},Nothing}

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
export fmi2Unknown

# custom abstract types, not part of the FMI-spec
abstract type fmi2Attributes end # Attributes used in fmi2XXXAttributes
abstract type fmi2AttributesExt end # extended version of the Attributes used in fmi2XXXAttributes

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2RealAttributes <: fmi2Attributes
    # mandatory
    # (nothing)

    # optional
    quantity::Union{String,Nothing}
    unit::Union{String,Nothing}
    displayUnit::Union{String,Nothing}
    relativeQuantity::Union{Bool,Nothing}
    min::Union{Real,Nothing}
    max::Union{Real,Nothing}
    nominal::Union{Real,Nothing}
    unbounded::Union{Bool,Nothing}

    # constructor 
    function fmi2RealAttributes()
        inst = new()

        inst.quantity = nothing
        inst.unit = nothing
        inst.displayUnit = nothing
        inst.relativeQuantity = nothing
        inst.min = nothing
        inst.max = nothing
        inst.nominal = nothing
        inst.unbounded = nothing

        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2RealAttributesExt <: fmi2AttributesExt
    # mandatory
    # (nothing)

    # optional
    declaredType::Union{String,Nothing}
    start::Union{Real,Nothing}
    derivative::Union{UInt,Nothing}
    reinit::Union{Bool,Nothing}

    # helper 
    attributes::fmi2RealAttributes

    # constructor 
    function fmi2RealAttributesExt()
        inst = new()

        inst.declaredType = nothing
        inst.start = nothing
        inst.derivative = nothing
        inst.reinit = nothing

        inst.attributes = fmi2RealAttributes()

        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2IntegerAttributes <: fmi2Attributes
    # optional
    quantity::Union{String,Nothing}
    min::Union{Integer,Nothing}
    max::Union{Integer,Nothing}

    # constructor 
    function fmi2IntegerAttributes()
        inst = new()

        inst.quantity = nothing
        inst.min = nothing
        inst.max = nothing

        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2IntegerAttributesExt <: fmi2AttributesExt
    # optional
    start::Union{fmi2Integer,Nothing}
    declaredType::Union{String,Nothing}

    attributes::fmi2IntegerAttributes

    # constructor 
    function fmi2IntegerAttributesExt()
        inst = new()

        inst.start = nothing
        inst.declaredType = nothing

        inst.attributes = fmi2IntegerAttributes()
        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2BooleanAttributesExt <: fmi2AttributesExt
    # optional
    start::Union{fmi2Boolean,Nothing}
    declaredType::Union{String,Nothing}

    # no `attributes` element, because the FMI-spec does not define one!

    # constructor 
    function fmi2BooleanAttributesExt()
        inst = new()

        inst.start = nothing
        inst.declaredType = nothing

        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2BooleanAttributes <: fmi2Attributes
    # this struct has no content and is only defined for consistency reasons!
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2StringAttributesExt <: fmi2AttributesExt
    # optional
    start::Union{String,Nothing}
    declaredType::Union{String,Nothing}

    # no `attributes` element, because the FMI-spec does not define one!

    # constructor 
    function fmi2StringAttributesExt()
        inst = new()

        inst.start = nothing
        inst.declaredType = nothing

        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2StringAttributes <: fmi2Attributes
    # this struct has no content and is only defined for consistency reasons!
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2EnumerationAttributesExt <: fmi2AttributesExt
    # mandatory 
    declaredType::Union{String,Nothing}

    # optional
    quantity::Union{String,Nothing}
    min::Union{Integer,Nothing}
    max::Union{Integer,Nothing}
    start::Union{Integer,Nothing}

    # constructor 
    function fmi2EnumerationAttributesExt()
        inst = new()

        inst.declaredType = nothing

        inst.quantity = nothing
        inst.min = nothing
        inst.max = nothing
        inst.start = nothing

        return inst
    end
end

"""
Custom helper, not part of the FMI-Spec. 

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2ModelDescriptionEnumerationItem

    # mandatory
    name::Union{String,Nothing}
    value::Union{Integer,Nothing}

    # optional
    description::Union{String,Nothing}

    # Constructor 
    function fmi2ModelDescriptionEnumerationItem()
        inst = new()
        inst.name = nothing
        inst.value = nothing

        inst.description = nothing

        return inst
    end
end

"""
ToDo.

Source: 2.2.3 Definition of Types (TypeDefinitions)
"""
mutable struct fmi2EnumerationAttributes <: fmi2Attributes
    # optional
    quantity::Union{String,Nothing}

    # mandatory (invisible)
    items::Array{fmi2ModelDescriptionEnumerationItem,1}

    # constructor 
    function fmi2EnumerationAttributes()
        inst = new()
        inst.quantity = nothing
        inst.items = []
        return inst
    end
end

import Base.push!
function push!(attr::fmi2EnumerationAttributes, items...)
    push!(attr.items, items...)
end

import Base.getindex
function getindex(attr::fmi2EnumerationAttributes, keys...)
    getindex(attr.items, keys...)
end

import Base.length
function length(attr::fmi2EnumerationAttributes)
    length(attr.items)
end

# mimic existence of properties of `fmi2RealAttributes` in `fmi2RealAttributesExt` (inheritance is not available in Julia, so it is simulated)
function Base.setproperty!(
    var::Union{fmi2RealAttributesExt,fmi2IntegerAttributesExt},
    sym::Symbol,
    value,
)

    if Base.invoke(Base.hasproperty, Tuple{Any,Symbol}, var, sym)
        return invoke(Base.setproperty!, Tuple{Any,Symbol,Any}, var, sym, value)
    end

    var_attributes = invoke(Base.getproperty, Tuple{Any,Symbol}, var, :attributes)

    if hasproperty(var_attributes, sym)
        return Base.setfield!(var_attributes, sym, value)
    end

    @assert false "Unknown property: $(sym)"

    return nothing
end

# mimic existence of properties of `fmi2RealAttributes` in `fmi2RealAttributesExt` (inheritance is not available in Julia, so it is simulated)
function Base.getproperty(
    var::Union{fmi2RealAttributesExt,fmi2IntegerAttributesExt},
    sym::Symbol,
)

    if Base.invoke(Base.hasproperty, Tuple{Any,Symbol}, var, sym)
        return Base.invoke(Base.getproperty, Tuple{Any,Symbol}, var, sym)
    end

    var_attributes = invoke(Base.getproperty, Tuple{Any,Symbol}, var, :attributes)

    if Base.hasproperty(var_attributes, sym)
        return Base.getproperty(var_attributes, sym)
    end

    @assert false "Unknown proerty: $(sym)"

    return nothing
end

# mimic existence of properties of `fmi2RealAttributes` in `fmi2RealAttributesExt` (inheritance is not available in Julia, so it is simulated)
function Base.hasproperty(
    var::Union{fmi2RealAttributesExt,fmi2IntegerAttributesExt},
    sym::Symbol,
)

    if Base.invoke(Base.hasproperty, Tuple{Any,Symbol}, var, sym)
        return true
    end

    var_attributes = invoke(Base.getproperty, Tuple{Any,Symbol}, var, :attributes)
    return Base.hasproperty(var_attribute, sym)
end

# Constant definition of union for the extended attributes (used in fmi2ScalarVariables)
const FMI2_SCALAR_VARIABLE_ATTRIBUTE_STRUCT = Union{
    fmi2RealAttributesExt,
    fmi2IntegerAttributesExt,
    fmi2BooleanAttributesExt,
    fmi2StringAttributesExt,
    fmi2EnumerationAttributesExt,
}

# Constant definition of union for the (not extended) attributes (used in fmi2SimpleTypes)
const FMI2_SIMPLE_TYPE_ATTRIBUTE_STRUCT = Union{
    fmi2RealAttributes,
    fmi2IntegerAttributes,
    fmi2StringAttributes,
    fmi2BooleanAttributes,
    fmi2EnumerationAttributes,
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
    outputs::Union{Array{fmi2VariableDependency,1},Nothing}
    derivatives::Union{Array{fmi2VariableDependency,1},Nothing}
    initialUnknowns::Union{Array{fmi2Unknown,1},Nothing}

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
    canGetAndSetFMUstate::Union{Bool,Nothing}
    canSerializeFMUstate::Union{Bool,Nothing}
    providesDirectionalDerivative::Union{Bool,Nothing}

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
    canHandleVariableCommunicationStepSize::Union{Bool,Nothing}
    canInterpolateInputs::Union{Bool,Nothing}
    maxOutputDerivativeOrder::Union{UInt,Nothing}
    canGetAndSetFMUstate::Union{Bool,Nothing}
    canSerializeFMUstate::Union{Bool,Nothing}
    providesDirectionalDerivative::Union{Bool,Nothing}

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
    description::Union{String,Nothing}
    causality::Union{fmi2Causality,Nothing}
    variability::Union{fmi2Variability,Nothing}
    initial::Union{fmi2Initial,Nothing}
    canHandleMultipleSetPerTimeInstant::Union{fmi2Boolean,Nothing}
    annotations::Union{fmi2Annotation,Nothing}

    # custom
    attribute::Union{FMI2_SCALAR_VARIABLE_ATTRIBUTE_STRUCT,Nothing}

    # Constructor for not further specified ScalarVariables
    function fmi2ScalarVariable(
        name::String,
        valueReference::fmi2ValueReference,
        causality::Union{fmi2Causality,Nothing},
        variability::Union{fmi2Variability,Nothing},
        initial::Union{fmi2Initial,Nothing},
    )
        inst = new()
        inst.name = name
        inst.valueReference = valueReference
        inst.description = nothing
        inst.causality = causality
        inst.variability = variability
        inst.initial = initial
        inst.canHandleMultipleSetPerTimeInstant = nothing
        inst.annotations = nothing
        inst.attribute = nothing

        return inst
    end
end
export fmi2ScalarVariable

function getAttributes(sv::fmi2ScalarVariable)

    causality = sv.causality
    variability = sv.variability
    initial = sv.initial

    if isnothing(causality)
        causality = fmi2CausalityLocal # this is the default according FMI-spec p. 48
    end

    if isnothing(variability)
        variability = fmi2VariabilityContinuous   # this is the default according FMI-spec p. 49  
    end

    if isnothing(initial)
        # setting default value for initial  according FMI-spec p. 51
        if causality != nothing && variability != nothing
            if causality == fmi2CausalityParameter
                if variability == fmi2VariabilityFixed ||
                   variability == fmi2VariabilityTunable
                    initial = fmi2InitialExact
                else
                    @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   This combination is not allowed."
                end
            elseif causality == fmi2CausalityCalculatedParameter
                if variability == fmi2VariabilityFixed ||
                   variability == fmi2VariabilityTunable
                    initial = fmi2InitialCalculated
                else
                    @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   This combination is not allowed."
                end
            elseif causality == fmi2CausalityInput
                if variability == fmi2VariabilityDiscrete ||
                   variability == fmi2VariabilityContinuous
                    # everything allright, it's not allowed to define `initial` in this case
                else
                    @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   This combination is not allowed."
                end
            elseif causality == fmi2CausalityOutput
                if variability == fmi2VariabilityConstant
                    initial = fmi2InitialExact
                elseif variability == fmi2VariabilityDiscrete ||
                       variability == fmi2VariabilityContinuous
                    initial = fmi2InitialCalculated
                else
                    @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   This combination is not allowed."
                end
            elseif causality == fmi2CausalityLocal
                if variability == fmi2VariabilityConstant
                    initial = fmi2InitialExact
                elseif variability == fmi2VariabilityFixed ||
                       variability == fmi2VariabilityTunable
                    initial = fmi2InitialCalculated
                elseif variability == fmi2VariabilityDiscrete ||
                       variability == fmi2VariabilityContinuous
                    initial = fmi2InitialCalculated
                else
                    @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   This combination is not allowed."
                end
            elseif causality == fmi2CausalityIndependent
                if variability == fmi2VariabilityContinuous
                    # everything allright, it's not allowed to define `initial` in this case
                else
                    @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   This combination is not allowed."
                end
            end
        else
            @warn "Causality: $(fmi2CausalityToString(causality))   Variability: $(fmi2VariabilityToString(variability))   Cannot pick default value for `initial` if one of them is `nothing`."
        end
    end

    return causality, variability, initial
end

""" 
Overload the Base.show() function for custom printing of the fmi2ScalarVariable.
"""
function Base.show(io::IO, var::fmi2ScalarVariable)
    print(io, "Name: '$(var.name)' (reference: $(var.valueReference))")
end

""" 
Source: FMISpec2.0.3[p.40]: 2.2.3 Definition of Types (TypeDefinitions)

The fmi2SimpleType describes the attributes of a type definition.
"""
mutable struct fmi2SimpleType
    # mandatory
    name::Union{String,Nothing}

    # optional
    description::Union{String,Nothing}

    # helper 
    attribute::Union{FMI2_SIMPLE_TYPE_ATTRIBUTE_STRUCT,Nothing}

    function fmi2SimpleType()
        inst = new()

        inst.name = nothing
        inst.description = nothing
        inst.attribute = nothing

        return inst
    end
end
export fmi2SimpleType

# Overwrite property setters and getters:

# overwrite `getproperty` and `hasproperty` to mimic existence of properties 
# `Real`, `Integer`, `Boolean`, `String`, 'Enumeration'
function Base.hasproperty(var::Union{fmi2ScalarVariable,fmi2SimpleType}, sym::Symbol)
    if sym in (:Real, :Integer, :Boolean, :String, :Enumeration)
        var_attribute = Base.invoke(Base.getproperty, Tuple{Any,Symbol}, var, :attribute)

        if sym == :Real
            return isa(var_attribute, fmi2RealAttributesExt) ||
                   isa(var_attribute, fmi2RealAttributes)
        elseif sym == :Integer
            return isa(var_attribute, fmi2IntegerAttributesExt) ||
                   isa(var_attribute, fmi2IntegerAttributes)
        elseif sym == :Boolean
            return isa(var_attribute, fmi2BooleanAttributesExt) ||
                   isa(var_attribute, fmi2BooleanAttributes)
        elseif sym == :String
            return isa(var_attribute, fmi2StringAttributesExt) ||
                   isa(var_attribute, fmi2StringAttributes)
        elseif sym == :Enumeration
            return isa(var_attribute, fmi2EnumerationAttributesExt) ||
                   isa(var_attribute, fmi2EnumerationAttributes)
        end

        return false
    end

    return Base.invoke(Base.hasproperty, Tuple{Any,Symbol}, var, sym)
end

function Base.getproperty(var::Union{fmi2ScalarVariable,fmi2SimpleType}, sym::Symbol)

    if sym in (:Real, :Integer, :Boolean, :String, :Enumeration)
        var_attribute = Base.invoke(Base.getproperty, Tuple{Any,Symbol}, var, :attribute)

        if sym == :Real
            if isa(var_attribute, fmi2RealAttributesExt) ||
               isa(var_attribute, fmi2RealAttributes)
                return var_attribute
            end
        elseif sym == :Integer
            if isa(var_attribute, fmi2IntegerAttributesExt) ||
               isa(var_attribute, fmi2IntegerAttributes)
                return var_attribute
            end
        elseif sym == :Boolean
            if isa(var_attribute, fmi2BooleanAttributesExt) ||
               isa(var_attribute, fmi2BooleanAttributes)
                return var_attribute
            end
        elseif sym == :String
            if isa(var_attribute, fmi2StringAttributesExt) ||
               isa(var_attribute, fmi2StringAttributes)
                return var_attribute
            end
        elseif sym == :Enumeration
            if isa(var_attribute, fmi2EnumerationAttributesExt) ||
               isa(var_attribute, fmi2EnumerationAttributes)
                return var_attribute
            end
        end

        return nothing
    end

    return invoke(Base.getproperty, Tuple{Any,Symbol}, var, sym)
end

# overwrite `setproperty!` to mimic existence of properties `Real`, `Integer`, `Boolean`, `String`, 'Enumeration'
function Base.setproperty!(
    var::Union{fmi2ScalarVariable,fmi2SimpleType},
    sym::Symbol,
    value,
)
    if sym ∈ (:Real, :Integer, :Boolean, :String, :Enumeration)
        return invoke(Base.setproperty!, Tuple{Any,Symbol,Any}, var, :attribute, value)
    else
        return invoke(Base.setproperty!, Tuple{Any,Symbol,Any}, var, sym, value)
    end
end

# ToDo: This is not a compliant docString.
"""
Source: FMISpec2.0.3[p.35]: 2.2.2 Definition of Units (UnitDefinitions)

    fmi2BaseUnit(
        kg=0, m=0, s=0, A=0, K=0, mol=0, cd=0, rad=0, factor=1.0, offset=0.0)

Type for the optional “BaseUnit” field of an `fmi2Unit`.
"""
mutable struct fmi2BaseUnit
    # exponents of SI units
    kg::Union{Integer,Nothing} # kilogram
    m::Union{Integer,Nothing} # meter
    s::Union{Integer,Nothing} # second
    A::Union{Integer,Nothing} # Ampere
    K::Union{Integer,Nothing} # Kelvin
    mol::Union{Integer,Nothing} # mol
    cd::Union{Integer,Nothing} # candela
    rad::Union{Integer,Nothing} # radians

    factor::Union{Real,Nothing}
    offset::Union{Real,Nothing}

    function fmi2BaseUnit(
        kg::Union{Integer,Nothing} = nothing,
        m::Union{Integer,Nothing} = nothing,
        s::Union{Integer,Nothing} = nothing,
        A::Union{Integer,Nothing} = nothing,
        K::Union{Integer,Nothing} = nothing,
        mol::Union{Integer,Nothing} = nothing,
        cd::Union{Integer,Nothing} = nothing,
        rad::Union{Integer,Nothing} = nothing,
        factor::Union{Real,Nothing} = nothing,
        offset::Union{Real,Nothing} = nothing,
    )

        return new(kg, m, s, A, K, mol, cd, rad, factor, offset)
    end
end
export fmi2BaseUnit

function Base.show(io::IO, unit::fmi2BaseUnit)
    if get(io, :compact, false)
        print(io, "BaseUnit")
    else

        for siUnit in SI_UNITS
            expon = unit.siUnit
            if !iszero(expon)
                print(io, "\n\t" * siUnit * "^{$(string(expon))}")
            end
        end

        print(io, "\n\tFactor: $(unit.factor)")
        print(io, "\n\tOffset: $(unit.offset)")
    end
end

"""
Source: FMISpec2.0.3[p.35]: 2.2.2 Definition of Units (UnitDefinitions)

    fmi2DisplayUnit(name, factor=1.0, offset=0.0)

Type for the optional “DisplayUnit” field(s) of an `fmi2Unit`.
"""
mutable struct fmi2DisplayUnit
    # mandatory
    name::String
    # optional
    factor::Real
    offset::Real

    function fmi2DisplayUnit(name::String, factor::Real = 1.0, offset::Real = 0.0)
        return new(name, factor, offset)
    end
end
export fmi2DisplayUnit

""" 
Source: FMISpec2.0.3[p.35]: 2.2.2 Definition of Units (UnitDefinitions)

Element “UnitDefinitions ” of fmiModelDescription.
"""
mutable struct fmi2Unit
    # mandatory
    name::String
    # optional
    baseUnit::Union{fmi2BaseUnit,Nothing}
    displayUnits::Union{Vector{fmi2DisplayUnit},Nothing}

    function fmi2Unit(
        name::String,
        baseUnit::Union{fmi2BaseUnit,Nothing} = nothing,
        displayUnits::Union{Vector{fmi2DisplayUnit},Nothing} = nothing,
    )
        return new(name, baseUnit, displayUnits)
    end
end
export fmi2Unit

"""
Source: FMISpec2.0.2[p.34]: 2.2.1 Definition of an FMU (fmiModelDescription)

The “ModelVariables” element of fmiModelDescription is the central part of the model description. It provides the static information of all exposed variables.
"""
mutable struct fmi2ModelDescription <: fmiModelDescription
    # attributes (mandatory)
    fmiVersion::String
    modelName::String
    guid::Union{String,Base.UUID}

    # attributes (optional)
    description::Union{String,Nothing}
    author::Union{String,Nothing}
    version::Union{String,Nothing}
    copyright::Union{String,Nothing}
    license::Union{String,Nothing}
    generationTool::Union{String,Nothing}
    generationDateAndTime::Union{DateTime,String,Nothing}
    variableNamingConvention::Union{fmi2VariableNamingConvention,Nothing}
    numberOfEventIndicators::Union{UInt,Nothing}

    unitDefinitions::Union{Array{fmi2Unit,1},Nothing}
    typeDefinitions::Union{Array{fmi2SimpleType,1},Nothing}
    logCategories::Union{Array,Nothing} # ToDo: Array type

    defaultExperiment::Union{fmi2ModelDescriptionDefaultExperiment,Nothing}
    modelExchange::Union{fmi2ModelDescriptionModelExchange,Nothing}
    coSimulation::Union{fmi2ModelDescriptionCoSimulation,Nothing}

    vendorAnnotations::Union{Array,Nothing} # ToDo: Array type
    modelVariables::Array{fmi2ScalarVariable,1}
    modelStructure::fmi2ModelDescriptionModelStructure

    # additionals
    valueReferences::Array{fmi2ValueReference}
    inputValueReferences::Array{fmi2ValueReference}
    outputValueReferences::Array{fmi2ValueReference}
    stateValueReferences::Array{fmi2ValueReference}
    discreteStateValueReferences::Array{fmi2ValueReference}
    derivativeValueReferences::Array{fmi2ValueReference}
    parameterValueReferences::Array{fmi2ValueReference}

    # additional fields (non-FMI-specific)
    stringValueReferences::Dict{String,fmi2ValueReference}     # String-ValueReference pairs of MD
    valueReferenceIndicies::Dict{UInt,UInt}

    # Constructor for uninitialized struct
    function fmi2ModelDescription()
        inst = new()

        inst.fmiVersion = ""
        inst.modelName = ""
        inst.guid = ""

        inst.description = nothing
        inst.author = nothing
        inst.version = nothing
        inst.copyright = nothing
        inst.license = nothing
        inst.generationTool = nothing
        inst.generationDateAndTime = nothing
        inst.variableNamingConvention = nothing
        inst.numberOfEventIndicators = nothing

        inst.unitDefinitions = nothing
        inst.typeDefinitions = nothing
        inst.logCategories = nothing

        inst.defaultExperiment = nothing
        inst.modelExchange = nothing
        inst.coSimulation = nothing

        inst.vendorAnnotations = nothing
        inst.modelVariables = Array{fmi2ScalarVariable,1}()
        inst.modelStructure = fmi2ModelDescriptionModelStructure()

        inst.valueReferences = []
        inst.inputValueReferences = []
        inst.outputValueReferences = []
        inst.stateValueReferences = []
        inst.discreteStateValueReferences = []
        inst.derivativeValueReferences = []
        inst.parameterValueReferences = []

        inst.stringValueReferences = Dict{String,fmi2ValueReference}()
        inst.valueReferenceIndicies = Dict{UInt,UInt}()

        return inst
    end
end
export fmi2ModelDescription

""" 
Overload the Base.show() function for custom printing of the fmi2ModelDescription.
"""
Base.show(io::IO, desc::fmi2ModelDescription) = print(
    io,
    "Model name:      $(desc.modelName)
    FMI version:     $(desc.fmiVersion)
    GUID:            $(desc.guid)
    Description:     $(desc.description)
    Model variables: [$(length(desc.modelVariables))]",
)
