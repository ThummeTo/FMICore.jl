#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# BouncingBall
function test_CS(fmu)
    lib = fmu.lib

    component = instantiate(fmu, fmi2TypeCoSimulation)
    @test component != C_NULL

    @test fmi2StatusOK == fmi2SetupExperiment(
        dlsym(lib, :fmi2SetupExperiment),
        component,
        fmi2True,
        fmi2Real(0.01),
        fmi2Real(0.0),
        fmi2False,
        fmi2Real(1.0),
    )
    @test fmi2StatusOK ==
          fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    @test fmi2StatusOK ==
          fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    t = 0.0
    for i = 1:100
        @test fmi2StatusOK ==
              fmi2DoStep(dlsym(lib, :fmi2DoStep), component, t, fmi2Real(0.01), fmi2True)
        t += 0.01
    end

    values = zeros(fmi2Real, 2)
    @test fmi2StatusOK == fmi2GetReal!(
        dlsym(lib, :fmi2GetReal),
        component,
        [BB_H, BB_V],
        Csize_t(2),
        values,
    )
    @test values ≈ [0.236644, -2.255319] atol = 1e-6 # after the first bounce

    value = zeros(fmi2Real, 1)
    GC.@preserve value begin
        @test fmi2StatusOK == fmi2GetRealStatus!(
            dlsym(lib, :fmi2GetRealStatus),
            component,
            fmi2StatusKindLastSuccessfulTime,
            pointer(value),
        )
    end
    @test value[1] ≈ 1.0

    value = ones(fmi2Boolean, 1)
    GC.@preserve value begin
        @test fmi2StatusOK == fmi2GetBooleanStatus!(
            dlsym(lib, :fmi2GetBooleanStatus),
            component,
            fmi2StatusKindTerminated,
            pointer(value),
        )
    end
    @test value == [fmi2False]

    # asynchronous `fmi2DoStep` is not supported by the FMU, so these status kinds are not available
    status = zeros(fmi2Status, 1)
    integer = zeros(fmi2Integer, 1)
    strings = fmi2String[C_NULL]
    GC.@preserve status integer strings begin
        @test fmi2StatusDiscard == fmi2GetStatus!(
            dlsym(lib, :fmi2GetStatus),
            component,
            fmi2StatusKindDoStepStatus,
            pointer(status),
        )
        @test fmi2StatusDiscard == fmi2GetIntegerStatus!(
            dlsym(lib, :fmi2GetIntegerStatus),
            component,
            fmi2StatusKindDoStepStatus,
            pointer(integer),
        )
        @test fmi2StatusDiscard == fmi2GetStringStatus!(
            dlsym(lib, :fmi2GetStringStatus),
            component,
            fmi2StatusKindPendingStatus,
            pointer(strings),
        )
    end

    @test fmi2StatusOK == fmi2Terminate(dlsym(lib, :fmi2Terminate), component)

    @suppress begin
        # expected error: there is no pending (asynchronous) step to cancel
        @test fmi2StatusError == fmi2CancelStep(dlsym(lib, :fmi2CancelStep), component)
    end

    fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component)
end

# Feedthrough
function test_CS_IO(fmu)
    lib = fmu.lib

    component = instantiate(fmu, fmi2TypeCoSimulation)
    @test component != C_NULL
    @test fmi2StatusOK == fmi2SetupExperiment(
        dlsym(lib, :fmi2SetupExperiment),
        component,
        fmi2False,
        fmi2Real(0.0),
        fmi2Real(0.0),
        fmi2False,
        fmi2Real(1.0),
    )
    @test fmi2StatusOK ==
          fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    @test fmi2StatusOK ==
          fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    @suppress begin
        # expected errors: the FMU does not support input/output derivatives
        @test fmi2StatusError == fmi2SetRealInputDerivatives(
            dlsym(lib, :fmi2SetRealInputDerivatives),
            component,
            [FT_REAL_IN],
            Csize_t(1),
            [fmi2Integer(1)],
            fmi2Real[1.0],
        )
        @test fmi2StatusError == fmi2GetRealOutputDerivatives!(
            dlsym(lib, :fmi2GetRealOutputDerivatives),
            component,
            [FT_REAL_OUT],
            Csize_t(1),
            [fmi2Integer(1)],
            zeros(fmi2Real, 1),
        )
    end

    fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component)
end
