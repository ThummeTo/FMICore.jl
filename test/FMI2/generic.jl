# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl, Suppressor

function test_generic(lib, cblibpath, type::fmi2Type)
    # Tests missing for fmi2<Set, Get><Boolean, String> because the FMU we are testing with doesnt have such variables

    cGetTypesPlatform = dlsym(lib, :fmi2GetTypesPlatform)
    test = fmi2GetTypesPlatform(cGetTypesPlatform)
    @test unsafe_string(test) == "default"
    
    ## fmi2GetVersion TODO get Version from modelDescription.xml
    vers = fmi2GetVersion(dlsym(lib, :fmi2GetVersion))
    @test unsafe_string(vers) == "2.0"

    # fmi2Instantiate

    component = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test_generic"), type, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(get_callbacks(cblibpath))), fmi2Boolean(false), fmi2Boolean(false))
    @test component != C_NULL

    @test fmi2StatusOK == fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2False, Unsigned(0), AbstractArray{fmi2String}([]))
    @test fmi2StatusOK == fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2True, Unsigned(0), AbstractArray{fmi2String}([]))

    # fmi2SetupExperiment

    @test fmi2StatusOK == fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(1.0))



    # get, set and free State
    state = fmi2FMUstate()
    stateRef = Ref(state)

    @test fmi2StatusOK == fmi2GetFMUstate!(dlsym(lib, :fmi2GetFMUstate), component, stateRef)
    state = stateRef[]

    @test typeof(state) == fmi2FMUstate
    
    @test fmi2StatusOK == fmi2SetFMUstate(dlsym(lib, :fmi2SetFMUstate), component, state)
    stateRef = Ref(state)

    size_ptr = Ref{Csize_t}(0)
    @test fmi2StatusOK == fmi2SerializedFMUstateSize!(dlsym(lib, :fmi2SerializedFMUstateSize), component, state, size_ptr)
    size = size_ptr[]

    serializedState = Array{fmi2Byte}(zeros(size))
    @test fmi2StatusOK == fmi2SerializeFMUstate!(dlsym(lib,:fmi2SerializeFMUstate), component, state, serializedState, size)
    
    @test fmi2StatusOK == fmi2DeSerializeFMUstate!(dlsym(lib, :fmi2DeSerializeFMUstate), component, serializedState, size, stateRef)

    @test stateRef[] != C_NULL
    @test fmi2StatusOK == fmi2FreeFMUstate(dlsym(lib,:fmi2FreeFMUstate), component, stateRef)
    @test stateRef[] == C_NULL
    
    

    # # Initialization Mode
    
    @test fmi2StatusOK == fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)

    fmireference = [fmi2ValueReference(16777220)]
    @test fmi2StatusOK == fmi2SetReal(dlsym(lib, :fmi2SetReal), component, fmireference, Csize_t(1), fmi2Real.([0.8]))

    fmireference = [fmi2ValueReference(16777220)]
    value = zeros(fmi2Real, 1)
    @test fmi2StatusOK == fmi2GetReal!(dlsym(lib, :fmi2GetReal), component, fmireference, Csize_t(1), value)
    @test value == fmi2Real.([0.8])

    fmireference = [fmi2ValueReference(637534208)]
    value = zeros(fmi2Integer, 1)
    @test fmi2StatusOK == fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value)

    fmireference = [fmi2ValueReference(637534208)]
    @test fmi2StatusOK == fmi2SetInteger(dlsym(lib, :fmi2SetInteger), component, fmireference, Csize_t(1), fmi2Integer.([typemin(fmi2Integer)]))

    fmireference = [fmi2ValueReference(637534208)]
    value = zeros(fmi2Integer, 1)
    @test fmi2StatusOK == fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value)
    @test value == fmi2Integer.([typemin(fmi2Integer)])

    # calculate ∂p/∂p (x)
    posreference = [fmi2ValueReference(33554432)]
    delta_x = fmi2Real.([randn()])
    result = zeros(fmi2Real, 1)
    @test fmi2StatusOK == fmi2GetDirectionalDerivative!(dlsym(lib,:fmi2GetDirectionalDerivative), component, posreference, Csize_t(1), posreference, Csize_t(1), delta_x, result)
    # ∂p/∂p(x) should be just x for any x
    if Sys.WORD_SIZE == 64
        # GetDirectionalDerivative behaves weirdly on 32 Bit
        @test result ≈ delta_x
    end
    
    @test fmi2StatusOK == fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)
    @suppress begin
    # Suppressing the CVODE-Stats that are printed here in CS Mode
        @test fmi2StatusOK == fmi2Reset(dlsym(lib, :fmi2Reset), component)
    end

    # # # fmi2FreeInstance
    @test isnothing(fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component))

end

function test_generic_io(lib, cblibpath, type::fmi2Type)
    component = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test_generic_io"), type, pointer("{95a6399d-38c5-4504-b3f3-98319bd94ce6}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(get_callbacks(cblibpath))), fmi2Boolean(false), fmi2Boolean(false))
    @test component != C_NULL
    @test fmi2StatusOK == fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(1.0))

    @test fmi2StatusOK == fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)

    fmireference = [fmi2ValueReference(16777216)]
    @test fmi2StatusOK == fmi2SetReal(dlsym(lib, :fmi2SetReal), component, fmireference, Csize_t(1), fmi2Real.([0.8]))

    value = zeros(fmi2Real, 1)
    @test fmi2StatusOK == fmi2GetReal!(dlsym(lib, :fmi2GetReal), component, fmireference, Csize_t(1), value)
    @test value == fmi2Real.([0.8])

    fmireference = [fmi2ValueReference(16777217)]
    value = zeros(fmi2Integer, 1)
    @test fmi2StatusOK == fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value)

    @test fmi2StatusOK == fmi2SetInteger(dlsym(lib, :fmi2SetInteger), component, fmireference, Csize_t(1), fmi2Integer.([typemin(fmi2Integer)]))

    value = zeros(fmi2Integer, 1)
    @test fmi2StatusOK == fmi2GetInteger!(dlsym(lib, :fmi2GetInteger), component, fmireference, Csize_t(1), value)
    @test value == fmi2Integer.([typemin(fmi2Integer)])

    fmireference = [fmi2ValueReference(16777218)]
    @test fmi2StatusOK == fmi2SetBoolean(dlsym(lib, :fmi2SetBoolean), component, fmireference, Csize_t(1), fmi2Boolean.([false]))

    value = zeros(fmi2Boolean, 1)
    @test fmi2StatusOK == fmi2GetBoolean!(dlsym(lib, :fmi2GetBoolean), component, fmireference, Csize_t(1), value)
    @test value == fmi2Boolean.([false])

    fmireference = [fmi2ValueReference(134217728)]
    
    value = ["anything"]
    valueptr = pointer.(value)
    @test fmi2StatusOK == fmi2SetString(dlsym(lib, :fmi2SetString), component, fmireference, Csize_t(1), valueptr)

    value = Vector{fmi2String}(undef, 1)
    values = string.(zeros(1))
    @test fmi2StatusOK == fmi2GetString!(dlsym(lib, :fmi2GetString), component, fmireference, Csize_t(1), value)
    values[:] = unsafe_string.(value)
    @test values == ["anything"]

end