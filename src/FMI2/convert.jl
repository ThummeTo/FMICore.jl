#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
    
    fmi2StatusToString(status)

Converts a fmi2Status/Integer `status` to String.
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
        @assert false "fmi2StatusToString($(status)): Unknown FMU status `$(status)`."
    end
end
export fmi2StatusToString

"""
    
    fmi2StringToStatus(s)

Converts a String `s` to fmi2Status.
"""
function fmi2StatusToString(s::AbstractString)
    if s == "OK"
        return fmi2StatusOK
    elseif s == "Warning"
        return fmi2StatusWarning
    elseif s == "Discard"
        return fmi2StatusDiscard
    elseif s == "Error"
        return fmi2StatusError
    elseif s == "Fatal"
        return fmi2StatusFatal
    elseif s == "Pending" 
        return fmi2StatusPending
    else
        @assert false "fmi2StatusToString($(s)): Unknown FMU status `$(s)`."
    end
end
export fmi2StatusToString

"""
    
    fmi2CausalityToString(c)

Converts a fmi2Causality `c` to String.
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
    
    fmi2StringToCausality(s)

Converts a String `s` to fmi2Causality.
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
    
    fmi2VariabilityToString(c)

Converts a fmi2Variablitiy `c` to fmi2Variability.
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
    
    fmi2StringToVariability(s)

Converts a String `s` to fmi2Variablitiy.
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
    
    fmi2InitialToString(c)

Converts a  fmi2Initial `c` to String.
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
    
    fmi2StringToInitial(s)

Converts a String `s` to fmi2Initial.
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
    
    fmi2DependencyKindToString(dk)

Converts a fmi2DependencyKind `dk` to String.
"""
function fmi2DependencyKindToString(dk::fmi2DependencyKind)
    if dk == fmi2DependencyKindDependent
        return "dependent"
    elseif dk == fmi2DependencyKindConstant
        return "constant"
    elseif dk == fmi2DependencyKindFixed
        return "fixed"
    elseif dk == fmi2DependencyKindTunable
        return "tunable"
    elseif dk == fmi2DependencyKindDiscrete
        return "discrete"
    else 
        @assert false "fmi2DependencyKindToString($(c)): Unknown dependency kind."
    end
end
export fmi2DependencyKindToString

"""
    
    fmi2StringToDependencyKind(s)

Converts a String `s` to fmi2DependencyKind.
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