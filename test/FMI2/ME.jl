# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl

function test_generic(lib, type::fmi2Type)
    cGetTypesPlatform = dlsym(lib, :fmi2GetTypesPlatform)
    test = fmi2GetTypesPlatform(cGetTypesPlatform)
    @test unsafe_string(test) == "default"
    
    ## fmi2GetVersion TODO get Version from modelDescription.xml
    vers = fmi2GetVersion(dlsym(lib, :fmi2GetVersion))
    @test unsafe_string(vers) == "2.0"

    ## fmi2Instantiate
    cInstantiate = dlsym(lib, :fmi2Instantiate)
    compAddr = fmi2Instantiate(cInstantiate, instantiate_args(fmu_path, fmi2TypeModelExchange)...)
    @test compAddr != Ptr{Cvoid}(C_NULL)
    component = fmi2Component(compAddr)

    test_status_ok(fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2False, Unsigned(0), AbstractArray{fmi2String}([])))
    test_status_ok(fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2True, Unsigned(0), AbstractArray{fmi2String}([])))

    ## fmi2SetupExperiment

    test_status_ok(fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(0.0)))



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
    
    

    # Initialization Mode

    
    test_status_ok(fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component))

    fmireference = [fmi2ValueReference(16777220)]
    value = fmi2Real.([0.8])
    test_status_ok(fmi2SetReal(dlsym(lib, :fmi2SetReal), component, fmireference, Csize_t(1), value))

    fmireference = [fmi2ValueReference(16777220)]
    value = zeros(fmi2Real, 1)
    test_status_ok(fmi2GetReal!(dlsym(lib, :fmi2GetReal), component, fmireference, Csize_t(1), value))
    println(value)

    fmireference = [fmi2ValueReference(637534208)]
    value = zeros(fmi2Integer, 1)
    test_status_ok(fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value))
    println(value)

    fmireference = [fmi2ValueReference(637534208)]
    value = fmi2Integer.([typemin(fmi2Integer)])
    test_status_ok(fmi2SetInteger(dlsym(lib, :fmi2SetInteger), component, fmireference, Csize_t(1), value))

    fmireference = [fmi2ValueReference(637534208)]
    value = zeros(fmi2Integer, 1)
    test_status_ok(fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value))
    println(value)

    test_status_ok(fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component))



    




    test_status_ok(fmi2Reset(dlsym(lib, :fmi2Reset), component))


    # # @test fmi2DoStep(component, 0.1) == 0

    # Nach dem Standard sollte das hier nötig sein, ist es aber mit unserer FMU nicht
    fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    test_status_ok(fmi2Terminate(dlsym(lib, :fmi2Terminate), component))

    ## fmi2FreeInstance
    @test isnothing(fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component))



end