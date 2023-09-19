#
# Copyright (c) 2022 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# this file containes placeholders for sensitivity (AD) related functions,
# if FMISensitivity is not loaded, these functions dispatch to neutral statements,
# if FMISensitivity is loaded, these functions are overwritten.

# check if scalar/vector is ForwardDiff.Dual
function isdual(e)
    return false 
end

# check if scalar/vector is ForwardDiff.Dual
function istracked(e)
    return false 
end

# check types (Tag, Variable, Number) of ForwardDiff.Dual scalar/vector
function fd_eltypes(e)
    @assert "fd_eltypes needs FMISensitivity to work. Use `import FMISensitivity`."
end

# overwrites a ForwardDiff.Dual in-place 
# inheritates partials
function sense_set!(dst::AbstractArray{<:Real}, src::AbstractArray{<:Real})
    dst[:] = src
    return nothing
end

# makes Reals from ForwardDiff.Dual scalar/vector
function undual(e::AbstractArray)
    return collect(undual(c) for c in e)
end
function undual(e::Tuple)
    return (collect(undual(c) for c in e)...,)
end
function undual(::Nothing)
    return nothing
end
function undual(e)
    return e
end

# makes Reals from ReverseDiff.TrackedXXX scalar/vector
function untrack(e::AbstractArray)
    return collect(untrack(c) for c in e)
end
function untrack(e::Tuple)
    return (collect(untrack(c) for c in e)...,)
end
function untrack(::Nothing)
    return nothing
end
function untrack(e)
    return e
end

# makes Reals from ForwardDiff/ReverseDiff.TrackedXXX scalar/vector
function unsense(e::AbstractArray)
    return unsense.(e)
end
function unsense(e::AbstractArray{fmi2Real})
    return e
end
function unsense(e::Tuple)
    return (collect(unsense(c) for c in e)...,)
end
function unsense(::Nothing)
    return nothing
end
function unsense(e)
    return e
end
