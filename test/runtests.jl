#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMICore
using Test

const FMIC = FMICore

@testset "FMICore.jl" begin
    @testset "FMI2" begin
        include(joinpath(@__DIR__, "FMI2", "simple_types.jl"))
    end
end