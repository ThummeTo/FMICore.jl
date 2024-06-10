# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl

function test_generic(lib, type::fmi2Type)
    # Tests missing for fmi2<Set, Get><Boolean, String> because the FMU we are testing with doesnt have such variables

    cGetTypesPlatform = dlsym(lib, :fmi2GetTypesPlatform)
    test = fmi2GetTypesPlatform(cGetTypesPlatform)
    @test unsafe_string(test) == "default"
    
    ## fmi2GetVersion TODO get Version from modelDescription.xml
    vers = fmi2GetVersion(dlsym(lib, :fmi2GetVersion))
    @test unsafe_string(vers) == "2.0"

    # fmi2Instantiate

    callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test2"), type, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), fmi2Boolean(true), fmi2Boolean(false))
    @test compAddr != Ptr{Cvoid}(C_NULL)
    component = fmi2Component(compAddr)

    test_status_ok(fmi2Reset(dlsym(lib, :fmi2Reset), component))



    test_status_ok(fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2False, Unsigned(0), AbstractArray{fmi2String}([])))
    test_status_ok(fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2True, Unsigned(0), AbstractArray{fmi2String}([])))

    # fmi2SetupExperiment

    test_status_ok(fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(1.0)))



    # get, set and free State
    state = fmi2FMUstate()
    stateRef = Ref(state)

    test_status_ok(fmi2GetFMUstate!(dlsym(lib, :fmi2GetFMUstate), component, stateRef))
    state = stateRef[]

    @test typeof(state) == fmi2FMUstate
    
    test_status_ok(fmi2SetFMUstate(dlsym(lib, :fmi2SetFMUstate), component, state))
    stateRef = Ref(state)

    size_ptr = Ref{Csize_t}(0)
    test_status_ok(fmi2SerializedFMUstateSize!(dlsym(lib, :fmi2SerializedFMUstateSize), component, state, size_ptr))
    size = size_ptr[]

    serializedState = Array{fmi2Byte}(zeros(size))
    test_status_ok(fmi2SerializeFMUstate!(dlsym(lib,:fmi2SerializeFMUstate), component, state, serializedState, size))
    
    test_status_ok(fmi2DeSerializeFMUstate!(dlsym(lib, :fmi2DeSerializeFMUstate), component, serializedState, size, stateRef))

    @test stateRef[] != C_NULL
    test_status_ok(fmi2FreeFMUstate(dlsym(lib,:fmi2FreeFMUstate), component, stateRef))
    @test stateRef[] == C_NULL
    
    

    # # Initialization Mode
    
    test_status_ok(fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component))

    fmireference = [fmi2ValueReference(16777220)]
    test_status_ok(fmi2SetReal(dlsym(lib, :fmi2SetReal), component, fmireference, Csize_t(1), fmi2Real.([0.8])))

    fmireference = [fmi2ValueReference(16777220)]
    value = zeros(fmi2Real, 1)
    test_status_ok(fmi2GetReal!(dlsym(lib, :fmi2GetReal), component, fmireference, Csize_t(1), value))
    @test value == fmi2Real.([0.8])

    fmireference = [fmi2ValueReference(637534208)]
    value = zeros(fmi2Integer, 1)
    test_status_ok(fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value))

    fmireference = [fmi2ValueReference(637534208)]
    test_status_ok(fmi2SetInteger(dlsym(lib, :fmi2SetInteger), component, fmireference, Csize_t(1), fmi2Integer.([typemin(fmi2Integer)])))

    fmireference = [fmi2ValueReference(637534208)]
    value = zeros(fmi2Integer, 1)
    test_status_ok(fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value))
    @test value == fmi2Integer.([typemin(fmi2Integer)])

    # calculate ∂p/∂p (x)
    posreference = [fmi2ValueReference(33554432)]
    delta_x = fmi2Real.([randn()])
    result = zeros(fmi2Real, 1)
    test_status_ok(fmi2GetDirectionalDerivative!(dlsym(lib,:fmi2GetDirectionalDerivative), component, posreference, Csize_t(1), posreference, Csize_t(1), delta_x, result))

    # ∂p/∂p(x) should be just x for any x
    @test result ≈ delta_x

    test_status_ok(fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component))

    # # # fmi2FreeInstance
    @test isnothing(fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component))


end

function test_ME(lib)
    callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test2"), fmi2TypeModelExchange, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), fmi2Boolean(true), fmi2Boolean(false))
    component = fmi2Component(compAddr)

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

function test_CS(lib)
    test_terminate_cs(lib)
    # ptrLogger = @cfunction(fmi2CallbackLogger, Cvoid, (Ptr{FMU2ComponentEnvironment}, Ptr{Cchar}, Cuint, Ptr{Cchar}, Ptr{Cchar}))
    # callbackFunctions = fmi2CallbackFunctions(ptrLogger, C_NULL, C_NULL, C_NULL, C_NULL)
    # callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    # compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test2"), fmi2TypeCoSimulation, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), fmi2Boolean(false), fmi2Boolean(false))
    # @test compAddr != C_NULL
    # component = fmi2Component(compAddr)

    # test_status_ok(fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(1.0)))

    
    # fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    # fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)
    # # test_status_ok(fmi2Reset(dlsym(lib, :fmi2Reset), component))
    


    # # status = [fmi2StatusError]
    # # test_status_ok(fmi2GetStatus!(dlsym(lib, :fmi2GetStatus), component, fmi2StatusKindDoStepStatus, pointer(status)))
    # # println(status)


    # test_status_ok(fmi2DoStep(dlsym(lib, :fmi2DoStep), component, fmi2Real(0.0), fmi2Real(0.1), fmi2False))
    # # # step = fmi2DoStep(dlsym(lib, :fmi2DoStep), component, fmi2Real(0.0), fmi2Real(-0.1), fmi2False)
    

    # test_status_ok(fmi2Terminate(dlsym(lib, :fmi2Terminate), component))

end

function test_terminate_cs(lib)
    callbackFunctions = fmi2CallbackFunctions(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    compAddr = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test2"), fmi2TypeCoSimulation, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(callbackFunctions)), fmi2Boolean(false), fmi2Boolean(false))
    @test compAddr != C_NULL
    component = fmi2Component(compAddr)

    test_status_ok(fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(1.0)))

    
    fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)
    test_status_ok(fmi2DoStep(dlsym(lib, :fmi2DoStep), component, fmi2Real(0.0), fmi2Real(0.1), fmi2False))
    test_status_ok(fmi2Terminate(dlsym(lib, :fmi2Terminate), component))
end