#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

mutable struct FMUJacobian{R, V} 
    mtx::Matrix{R}
    valid::Bool 

    ∂f_refs::AbstractArray{<:V}
    ∂x_refs::AbstractArray{<:V}

    updateFct!

    b::Vector{R}
    c::Vector{R}

    numUpdates::Integer
    numJVPs::Integer
    numVJPs::Integer

    function FMUJacobian{R, V}(∂f_refs::AbstractArray{<:V}, ∂x_refs::AbstractArray{<:V}, updateFct!) where {R, V}
        inst = new{R, V}()
        inst.mtx = zeros(R, length(∂f_refs), length(∂x_refs))
        inst.b = zeros(R, length(∂f_refs))
        inst.c = zeros(R, length(∂x_refs))
        inst.valid = false 
        inst.∂f_refs = ∂f_refs
        inst.∂x_refs = ∂x_refs
        inst.updateFct! = updateFct!

        inst.numUpdates = 0
        inst.numJVPs = 0
        inst.numVJPs = 0

        return inst
    end
end

function update!(jac::FMUJacobian{R, V}; ∂f_refs=jac.∂f_refs, ∂x_refs=jac.∂x_refs) where {R, V}

    if ∂f_refs != jac.∂f_refs || ∂x_refs != jac.∂x_refs
        if size(jac.mtx) != (length(∂f_refs), length(∂x_refs))
            jac.mtx = zeros(R, length(∂f_refs), length(∂x_refs))
        end

        if size(jac.b) != (length(∂f_refs),)
            jac.b = zeros(R, length(∂f_refs))
        end

        if size(jac.c) != (length(∂x_refs),)
            jac.c = zeros(R, length(∂x_refs))
        end

        jac.valid = false
    end

    if !jac.valid
        jac.updateFct!(jac, ∂f_refs, ∂x_refs)
        jac.numUpdates += 1
        jac.valid = true
    end
    return nothing
end

function invalidate!(jac::FMUJacobian)
    jac.valid = false
    return nothing
end

function jvp!(jac::FMUJacobian, x; ∂f_refs=jac.∂f_refs, ∂x_refs=jac.∂x_refs)
    update!(jac; ∂f_refs=∂f_refs, ∂x_refs=∂x_refs)
    jac.b[:] = jac.mtx * x
    jac.numJVPs += 1
    return jac.b
end

function vjp!(jac::FMUJacobian, x; ∂f_refs=jac.∂f_refs, ∂x_refs=jac.∂x_refs)
    update!(jac; ∂f_refs=∂f_refs, ∂x_refs=∂x_refs)
    jac.c[:] = jac.mtx' * x
    jac.numVJPs += 1
    return jac.c
end