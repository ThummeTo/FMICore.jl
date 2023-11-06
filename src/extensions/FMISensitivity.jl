#
# Copyright (c) 2023 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import .FMISensitivity.ForwardDiff 
import .FMISensitivity.ReverseDiff

###########

import .FMISensitivity.SciMLSensitivity.ForwardDiff
import .FMISensitivity.SciMLSensitivity.ReverseDiff

# check if scalar/vector is ForwardDiff.Dual
function isdual(e::ForwardDiff.Dual{T, V, N}) where {T, V, N}
    return true
end
function isdual(e::AbstractVector{<:ForwardDiff.Dual{T, V, N}}) where {T, V, N}
    return true
end

# check if scalar/vector is ForwardDiff.Dual
function istracked(e::ReverseDiff.TrackedReal) 
    return true
end
function istracked(e::AbstractVector{<:ReverseDiff.TrackedReal}) 
    return true
end
function istracked(e::ReverseDiff.TrackedArray) 
    return true
end

# makes Reals from ForwardDiff.Dual scalar/vector
function undual(e::ForwardDiff.Dual)
    return ForwardDiff.value(e)
end

# makes Reals from ReverseDiff.TrackedXXX scalar/vector
function untrack(e::ReverseDiff.TrackedReal)
    return ReverseDiff.value(e)
end
function untrack(e::ReverseDiff.TrackedArray)
    return ReverseDiff.value(e)
end

# makes Reals from ForwardDiff/ReverseDiff.TrackedXXX scalar/vector
function unsense(e::ReverseDiff.TrackedReal)
    return ReverseDiff.value(e)
end
function unsense(e::ReverseDiff.TrackedArray)
    return ReverseDiff.value(e)
end
function unsense(e::ForwardDiff.Dual)
    return ForwardDiff.value(e)
end

