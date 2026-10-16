#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using FMICore
using Test

# [Note] Currently NOT tested:
#   FMI 3
#   - Scheduled Execution: `fmi3InstantiateScheduledExecution`, `fmi3ActivateModelPartition`
#   - Clocks: `fmi3GetClock!`, `fmi3SetClock`, `fmi3GetIntervalDecimal!`, `fmi3SetIntervalDecimal`,
#     `fmi3GetIntervalFraction!`, `fmi3SetIntervalFraction`, `fmi3GetShiftDecimal!`, `fmi3GetShiftFraction!`
#   - Configuration Mode: `fmi3EnterConfigurationMode`, `fmi3ExitConfigurationMode`
#   - `fmi3EvaluateDiscreteStates`
#   - Variable dependencies: `fmi3GetNumberOfVariableDependencies!`, `fmi3GetVariableDependencies!`
#   - the pre-release signature of `fmi3EnterEventMode` (with `rootsFound`), only the FMI 3.0 signature is tested
#   FMI 2
#   - `fmi2SetRealInputDerivatives`, `fmi2GetRealOutputDerivatives`, `fmi2CancelStep` and the status getters
#     `fmi2GetStatus!`, `fmi2GetIntegerStatus!`, `fmi2GetStringStatus!` are only tested for their error/discard
#     return, because the Reference FMUs don't support them
#   Both
#   - the Reference FMU tests are skipped on platforms without Reference FMU binaries,
#     FMI 2 additionally on architectures where `fmi2Real != Cdouble` (32-bit)

# shared helpers (Reference FMUs)
include("utils.jl")

@testset "FMICore.jl" begin
    @testset "FMI2" begin
        include("FMI2/cfunc.jl")
    end
    @testset "FMI3" begin
        include("FMI3/cfunc.jl")
    end
end
