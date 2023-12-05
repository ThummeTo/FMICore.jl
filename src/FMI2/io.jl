#
# Copyright (c) 2022 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.

# [ToDo] This currently fails with DifferentiableFlatten
# mutable struct FMU2EvaluationOutput{A <: AbstractArray{<:Real, 1}, B <: AbstractArray{<:Real, 1}, C <: AbstractArray{<:Real, 1}} <: AbstractArray{Real, 1}
#     dx::A
#     y::B
#     ec::C

#     function FMU2EvaluationOutput{A, B, C}(dx::A, y::B, ec::C) where {A <: AbstractArray{<:Real, 1}, B <: AbstractArray{<:Real, 1}, C <: AbstractArray{<:Real, 1}}
#         return new{A, B, C}(dx, y, ec)
#     end

#     function FMU2EvaluationOutput(dx::A, y::B, ec::C) where {A <: AbstractArray{<:Real, 1}, B <: AbstractArray{<:Real, 1}, C <: AbstractArray{<:Real, 1}}
#         return FMU2EvaluationOutput{A, B, C}(dx, y, ec)
#     end

#     function FMU2EvaluationOutput() 
#         return FMU2EvaluationOutput(EMPTY_fmi2Real, EMPTY_fmi2Real, EMPTY_fmi2Real)
#     end
# end

mutable struct FMU2EvaluationOutput{T} <: AbstractArray{Real, 1}
    dx::AbstractArray{<:T,1}
    y::AbstractArray{<:T,1}
    ec::AbstractArray{<:T,1}

    ec_visible::Bool    # switch visability of event indictors on and off (AD needs them visible, but user not)

    function FMU2EvaluationOutput{T}(dx::AbstractArray, y::AbstractArray, ec::AbstractArray, ec_visible::Bool) where {T}
        return new{T}(dx, y, ec, ec_visible)
    end

    function FMU2EvaluationOutput(dx::AbstractArray{T}, y::AbstractArray{T}, ec::AbstractArray{T}, ec_visible::Bool) where {T}
        return FMU2EvaluationOutput{T}(dx, y, ec, ec_visible)
    end

    function FMU2EvaluationOutput{T}(ec_visible::Bool; initType::DataType=T) where {T}
        return FMU2EvaluationOutput{T}(Array{initType,1}(), Array{initType,1}(), Array{initType,1}(), ec_visible)
    end

    function FMU2EvaluationOutput(ec_visible::Bool) 
        return FMU2EvaluationOutput{fmi2Real}(EMPTY_fmi2Real, EMPTY_fmi2Real, EMPTY_fmi2Real, ec_visible)
    end
end

import ChainRulesCore: ZeroTangent, NoTangent

function Base.setproperty!(out::FMU2EvaluationOutput, var::Symbol, value::ZeroTangent)
    return Base.setproperty!(out, var, EMPTY_fmi2Real)
end

function Base.setproperty!(out::FMU2EvaluationOutput, var::Symbol, value::NoTangent)
    return Base.setproperty!(out, var, EMPTY_fmi2Real)
end

# function Base.hasproperty(::FMU2EvaluationOutput, var::Symbol)
#     return var ∈ (:dx, :y, :ec)
# end

# function Base.getproperty(out::FMU2EvaluationOutput, var::Symbol)
#     return Base.getfield(out, var)
# end

function Base.length(out::FMU2EvaluationOutput)
    len_dx = length(out.dx)
    len_y  = length(out.y)
    len_ec = out.ec_visible ? length(out.ec) : 0
    return len_dx+len_y+len_ec
end

function Base.getindex(out::FMU2EvaluationOutput, ind::Int)
    @assert ind >= 1 "`getindex` for index $(ind) <= 0 not supported."

    len_dx = length(out.dx)
    if ind <= len_dx
        return out.dx[ind]
    end
    ind -= len_dx
    
    len_y  = length(out.y)
    if ind <= len_y
        return out.y[ind]
    end
    ind -= len_y
    
    len_ec = out.ec_visible ? length(out.ec) : 0
    if ind <= len_ec
        return out.ec[ind]
    end
    ind -= len_ec

    @assert false "`getindex` for index $(ind+len_y+len_dx+len_ec) out of bounds [$(length(out))]."
end

function Base.getindex(out::FMU2EvaluationOutput, ind::UnitRange)
    # [ToDo] Could be improved.
    return collect(Base.getindex(out, i) for i in ind)
end

function Base.setindex!(out::FMU2EvaluationOutput, v, index::Int) 
    
    len_dx = length(out.dx)
    if index <= len_dx 
        return setindex!(out.dx, v, index)
    end
    index -= len_dx 
    
    len_y = length(out.y)
    if index <= len_y
        return setindex!(out.y, v, index)
    end
    index -= len_y

    len_ec = out.ec_visible ? length(out.ec) : 0
    if index <= len_ec
        return setindex!(out.ec, v, index)
    end
    index -= len_ec
    
    @assert false "`setindex!` for index $(ind+len_y+len_dx+len_ec) out of bounds [$(length(out))]."
end

function Base.size(out::FMU2EvaluationOutput)
    return (length(out),)
end

function Base.IndexStyle(::FMU2EvaluationOutput)
    return IndexLinear()
end

function Base.unaliascopy(out::FMU2EvaluationOutput)
    return FMU2EvaluationOutput(copy(out.dx), copy(out.y), copy(out.ec), out.ec_visible)
end

#####

mutable struct FMU2ADOutput{T} <: AbstractArray{Real,1}
    buffer::AbstractArray{<:T,1}

    len_dx::Int
    len_y::Int
    len_ec::Int

    function FMU2ADOutput{T}(; initType::DataType=T) where {T}
        return new{T}(Array{initType,1}(), 0, 0, 0)
    end

    function FMU2ADOutput() 
        return FMU2ADOutput{fmi2Real}()
    end
end

import ChainRulesCore: ZeroTangent, NoTangent

function Base.setproperty!(out::FMU2ADOutput, var::Symbol, value::ZeroTangent)
    return Base.setproperty!(out, var, EMPTY_fmi2Real)
end

function Base.setproperty!(out::FMU2ADOutput, var::Symbol, value::NoTangent)
    return Base.setproperty!(out, var, EMPTY_fmi2Real)
end

function Base.hasproperty(::FMU2ADOutput, var::Symbol)
    return var ∈ (:dx, :y, :ec, :buffer, :len_dx, :len_y, :len_ex, :ec_visible)
end

function Base.getproperty(out::FMU2ADOutput, var::Symbol)

    if var == :dx 
        return @view(out.buffer[1:out.len_dx])
    elseif var == :y 
        return @view(out.buffer[out.len_dx+1:out.len_dx+out.len_y])
    elseif var == :ec 
        return @view(out.buffer[out.len_dx+out.len_y+1:end])
    else
        return Base.getfield(out, var)
    end
end

function Base.length(out::FMU2ADOutput)
    len_dx = out.len_dx
    len_y  = out.len_y
    len_ec = out.len_ec
    return len_dx+len_y+len_ec
end

function Base.getindex(out::FMU2ADOutput, ind::Int)
    return getindex(out.buffer, ind)
end

function Base.getindex(out::FMU2ADOutput, ind::UnitRange)
    # [ToDo] Could be improved.
    return collect(Base.getindex(out, i) for i in ind)
end

function Base.setindex!(out::FMU2ADOutput, v, index::Int) 
    return setindex!(out.buffer, v, index)
end

function Base.size(out::FMU2ADOutput)
    return (length(out),)
end

function Base.IndexStyle(::FMU2ADOutput)
    return IndexLinear()
end

function Base.unaliascopy(out::FMU2ADOutput)
    return FMU2ADOutput(copy(out.buffer), out.len_dx, out.len_y, out.len_ec)
end

#####

mutable struct FMU2EvaluationInput <: AbstractVector{Real}
    
    x::AbstractArray{<:Real}
    u::AbstractVector{<:Real}
    p::AbstractVector{<:Real}
    t::Real

    function FMU2EvaluationInput(x::AbstractArray{<:Real}, u::AbstractArray{<:Real}, p::AbstractArray{<:Real}, t::Real) 
        return new(x, u, p, t)
    end

    function FMU2EvaluationInput() 
        return FMU2EvaluationInput(EMPTY_fmi2Real, EMPTY_fmi2Real, EMPTY_fmi2Real, 0.0)
    end
end