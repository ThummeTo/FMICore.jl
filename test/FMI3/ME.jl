#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function updateDiscreteStates(lib, instance)
    flags = [Ref(fmi3True) for _ = 1:5]
    nextEventTime = Ref(fmi3Float64(0.0))
    status = fmi3UpdateDiscreteStates(
        dlsym(lib, :fmi3UpdateDiscreteStates),
        instance,
        flags...,
        nextEventTime,
    )
    return status, [flag[] for flag in flags]
end

# BouncingBall
function test_ME(fmu)
    lib = fmu.lib

    instance = instantiate(fmu, fmi3TypeModelExchange; loggingOn = true)
    @test instance != C_NULL

    @test fmi3StatusOK == fmi3EnterInitializationMode(
        dlsym(lib, :fmi3EnterInitializationMode),
        instance,
        fmi3False,
        fmi3Float64(0.0),
        fmi3Float64(0.0),
        fmi3False,
        fmi3Float64(0.0),
    )
    @test fmi3StatusOK ==
          fmi3ExitInitializationMode(dlsym(lib, :fmi3ExitInitializationMode), instance)

    status, flags = updateDiscreteStates(lib, instance)
    @test status == fmi3StatusOK
    @test all(flags .== fmi3False)

    @test fmi3StatusOK ==
          fmi3EnterContinuousTimeMode(dlsym(lib, :fmi3EnterContinuousTimeMode), instance)

    n = Ref(Csize_t(0))
    @test fmi3StatusOK == fmi3GetNumberOfContinuousStates!(
        dlsym(lib, :fmi3GetNumberOfContinuousStates),
        instance,
        n,
    )
    @test n[] == 2
    @test fmi3StatusOK == fmi3GetNumberOfEventIndicators!(
        dlsym(lib, :fmi3GetNumberOfEventIndicators),
        instance,
        n,
    )
    @test n[] == 1

    enterEventMode = Ref(fmi3True)
    terminateSimulation = Ref(fmi3True)
    @test fmi3StatusOK == fmi3CompletedIntegratorStep!(
        dlsym(lib, :fmi3CompletedIntegratorStep),
        instance,
        fmi3True,
        enterEventMode,
        terminateSimulation,
    )
    @test enterEventMode[] == fmi3False
    @test terminateSimulation[] == fmi3False

    @test fmi3StatusOK == fmi3SetTime(dlsym(lib, :fmi3SetTime), instance, fmi3Float64(0.0))

    n_states = Csize_t(2)
    x = zeros(fmi3Float64, 2)
    @test fmi3StatusOK == fmi3GetContinuousStates!(
        dlsym(lib, :fmi3GetContinuousStates),
        instance,
        x,
        n_states,
    )
    @test x == [1.0, 0.0]

    @test fmi3StatusOK == fmi3SetContinuousStates(
        dlsym(lib, :fmi3SetContinuousStates),
        instance,
        fmi3Float64[1.0, 2.0],
        n_states,
    )

    # pointer arguments
    x = zeros(fmi3Float64, 2)
    GC.@preserve x begin
        @test fmi3StatusOK == fmi3GetContinuousStates!(
            dlsym(lib, :fmi3GetContinuousStates),
            instance,
            pointer(x),
            n_states,
        )
    end
    @test x == [1.0, 2.0]

    z = zeros(fmi3Float64, 1)
    @test fmi3StatusOK == fmi3GetEventIndicators!(
        dlsym(lib, :fmi3GetEventIndicators),
        instance,
        z,
        Csize_t(1),
    )
    @test z == [1.0] # height

    nominals = zeros(fmi3Float64, 2)
    @test fmi3StatusOK == fmi3GetNominalsOfContinuousStates!(
        dlsym(lib, :fmi3GetNominalsOfContinuousStates),
        instance,
        nominals,
        n_states,
    )
    @test nominals == [1.0, 1.0]

    dx = zeros(fmi3Float64, 2)
    @test fmi3StatusOK == fmi3GetContinuousStateDerivatives!(
        dlsym(lib, :fmi3GetContinuousStateDerivatives),
        instance,
        dx,
        n_states,
    )
    @test dx ≈ [2.0, -9.81]

    # FMI 3.0 signature
    @test fmi3StatusOK == fmi3EnterEventMode(dlsym(lib, :fmi3EnterEventMode), instance)
    status, flags = updateDiscreteStates(lib, instance)
    @test status == fmi3StatusOK

    @test fmi3StatusOK == fmi3Terminate(dlsym(lib, :fmi3Terminate), instance)
    fmi3FreeInstance(dlsym(lib, :fmi3FreeInstance), instance)
end
