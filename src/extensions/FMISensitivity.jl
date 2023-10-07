#
# Copyright (c) 2023 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

import .FMISensitivity.ForwardDiff 
import .FMISensitivity.ReverseDiff

# function getDerivatives!(c::FMU2Component, dx::AbstractArray{<:ForwardDiff.Dual})
#     dx_tmp = ForwardDiff.value.(dx)
#     c.fmu.isZeroState || fmi2GetDerivatives!(c, dx_tmp)

#     for i = 1:length(dx)
#         dx[i].value = dx_tmp[i]
#     end
    
#     return nothing
# end

# function getDerivatives!(c::FMU2Component, dx::ReverseDiff.TrackedArray)
#     dx_tmp = zeros(fmi2Real, length(dx))
#     fmi2GetDerivatives!(c, dx_tmp)

#     for i in 1:length(dx)
#         dx[i].value = dx_tmp[i]
#     end  

#     return nothing
# end

# function getOutputs!(c::FMU2Component, y::AbstractArray{<:ForwardDiff.Dual}, y_refs)
#     y_tmp = collect(ForwardDiff.value(e) for e in y)
#     fmi2GetReal!(c, y_refs, y_tmp)
    
#     for i = 1:length(y)
#         y[i].value = y_tmp[i]
#     end

#     return nothing
# end

# function getOutputs!(c::FMU2Component, y::ReverseDiff.TrackedArray, y_refs)
#     @assert false, "getOutputs!() not implemented (yet) for ReverseDiff, please open an issue with MWE."

#     return nothing
# end

###########

import .FMISensitivity.SciMLSensitivity.ForwardDiff
import .FMISensitivity.SciMLSensitivity.ReverseDiff

import FMICore: isdual, istracked, fd_eltypes, sense_set!, undual, untrack, unsense

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

# check types (Tag, Variable, Number) of ForwardDiff.Dual scalar/vector
function fd_eltypes(e::ForwardDiff.Dual{T, V, N}) where {T, V, N}
    return (T, V, N)
end
function fd_eltypes(e::AbstractVector{<:ForwardDiff.Dual{T, V, N}}) where {T, V, N}
    return (T, V, N)
end

# overwrites a ForwardDiff.Dual in-place 
# inheritates partials
function sense_set!(dst::AbstractArray{<:Float64}, src::AbstractArray{<:ForwardDiff.Dual})
    dst[:] = collect(ForwardDiff.value(e) for e in src)
    return nothing
end
function sense_set!(dst::AbstractArray{<:ForwardDiff.Dual}, src::AbstractArray{<:Float64})
    T, V, N = fd_eltypes(dst)
    dst[:] = collect(ForwardDiff.Dual{T, V, N}(V(src[i]), ForwardDiff.partials(dst[i])    ) for i in 1:length(dst))
    return nothing
end
function sense_set!(dst::ReverseDiff.TrackedArray, src::AbstractArray{<:ForwardDiff.Dual})
    dst[:] = collect(ReverseDiff.TrackedReal(ReverseDiff.value(src[i]), 0.0    ) for i in 1:length(dst))
    return nothing
end
function sense_set!(dst::AbstractArray{<:Float64}, src::ReverseDiff.TrackedArray)
    dst[:] = collect(ReverseDiff.value(e) for e in src)
    return nothing
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

