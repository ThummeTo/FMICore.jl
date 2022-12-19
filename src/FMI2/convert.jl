#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Formats a fmi2Status/Integer to String.
"""
function fmi2StatusToString(status::Union{fmi2Status, Integer})
    if status == fmi2StatusOK
        return "OK"
    elseif status == fmi2StatusWarning
        return "Warning"
    elseif status == fmi2StatusDiscard
        return "Discard"
    elseif status == fmi2StatusError
        return "Error"
    elseif status == fmi2StatusFatal
        return "Fatal"
    elseif status == fmi2StatusPending
        return "Pending"
    else
        @assert false "fmi2StatusToString($(status)): Unknown FMU status."
    end
end
export fmi2StatusToString

"""
ToDo.
"""
function fmi2CausalityToString(c::fmi2Causality)
    if c == fmi2CausalityParameter
        return "parameter"
    elseif c == fmi2CausalityCalculatedParameter
        return "calculatedParameter"
    elseif c == fmi2CausalityInput
        return "input"
    elseif c == fmi2CausalityOutput
        return "output"
    elseif c == fmi2CausalityLocal
        return "local"
    elseif c == fmi2CausalityIndependent
        return "independent"
    else 
        @assert false "fmi2CausalityToString($(c)): Unknown causality."
    end
end
export fmi2CausalityToString

"""
ToDo.
"""
function fmi2StringToCausality(s::AbstractString)
    if s == "parameter"
        return fmi2CausalityParameter
    elseif s == "calculatedParameter"
        return fmi2CausalityCalculatedParameter
    elseif s == "input"
        return fmi2CausalityInput
    elseif s == "output"
        return fmi2CausalityOutput
    elseif s == "local"
        return fmi2CausalityLocal
    elseif s == "independent"
        return fmi2CausalityIndependent
    else 
        @assert false "fmi2StringToCausality($(s)): Unknown causality."
    end
end
export fmi2StringToCausality

"""
ToDo.
"""
function fmi2VariabilityToString(c::fmi2Variability)
    if c == fmi2VariabilityConstant
        return "constant"
    elseif c == fmi2VariabilityFixed
        return "fixed"
    elseif c == fmi2VariabilityTunable
        return "tunable"
    elseif c == fmi2VariabilityDiscrete
        return "discrete"
    elseif c == fmi2VariabilityContinuous
        return "continuous"
    else 
        @assert false "fmi2VariabilityToString($(c)): Unknown variability."
    end
end
export fmi2VariabilityToString

"""
ToDo.
"""
function fmi2StringToVariability(s::AbstractString)
    if s == "constant"
        return fmi2VariabilityConstant
    elseif s == "fixed"
        return fmi2VariabilityFixed
    elseif s == "tunable"
        return fmi2VariabilityTunable
    elseif s == "discrete"
        return fmi2VariabilityDiscrete
    elseif s == "continuous"
        return fmi2VariabilityContinuous
    else 
        @assert false "fmi2StringToVariability($(s)): Unknown variability."
    end
end
export fmi2StringToVariability

"""
ToDo.
"""
function fmi2InitialToString(c::fmi2Initial)
    if c == fmi2InitialApprox
        return "approx"
    elseif c == fmi2InitialExact
        return "exact"
    elseif c == fmi2InitialCalculated
        return "calculated"
    else 
        @assert false "fmi2InitialToString($(c)): Unknown initial."
    end
end
export fmi2InitialToString

"""
ToDo.
"""
function fmi2StringToInitial(s::AbstractString)
    if s == "approx"
        return fmi2InitialApprox
    elseif s == "exact"
        return fmi2InitialExact
    elseif s == "calculated"
        return fmi2InitialCalculated
    else 
        @assert false "fmi2StringToInitial($(s)): Unknown initial."
    end
end
export fmi2StringToInitial

"""
ToDo.
"""
function fmi2DependencyKindToString(c::fmi2DependencyKind)
    if c == fmi2DependencyKindDependent
        return "dependent"
    elseif c == fmi2DependencyKindConstant
        return "constant"
    elseif c == fmi2DependencyKindFixed
        return "fixed"
    elseif c == fmi2DependencyKindTunable
        return "tunable"
    elseif c == fmi2DependencyKindDiscrete
        return "discrete"
    else 
        @assert false "fmi2DependencyKindToString($(c)): Unknown dependency kind."
    end
end
export fmi2DependencyKindToString

"""
ToDo.
"""
function fmi2StringToDependencyKind(s::AbstractString)
    if s == "dependent"
        return fmi2DependencyKindDependent
    elseif s == "constant"
        return fmi2DependencyKindConstant
    elseif s == "fixed"
        return fmi2DependencyKindFixed
    elseif s == "tunable"
        return fmi2DependencyKindTunable
    elseif s == "discrete"
        return fmi2DependencyKindDiscrete
    else 
        @assert false "fmi2StringToDependencyKind($(s)): Unknown dependency kind."
    end
end
export fmi2StringToDependencyKind