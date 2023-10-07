#
# Copyright (c) 2022 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# this file containes placeholders for sensitivity (AD) related functions,
# if FMISensitivity is not loaded, these functions dispatch to neutral statements,
# if FMISensitivity is loaded, these functions are extended.

# check if scalar/vector is ForwardDiff.Dual
function isdual(e)
    return false 
end
function isdual(e::Tuple)
    return any(isdual.(e))
end

# check if scalar/vector is ForwardDiff.Dual
function istracked(e)
    return false 
end
function istracked(e::Tuple)
    return any(istracked.(e))
end

# makes Reals from ForwardDiff.Dual scalar/vector
function undual(e::AbstractArray)
    return undual.(e)
end
function undual(e::AbstractArray{fmi2Real})
    return e
end
function undual(e::Tuple)
    if !isdual(e)
        return e 
    end
    return undual.(e)
end
function undual(::Nothing)
    return nothing
end
function undual(e)
    return e
end

# makes Reals from ReverseDiff.TrackedXXX scalar/vector
function untrack(e::AbstractArray)
    return untrack.(e)
end
function untrack(e::AbstractArray{fmi2Real})
    return e
end
function untrack(e::Tuple)
    if !istracked(e)
        return e 
    end
    return untrack.(e)
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
    if !isdual(e) && !istracked(e)
        return e 
    end
    return unsense.(e)
end
function unsense(::Nothing)
    return nothing
end
function unsense(e)
    return e
end
