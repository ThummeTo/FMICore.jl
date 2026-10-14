#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# BouncingBall
function test_CS(fmu)
    lib = fmu.lib

    instance = instantiate(fmu, fmi3TypeCoSimulation)
    @test instance != C_NULL

    @test fmi3StatusOK == fmi3EnterInitializationMode(
        dlsym(lib, :fmi3EnterInitializationMode),
        instance,
        fmi3True,
        fmi3Float64(0.01),
        fmi3Float64(0.0),
        fmi3False,
        fmi3Float64(1.0),
    )
    @test fmi3StatusOK ==
          fmi3ExitInitializationMode(dlsym(lib, :fmi3ExitInitializationMode), instance)

    eventHandlingNeeded = Ref(fmi3True)
    terminateSimulation = Ref(fmi3True)
    earlyReturn = Ref(fmi3True)
    lastSuccessfulTime = Ref(fmi3Float64(0.0))
    for i = 1:100
        @test fmi3StatusOK == fmi3DoStep!(
            dlsym(lib, :fmi3DoStep),
            instance,
            lastSuccessfulTime[],
            fmi3Float64(0.01),
            fmi3True,
            eventHandlingNeeded,
            terminateSimulation,
            earlyReturn,
            lastSuccessfulTime,
        )
    end
    @test lastSuccessfulTime[] ≈ 1.0
    @test terminateSimulation[] == fmi3False
    @test earlyReturn[] == fmi3False

    values = zeros(fmi3Float64, 2)
    @test fmi3StatusOK == fmi3GetFloat64!(
        dlsym(lib, :fmi3GetFloat64),
        instance,
        [BB_H, BB_V],
        Csize_t(2),
        values,
        Csize_t(2),
    )
    @test values ≈ [0.236644, -2.255319] atol = 1e-6 # after the first bounce

    # the first derivative of the height is the velocity
    derivative = zeros(fmi3Float64, 1)
    @test fmi3StatusOK == fmi3GetOutputDerivatives!(
        dlsym(lib, :fmi3GetOutputDerivatives),
        instance,
        [BB_H],
        Csize_t(1),
        fmi3Int32[1],
        derivative,
        Csize_t(1),
    )
    @test derivative ≈ [values[2]]

    @test fmi3StatusOK == fmi3Terminate(dlsym(lib, :fmi3Terminate), instance)

    # expected error: the FMU is not in event mode (`eventModeUsed = false`)
    @test fmi3StatusError == fmi3EnterStepMode(dlsym(lib, :fmi3EnterStepMode), instance)

    fmi3FreeInstance(dlsym(lib, :fmi3FreeInstance), instance)
end
