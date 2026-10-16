#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# BouncingBall
function test_ME(fmu)
    lib = fmu.lib

    component = instantiate(fmu, fmi2TypeModelExchange; loggingOn = true)
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

    eventInfo = Ref(fmi2EventInfo())
    GC.@preserve eventInfo begin
        @test fmi2StatusOK == fmi2NewDiscreteStates!(
            dlsym(lib, :fmi2NewDiscreteStates),
            component,
            Base.unsafe_convert(Ptr{fmi2EventInfo}, eventInfo),
        )
    end
    @test eventInfo[].newDiscreteStatesNeeded == fmi2False

    @test fmi2StatusOK ==
          fmi2EnterContinuousTimeMode(dlsym(lib, :fmi2EnterContinuousTimeMode), component)

    flags = ones(fmi2Boolean, 2)
    GC.@preserve flags begin
        @test fmi2StatusOK == fmi2CompletedIntegratorStep!(
            dlsym(lib, :fmi2CompletedIntegratorStep),
            component,
            fmi2True,
            pointer(flags, 1),
            pointer(flags, 2),
        )
    end
    @test flags == [fmi2False, fmi2False] # enterEventMode, terminateSimulation

    @test fmi2StatusOK == fmi2SetTime(dlsym(lib, :fmi2SetTime), component, fmi2Real(0.0))

    n_states = Csize_t(2)
    x = zeros(fmi2Real, 2)
    @test fmi2StatusOK == fmi2GetContinuousStates!(
        dlsym(lib, :fmi2GetContinuousStates),
        component,
        x,
        n_states,
    )
    @test x == [1.0, 0.0]

    @test fmi2StatusOK == fmi2SetContinuousStates(
        dlsym(lib, :fmi2SetContinuousStates),
        component,
        fmi2Real[1.0, 2.0],
        n_states,
    )

    # pointer arguments
    x = zeros(fmi2Real, 2)
    GC.@preserve x begin
        @test fmi2StatusOK == fmi2GetContinuousStates!(
            dlsym(lib, :fmi2GetContinuousStates),
            component,
            pointer(x),
            n_states,
        )
    end
    @test x == [1.0, 2.0]

    z = zeros(fmi2Real, 1)
    @test fmi2StatusOK == fmi2GetEventIndicators!(
        dlsym(lib, :fmi2GetEventIndicators),
        component,
        z,
        Csize_t(1),
    )
    @test z == [1.0] # height

    nominals = zeros(fmi2Real, 2)
    @test fmi2StatusOK == fmi2GetNominalsOfContinuousStates!(
        dlsym(lib, :fmi2GetNominalsOfContinuousStates),
        component,
        nominals,
        n_states,
    )
    @test nominals == [1.0, 1.0]

    dx = zeros(fmi2Real, 2)
    @test fmi2StatusOK ==
          fmi2GetDerivatives!(dlsym(lib, :fmi2GetDerivatives), component, dx, n_states)
    @test dx ≈ [2.0, -9.81]

    @test fmi2StatusOK == fmi2EnterEventMode(dlsym(lib, :fmi2EnterEventMode), component)
    @test fmi2StatusOK == fmi2Terminate(dlsym(lib, :fmi2Terminate), component)
    fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component)
end
