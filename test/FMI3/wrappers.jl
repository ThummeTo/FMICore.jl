#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# The FMI 3 wrappers are tested against Julia functions with C signatures (no FMU binaries needed),
# every wrapper that takes buffers is called with arrays and with raw pointers.

const FAKE_INSTANCE = Ptr{Cvoid}(1234)
const FAKE_LOG = String[]

fake_status(c::fmi3Instance) = (c == FAKE_INSTANCE ? fmi3StatusOK : fmi3StatusError)

function fake_instantiateME(
    name::fmi3String,
    token::fmi3String,
    path::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    env::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
)::fmi3Instance
    push!(FAKE_LOG, "ME $(unsafe_string(name)) $(visible) $(loggingOn)")
    return FAKE_INSTANCE
end

function fake_instantiateCS(
    name::fmi3String,
    token::fmi3String,
    path::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    eventModeUsed::fmi3Boolean,
    earlyReturnAllowed::fmi3Boolean,
    vrs::Ptr{fmi3ValueReference},
    nvrs::Csize_t,
    env::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    intermediateUpdate::Ptr{Cvoid},
)::fmi3Instance
    push!(
        FAKE_LOG,
        "CS $(unsafe_string(name)) $(nvrs) $(nvrs > 0 ? unsafe_load(vrs, 1) : 0)",
    )
    return FAKE_INSTANCE
end

function fake_setDebugLogging(
    c::fmi3Instance,
    loggingOn::fmi3Boolean,
    n::Csize_t,
    categories::Ptr{fmi3String},
)::fmi3Status
    push!(FAKE_LOG, "logging $(loggingOn) $(n)")
    return fake_status(c)
end

fake_instance(c::fmi3Instance)::fmi3Status = fake_status(c)

# values[i] = 2 * vr[i]
function fake_getFloat64(
    c::fmi3Instance,
    vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    values::Ptr{fmi3Float64},
    nValues::Csize_t,
)::fmi3Status
    for i = 1:nvr
        unsafe_store!(values, 2.0 * unsafe_load(vr, i), i)
    end
    return fake_status(c)
end

function fake_setFloat64(
    c::fmi3Instance,
    vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    values::Ptr{fmi3Float64},
    nValues::Csize_t,
)::fmi3Status
    push!(FAKE_LOG, "set $(unsafe_load(vr, 1)) $(unsafe_load(values, 1)) $(nValues)")
    return fake_status(c)
end

const FAKE_STRING = "fmi3"
function fake_getString(
    c::fmi3Instance,
    vr::Ptr{fmi3ValueReference},
    nvr::Csize_t,
    values::Ptr{fmi3String},
    nValues::Csize_t,
)::fmi3Status
    unsafe_store!(values, pointer(FAKE_STRING), 1)
    return fake_status(c)
end

function fake_updateDiscreteStates(
    c::fmi3Instance,
    needUpdate::Ptr{fmi3Boolean},
    terminate::Ptr{fmi3Boolean},
    nominalsChanged::Ptr{fmi3Boolean},
    valuesChanged::Ptr{fmi3Boolean},
    nextEventTimeDefined::Ptr{fmi3Boolean},
    nextEventTime::Ptr{fmi3Float64},
)::fmi3Status
    unsafe_store!(valuesChanged, fmi3True)
    unsafe_store!(nextEventTime, 1.5)
    return fake_status(c)
end

function fake_doStep(
    c::fmi3Instance,
    t::fmi3Float64,
    h::fmi3Float64,
    noSet::fmi3Boolean,
    eventHandlingNeeded::Ptr{fmi3Boolean},
    terminate::Ptr{fmi3Boolean},
    earlyReturn::Ptr{fmi3Boolean},
    lastSuccessfulTime::Ptr{fmi3Float64},
)::fmi3Status
    unsafe_store!(lastSuccessfulTime, t + h)
    return fake_status(c)
end

function fake_serializeFMUState(
    c::fmi3Instance,
    state::fmi3FMUState,
    bytes::Ptr{fmi3Byte},
    size::Csize_t,
)::fmi3Status
    for i = 1:size
        unsafe_store!(bytes, fmi3Byte(i), i)
    end
    return fake_status(c)
end

function fake_getDerivatives(c::fmi3Instance, dx::Ptr{fmi3Float64}, nx::Csize_t)::fmi3Status
    for i = 1:nx
        unsafe_store!(dx, -1.0 * i, i)
    end
    return fake_status(c)
end

function fake_getNumber(c::fmi3Instance, n::Ptr{Csize_t})::fmi3Status
    unsafe_store!(n, Csize_t(2))
    return fake_status(c)
end

cInstantiateME = @cfunction(
    fake_instantiateME,
    fmi3Instance,
    (
        fmi3String,
        fmi3String,
        fmi3String,
        fmi3Boolean,
        fmi3Boolean,
        fmi3InstanceEnvironment,
        Ptr{Cvoid},
    )
)
cInstantiateCS = @cfunction(
    fake_instantiateCS,
    fmi3Instance,
    (
        fmi3String,
        fmi3String,
        fmi3String,
        fmi3Boolean,
        fmi3Boolean,
        fmi3Boolean,
        fmi3Boolean,
        Ptr{fmi3ValueReference},
        Csize_t,
        fmi3InstanceEnvironment,
        Ptr{Cvoid},
        Ptr{Cvoid},
    )
)
cSetDebugLogging = @cfunction(
    fake_setDebugLogging,
    fmi3Status,
    (fmi3Instance, fmi3Boolean, Csize_t, Ptr{fmi3String})
)
cInstance = @cfunction(fake_instance, fmi3Status, (fmi3Instance,))
cGetFloat64 = @cfunction(
    fake_getFloat64,
    fmi3Status,
    (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t)
)
cSetFloat64 = @cfunction(
    fake_setFloat64,
    fmi3Status,
    (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t)
)
cGetString = @cfunction(
    fake_getString,
    fmi3Status,
    (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3String}, Csize_t)
)
cUpdateDiscreteStates = @cfunction(
    fake_updateDiscreteStates,
    fmi3Status,
    (
        fmi3Instance,
        Ptr{fmi3Boolean},
        Ptr{fmi3Boolean},
        Ptr{fmi3Boolean},
        Ptr{fmi3Boolean},
        Ptr{fmi3Boolean},
        Ptr{fmi3Float64},
    )
)
cDoStep = @cfunction(
    fake_doStep,
    fmi3Status,
    (
        fmi3Instance,
        fmi3Float64,
        fmi3Float64,
        fmi3Boolean,
        Ptr{fmi3Boolean},
        Ptr{fmi3Boolean},
        Ptr{fmi3Boolean},
        Ptr{fmi3Float64},
    )
)
cSerializeFMUState = @cfunction(
    fake_serializeFMUState,
    fmi3Status,
    (fmi3Instance, fmi3FMUState, Ptr{fmi3Byte}, Csize_t)
)
cGetDerivatives =
    @cfunction(fake_getDerivatives, fmi3Status, (fmi3Instance, Ptr{fmi3Float64}, Csize_t))
cGetNumber = @cfunction(fake_getNumber, fmi3Status, (fmi3Instance, Ptr{Csize_t}))

function test_wrappers()
    c = FAKE_INSTANCE

    @testset "Instantiate" begin
        name, token, path = "inst", "{token}", ""
        @test GC.@preserve name token path fmi3InstantiateModelExchange(
            cInstantiateME,
            pointer(name),
            pointer(token),
            pointer(path),
            fmi3False,
            fmi3True,
            C_NULL,
            C_NULL,
        ) == FAKE_INSTANCE
        @test FAKE_LOG[end] == "ME inst 0 1"

        vrs = fmi3ValueReference[7]
        for _vrs in (vrs, pointer(vrs))
            @test GC.@preserve name token path vrs fmi3InstantiateCoSimulation(
                cInstantiateCS,
                pointer(name),
                pointer(token),
                pointer(path),
                fmi3False,
                fmi3True,
                fmi3False,
                fmi3False,
                _vrs,
                Csize_t(1),
                C_NULL,
                C_NULL,
                C_NULL,
            ) == FAKE_INSTANCE
            @test FAKE_LOG[end] == "CS inst 1 7"
        end
    end

    @testset "Debug logging" begin
        categories = fmi3String[pointer(FAKE_STRING)]
        for _categories in (categories, pointer(categories), C_NULL)
            @test fmi3SetDebugLogging(
                cSetDebugLogging,
                c,
                fmi3True,
                UInt(length(categories)),
                _categories,
            ) == fmi3StatusOK
            @test FAKE_LOG[end] == "logging 1 1"
        end
    end

    @testset "State transitions" begin
        for f in (
            fmi3ExitInitializationMode,
            fmi3Terminate,
            fmi3Reset,
            fmi3EnterContinuousTimeMode,
            fmi3EnterStepMode,
            fmi3EnterEventMode, # FMI 3.0 signature
        )
            @test f(cInstance, c) == fmi3StatusOK
        end
    end

    @testset "Get/Set (arrays and pointers)" begin
        vr = fmi3ValueReference[1, 2, 3]
        values = zeros(fmi3Float64, 3)
        @test fmi3GetFloat64!(cGetFloat64, c, vr, Csize_t(3), values, Csize_t(3)) ==
              fmi3StatusOK
        @test values == [2.0, 4.0, 6.0]

        values = zeros(fmi3Float64, 3)
        GC.@preserve vr values begin
            @test fmi3GetFloat64!(
                cGetFloat64,
                c,
                pointer(vr),
                Csize_t(3),
                pointer(values),
                Csize_t(3),
            ) == fmi3StatusOK
        end
        @test values == [2.0, 4.0, 6.0]

        values = [42.0]
        GC.@preserve vr values begin
            @test fmi3SetFloat64(
                cSetFloat64,
                c,
                pointer(vr),
                Csize_t(1),
                pointer(values),
                Csize_t(1),
            ) == fmi3StatusOK
        end
        @test FAKE_LOG[end] == "set 1 42.0 1"

        strings = fmi3String[C_NULL]
        for _strings in (strings, pointer(strings))
            strings[1] = C_NULL
            GC.@preserve strings begin
                @test fmi3GetString!(cGetString, c, vr, Csize_t(1), _strings, Csize_t(1)) ==
                      fmi3StatusOK
            end
            @test unsafe_string(strings[1]) == FAKE_STRING
        end
    end

    @testset "Buffers (arrays, Refs and pointers)" begin
        flags = zeros(fmi3Boolean, 5)
        nextEventTime = zeros(fmi3Float64, 1)
        GC.@preserve flags nextEventTime begin
            @test fmi3UpdateDiscreteStates(
                cUpdateDiscreteStates,
                c,
                pointer(flags, 1),
                pointer(flags, 2),
                pointer(flags, 3),
                pointer(flags, 4),
                pointer(flags, 5),
                pointer(nextEventTime),
            ) == fmi3StatusOK
        end
        @test flags[4] == fmi3True
        @test nextEventTime[1] == 1.5

        lastSuccessfulTime = Ref(0.0)
        @test fmi3DoStep!(
            cDoStep,
            c,
            1.0,
            0.5,
            fmi3True,
            Ref(fmi3False),
            Ref(fmi3False),
            Ref(fmi3False),
            lastSuccessfulTime,
        ) == fmi3StatusOK
        @test lastSuccessfulTime[] == 1.5

        bytes = zeros(fmi3Byte, 3)
        for _bytes in (bytes, pointer(bytes))
            fill!(bytes, 0)
            GC.@preserve bytes begin
                @test fmi3SerializeFMUState!(
                    cSerializeFMUState,
                    c,
                    C_NULL,
                    _bytes,
                    Csize_t(3),
                ) == fmi3StatusOK
            end
            @test bytes == fmi3Byte[1, 2, 3]
        end

        dx = zeros(fmi3Float64, 2)
        for _dx in (dx, pointer(dx))
            fill!(dx, 0.0)
            GC.@preserve dx begin
                @test fmi3GetContinuousStateDerivatives!(
                    cGetDerivatives,
                    c,
                    _dx,
                    Csize_t(2),
                ) == fmi3StatusOK
            end
            @test dx == [-1.0, -2.0]
        end

        n = Ref(Csize_t(0))
        @test fmi3GetNumberOfContinuousStates!(cGetNumber, c, n) == fmi3StatusOK
        @test n[] == 2
    end
end
