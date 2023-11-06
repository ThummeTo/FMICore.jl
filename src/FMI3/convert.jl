#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""

    fmi3StatusToString(status::Union{fmi3Status, Integer})

Converts `fmi3Status` `status` into a String ("OK", "Warning", "Discard", "Error", "Fatal", "Unknown").
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
    fmi3CausalityToString(c::fmi3Causality)

Convert [`fmi3Causality`](@ref) `c` to the corresponding String ("parameter", "calculatedParameter", "structuralParameter", "input", "output", "local", "independent").
"""
function fmi3StringToStatus(s::AbstractString)
    if s == "OK" 
        return fmi3StatusOK
    elseif s == "Warning"
        return fmi3StatusWarning
    elseif s == "Discard" 
        return fmi3StatusDiscard
    elseif s == "Error" 
        return fmi3StatusError
    elseif s == "Fatal"
        return fmi3StatusFatal
    else
        return "Unknown"
    end
end
export fmi3StringToStatus

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
    fmi3StringToCausality(s::AbstractString)

Convert `s` ("parameter", "calculatedParameter", "structuralParameter", "input", "output", "local", "independent") to the corresponding [`fmi3Causality`](@ref).
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
    fmi3VariabilityToString(c::fmi3Variability)

Convert [`fmi3Variability`](@ref) `c` to the corresponding String ("constant", "fixed", "tunable", "discrete", "continuous").
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
    fmi3StringToVariability(s::AbstractString)

Convert `s` ("constant", "fixed", "tunable", "discrete", "continuous") to the corresponding [`fmi3Variability`](@ref).
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
    fmi3InitialToString(c::fmi3Initial)

Convert [`fmi3Initial`](@ref) `c` to the corresponding String ("approx", "exact", "calculated").
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
    fmi3StringToInitial(s::AbstractString)

Convert `s` ("approx", "exact", "calculated") to the corresponding [`fmi3Initial`](@ref).
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
    fmi3DependencyKindToString(c::fmi3DependencyKind)

Convert [`fmi3DependencyKind`](@ref) `c` to the corresponding String ("independent", "dependent", "constant", "fixed", "tunable", "discrete").
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
    fmi3StringToDependencyKind(s::AbstractString)

Convert `s` ("independent", "dependent", "constant", "fixed", "tunable", "discrete") to the corresponding [`fmi3DependencyKind`](@ref).
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
    fmi3VariableNamingConventionToString(c::fmi3VariableNamingConvention)

Convert [`fmi3VariableNamingConvention`](@ref) `c` to the corresponding String ("flat", "structured").
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
    fmi3StringToVariableNamingConvention(s::AbstractString)

Convert `s` ("flat", "structured") to the corresponding [`fmi3VariableNamingConvention`](@ref).
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
    fmi3TypeToString(c::fmi3Type)

Convert [`fmi3Type`](@ref) `c` to the corresponding String ("coSimulation", "modelExchange", "scheduledExecution").
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
    fmi3StringToType(s::AbstractString)

Convert `s` ("coSimulation", "modelExchange", "scheduledExecution") to the corresponding [`fmi3Type`](@ref).
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
    fmi3IntervalQualifierToString(c::fmi3IntervalQualifier)

Convert [`fmi3IntervalQualifier`](@ref) `c` to the corresponding String ("intervalNotYetKnown", "intervalUnchanged", "intervalChanged").
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
    fmi3StringToIntervalQualifier(s::AbstractString)

Convert `s` ("intervalNotYetKnown", "intervalUnchanged", "intervalChanged") to the corresponding [`fmi3IntervalQualifier`](@ref).
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