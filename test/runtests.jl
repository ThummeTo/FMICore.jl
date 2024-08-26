#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMICore
using Test
using Downloads, ZipFile

@testset "FMICore.jl" begin
    @testset "FMI2" begin
        include("FMI2/cfunc.jl")
    end
    @testset "FMI3" begin
        include("FMI3/cfunc.jl")
    end
end
