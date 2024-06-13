# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl

function test_ME(lib, cblibpath)
    component = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test_me"), fmi2TypeModelExchange, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(get_callbacks(cblibpath))), fmi2Boolean(false), fmi2Boolean(false))
    @test component != C_NULL

    fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    test_status_ok(fmi2EnterEventMode(dlsym(lib, :fmi2Instantiate), component))

    eventInfo = fmi2EventInfo() 
    ptr = Ptr{fmi2EventInfo}(pointer_from_objref(eventInfo))

    test_status_ok(fmi2NewDiscreteStates!(dlsym(lib, :fmi2NewDiscreteStates), component, ptr))
    
    test_status_ok(fmi2EnterContinuousTimeMode(dlsym(lib, :fmi2EnterContinuousTimeMode), component))

    enterEventMode = fmi2Boolean(false)
    terminateSimulation = fmi2Boolean(false)
    test_status_ok(fmi2CompletedIntegratorStep!(dlsym(lib, :fmi2CompletedIntegratorStep), component, fmi2Boolean(false), pointer([enterEventMode]), pointer([terminateSimulation])))

    test_status_ok(fmi2SetTime(dlsym(lib, :fmi2SetTime), component, fmi2Real(0.0)))

    n_states = Csize_t(2)
    state_arr = zeros(fmi2Real, 2)
    test_status_ok(fmi2GetContinuousStates!(dlsym(lib, :fmi2GetContinuousStates), component,state_arr, n_states))

    state_arr[2] = 2.0
    test_status_ok(fmi2SetContinuousStates(dlsym(lib, :fmi2SetContinuousStates), component,state_arr, n_states))

    state_arr = zeros(fmi2Real, 2)
    test_status_ok(fmi2GetContinuousStates!(dlsym(lib, :fmi2GetContinuousStates), component,state_arr, n_states))
    @test state_arr[2] == 2.0

    n_indicators = Csize_t(2)
    indicator_arr = zeros(fmi2Real, 2)
    test_status_ok(fmi2GetEventIndicators!(dlsym(lib, :fmi2GetEventIndicators), component,indicator_arr, n_indicators))

    nom_state_arr = zeros(fmi2Real, 2)
    test_status_ok(fmi2GetNominalsOfContinuousStates!(dlsym(lib, :fmi2GetNominalsOfContinuousStates), component, nom_state_arr, n_states))

    der_arr = zeros(fmi2Real, 2)
    test_status_ok(fmi2GetDerivatives!(dlsym(lib, :fmi2GetDerivatives), component,der_arr, n_states))
    # Acceleration should be equal to Gravity in this FMU
    @test der_arr[2] ≈ -9.81

    test_status_ok(fmi2Terminate(dlsym(lib, :fmi2Terminate), component))
end
