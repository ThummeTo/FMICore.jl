#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Formats the fmi3Status/Integer into a String.
"""
function fmi3StatusToString(status::Union{fmi3Status, Integer})
    if status == fmi3StatusOK
        return "OK"
    elseif status == fmi3StatusWarning
        return "Warning"
    elseif status == fmi3StatusDiscard
        return "Discard"
    elseif status == fmi3StatusError
        return "Error"
    elseif status == fmi3StatusFatal
        return "Fatal"
    else
        return "Unknown"
    end
end
export fmi3StatusToString

"""
ToDo.
"""
function fmi3CausalityToString(c::fmi3Causality)
    if c == fmi3CausalityParameter
        return "parameter"
    elseif c == fmi3CausalityCalculatedParameter
        return "calculatedParameter"
    elseif c == fmi3CausalityInput
        return "input"
    elseif c == fmi3CausalityOutput
        return "output"
    elseif c == fmi3CausalityLocal
        return "local"
    elseif c == fmi3CausalityIndependent
        return "independent"
    elseif c == fmi3CausalityStructuralParameter
        return "structuralParameter"
    else 
        @assert false "fmi3CausalityToString(...): Unknown causality."
    end
end
export fmi3CausalityToString

"""
ToDo.
"""
function fmi3StringToCausality(s::AbstractString)
    if s == "parameter"
        return fmi3CausalityParameter
    elseif s == "calculatedParameter"
        return fmi3CausalityCalculatedParameter
    elseif s == "input"
        return fmi3CausalityInput
    elseif s == "output"
        return fmi3CausalityOutput
    elseif s == "local"
        return fmi3CausalityLocal
    elseif s == "independent"
        return fmi3CausalityIndependent
    elseif s == "structuralParameter"
        return fmi3CausalityStructuralParameter
    else 
        @assert false "fmi3StringToCausality($(s)): Unknown causality."
    end
end
export fmi3StringToCausality

"""
ToDo.
"""
function fmi3VariabilityToString(c::fmi3Variability)
    if c == fmi3VariabilityConstant
        return "constant"
    elseif c == fmi3VariabilityFixed
        return "fixed"
    elseif c == fmi3VariabilityTunable
        return "tunable"
    elseif c == fmi3VariabilityDiscrete
        return "discrete"
    elseif c == fmi3VariabilityContinuous
        return "continuous"
    else 
        @assert false "fmi3VariabilityToString(...): Unknown variability."
    end
end
export fmi3VariabilityToString

"""
ToDo.
"""
function fmi3StringToVariability(s::AbstractString)
    if s == "constant"
        return fmi3VariabilityConstant
    elseif s == "fixed"
        return fmi3VariabilityFixed
    elseif s == "tunable"
        return fmi3VariabilityTunable
    elseif s == "discrete"
        return fmi3VariabilityDiscrete
    elseif s == "continuous"
        return fmi3VariabilityContinuous
    else 
        @assert false "fmi3StringToVariability($(s)): Unknown variability."
    end
end
export fmi3StringToVariability

"""
ToDo.
"""
function fmi3InitialToString(c::fmi3Initial)
    if c == fmi3InitialApprox
        return "approx"
    elseif c == fmi3InitialExact
        return "exact"
    elseif c == fmi3InitialCalculated
        return "calculated"
    else 
        @assert false "fmi3InitialToString(...): Unknown initial."
    end
end
export fmi3InitialToString

"""
ToDo.
"""
function fmi3StringToInitial(s::AbstractString)
    if s == "approx"
        return fmi3InitialApprox
    elseif s == "exact"
        return fmi3InitialExact
    elseif s == "calculated"
        return fmi3InitialCalculated
    else 
        @assert false "fmi3StringToInitial($(s)): Unknown initial."
    end
end
export fmi3StringToInitial

"""
ToDo.
"""
function fmi3DependencyKindToString(c::fmi3DependencyKind)
    if c == fmi3DependencyKindIndependent
        return "independent"
    elseif c == fmi3DependencyKindConstant
        return "constant"
    elseif c == fmi3DependencyKindFixed
        return "fixed"
    elseif c == fmi3DependencyKindTunable
        return "tunable"
    elseif c == fmi3DependencyKindDiscrete
        return "discrete"
    elseif c == fmi3DependencyKindDependent
        return "dependent"
    else 
        @assert false "fmi3DependencyKindToString(...): Unknown dependencyKind."
    end
end
export fmi3DependencyKindToString

"""
ToDo.
"""
function fmi3StringToDependencyKind(s::AbstractString)
    if s == "independent"
        return fmi3DependencyKindIndependent
    elseif s == "constant"
        return fmi3DependencyKindConstant
    elseif s == "fixed"
        return fmi3DependencyKindFixed
    elseif s == "tunable"
        return fmi3DependencyKindTunable
    elseif s == "discrete"
        return fmi3DependencyKindDiscrete
    elseif s == "dependent"
        return fmi3DependencyKindDependent
    else 
        @assert false "fmi3StringToDependencyKind($(s)): Unknown dependencyKind."
    end
end
export fmi3StringToDependencyKind

"""
ToDo.
"""
function fmi3VariableNamingConventionToString(c::fmi3VariableNamingConvention)
    if c == fmi3VariableNamingConventionFlat
        return "flat"
    elseif c == fmi3VariableNamingConventionStructured
        return "structured"
    else 
        @assert false "fmi3VariableNamingConventionToString(...): Unknown variableNamingConvention."
    end
end
export fmi3VariableNamingConventionToString

"""
ToDo.
"""
function fmi3StringToVariableNamingConvention(s::AbstractString)
    if s == "flat"
        return fmi3VariableNamingConventionFlat
    elseif s == "structured"
        return fmi3VariableNamingConventionStructured
    else 
        @assert false "fmi3StringToVariableNamingConvention($(s)): Unknown variableNamingConvention."
    end
end
export fmi3StringToVariableNamingConvention

"""
ToDo.
"""
function fmi3TypeToString(c::fmi3Type)
    if c == fmi3TypeCoSimulation
        return "coSimulation"
    elseif c == fmi3TypeModelExchange
        return "modelExchange"
    elseif c == fmi3TypeScheduledExecution
        return "scheduledExecution"
    else 
        @assert false "fmi3TypeToString(...): Unknown type."
    end
end
export fmi3TypeToString

"""
ToDo.
"""
function fmi3StringToType(s::AbstractString)
    if s == "coSimulation"
        return fmi3TypeCoSimulation
    elseif s == "modelExchange"
        return fmi3TypeModelExchange
    elseif s == "scheduledExecution"
        return fmi3TypeScheduledExecution
    else 
        @assert false "fmi3StringToInitial($(s)): Unknown type."
    end
end
export fmi3StringToType

"""
ToDo.
"""
function fmi3IntervalQualifierToString(c::fmi3IntervalQualifier)
    if c == fmi3IntervalQualifierIntervalNotYetKnown
        return "intervalNotYetKnown"
    elseif c == fmi3IntervalQualifierIntervalUnchanged
        return "intervalUnchanged"
    elseif c == fmi3IntervalQualifierIntervalChanged
        return "intervalChanged"
    else 
        @assert false "fmi3IntervalQualifierToString(...): Unknown intervalQualifier."
    end
end
export fmi3IntervalQualifierToString

"""
ToDo.
"""
function fmi3StringToIntervalQualifier(s::AbstractString)
    if s == "intervalNotYetKnown"
        return fmi3IntervalQualifierIntervalNotYetKnown
    elseif s == "intervalUnchanged"
        return fmi3IntervalQualifierIntervalUnchanged
    elseif s == "intervalChanged"
        return fmi3IntervalQualifierIntervalChanged
    else 
        @assert false "fmi3StringToIntervalQualifier($(s)): Unknown intervalQualifier."
    end
end
export fmi3StringToIntervalQualifier