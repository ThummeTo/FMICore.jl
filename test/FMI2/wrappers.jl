#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# The FMI 2 wrappers are tested against Julia functions with C signatures (no FMU binaries needed),
# every wrapper that takes buffers is called with arrays and with raw pointers.

const FAKE_INSTANCE = Ptr{Cvoid}(1234)
const FAKE_LOG = String[]
const FAKE_STRING = "fmi2"

fake_status(c::fmi2Component) = (c == FAKE_INSTANCE ? fmi2StatusOK : fmi2StatusError)

function fake_instantiate(
    name::fmi2String,
    type::fmi2Type,
    guid::fmi2String,
    resources::fmi2String,
    functions::Ptr{fmi2CallbackFunctions},
    visible::fmi2Boolean,
    loggingOn::fmi2Boolean,
)::fmi2Component
    push!(FAKE_LOG, "instantiate $(unsafe_string(name)) $(type) $(visible) $(loggingOn)")
    return FAKE_INSTANCE
end

function fake_setDebugLogging(
    c::fmi2Component,
    loggingOn::fmi2Boolean,
    n::Csize_t,
    categories::Ptr{fmi2String},
)::fmi2Status
    push!(
        FAKE_LOG,
        "logging $(loggingOn) $(n) $(unsafe_string(unsafe_load(categories, 1)))",
    )
    return fake_status(c)
end

# values[i] = 2 * vr[i]
function fake_getReal(
    c::fmi2Component,
    vr::Ptr{fmi2ValueReference},
    nvr::Csize_t,
    values::Ptr{fmi2Real},
)::fmi2Status
    for i = 1:nvr
        unsafe_store!(values, 2.0 * unsafe_load(vr, i), i)
    end
    return fake_status(c)
end

function fake_setReal(
    c::fmi2Component,
    vr::Ptr{fmi2ValueReference},
    nvr::Csize_t,
    values::Ptr{fmi2Real},
)::fmi2Status
    push!(FAKE_LOG, "set $(unsafe_load(vr, 1)) $(unsafe_load(values, 1))")
    return fake_status(c)
end

function fake_getString(
    c::fmi2Component,
    vr::Ptr{fmi2ValueReference},
    nvr::Csize_t,
    values::Ptr{fmi2String},
)::fmi2Status
    unsafe_store!(values, pointer(FAKE_STRING), 1)
    return fake_status(c)
end

# x[i] = -i
function fake_getStates(c::fmi2Component, x::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status
    for i = 1:nx
        unsafe_store!(x, -1.0 * i, i)
    end
    return fake_status(c)
end

function fake_setStates(c::fmi2Component, x::Ptr{fmi2Real}, nx::Csize_t)::fmi2Status
    push!(FAKE_LOG, "states $(unsafe_load(x, 1)) $(nx)")
    return fake_status(c)
end

function fake_newDiscreteStates(c::fmi2Component, eventInfo::Ptr{fmi2EventInfo})::fmi2Status
    info = fmi2EventInfo()
    info.valuesOfContinuousStatesChanged = fmi2True
    info.nextEventTime = 1.5
    unsafe_store!(eventInfo, info)
    return fake_status(c)
end

function fake_completedIntegratorStep(
    c::fmi2Component,
    noSet::fmi2Boolean,
    enterEventMode::Ptr{fmi2Boolean},
    terminate::Ptr{fmi2Boolean},
)::fmi2Status
    unsafe_store!(enterEventMode, fmi2True)
    unsafe_store!(terminate, fmi2False)
    return fake_status(c)
end

function fake_getRealStatus(
    c::fmi2Component,
    kind::fmi2StatusKind,
    value::Ptr{fmi2Real},
)::fmi2Status
    unsafe_store!(value, 1.5)
    return fake_status(c)
end

fake_instance(c::fmi2Component)::fmi2Status = fake_status(c)

cInstantiate = @cfunction(
    fake_instantiate,
    fmi2Component,
    (
        fmi2String,
        fmi2Type,
        fmi2String,
        fmi2String,
        Ptr{fmi2CallbackFunctions},
        fmi2Boolean,
        fmi2Boolean,
    )
)
cSetDebugLogging = @cfunction(
    fake_setDebugLogging,
    fmi2Status,
    (fmi2Component, fmi2Boolean, Csize_t, Ptr{fmi2String})
)
cGetReal = @cfunction(
    fake_getReal,
    fmi2Status,
    (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real})
)
cSetReal = @cfunction(
    fake_setReal,
    fmi2Status,
    (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real})
)
cGetString = @cfunction(
    fake_getString,
    fmi2Status,
    (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String})
)
cGetStates = @cfunction(fake_getStates, fmi2Status, (fmi2Component, Ptr{fmi2Real}, Csize_t))
cSetStates = @cfunction(fake_setStates, fmi2Status, (fmi2Component, Ptr{fmi2Real}, Csize_t))
cNewDiscreteStates =
    @cfunction(fake_newDiscreteStates, fmi2Status, (fmi2Component, Ptr{fmi2EventInfo}))
cCompletedIntegratorStep = @cfunction(
    fake_completedIntegratorStep,
    fmi2Status,
    (fmi2Component, fmi2Boolean, Ptr{fmi2Boolean}, Ptr{fmi2Boolean})
)
cGetRealStatus = @cfunction(
    fake_getRealStatus,
    fmi2Status,
    (fmi2Component, fmi2StatusKind, Ptr{fmi2Real})
)
cInstance = @cfunction(fake_instance, fmi2Status, (fmi2Component,))

function test_wrappers()
    c = FAKE_INSTANCE

    @testset "Instantiate" begin
        name, guid, resources = "inst", "{guid}", ""
        @test GC.@preserve name guid resources fmi2Instantiate(
            cInstantiate,
            pointer(name),
            fmi2TypeCoSimulation,
            pointer(guid),
            pointer(resources),
            Ptr{fmi2CallbackFunctions}(C_NULL),
            fmi2False,
            fmi2True,
        ) == FAKE_INSTANCE
        @test FAKE_LOG[end] == "instantiate inst $(fmi2TypeCoSimulation) 0 1"
    end

    @testset "Debug logging" begin
        categories = fmi2String[pointer(FAKE_STRING)]
        for _categories in (categories, pointer(categories))
            GC.@preserve categories begin
                @test fmi2SetDebugLogging(
                    cSetDebugLogging,
                    c,
                    fmi2True,
                    Csize_t(1),
                    _categories,
                ) == fmi2StatusOK
            end
            @test FAKE_LOG[end] == "logging 1 1 fmi2"
        end
    end

    @testset "State transitions" begin
        for f in (
            fmi2EnterInitializationMode,
            fmi2ExitInitializationMode,
            fmi2Terminate,
            fmi2Reset,
            fmi2EnterEventMode,
            fmi2EnterContinuousTimeMode,
            fmi2CancelStep,
        )
            @test f(cInstance, c) == fmi2StatusOK
        end
    end

    @testset "Get/Set (arrays and pointers)" begin
        vr = fmi2ValueReference[1, 2, 3]
        values = zeros(fmi2Real, 3)
        @test fmi2GetReal!(cGetReal, c, vr, Csize_t(3), values) == fmi2StatusOK
        @test values == [2.0, 4.0, 6.0]

        values = zeros(fmi2Real, 3)
        GC.@preserve vr values begin
            @test fmi2GetReal!(cGetReal, c, pointer(vr), Csize_t(3), pointer(values)) ==
                  fmi2StatusOK
        end
        @test values == [2.0, 4.0, 6.0]

        values = fmi2Real[42.0]
        GC.@preserve vr values begin
            @test fmi2SetReal(cSetReal, c, pointer(vr), Csize_t(1), pointer(values)) ==
                  fmi2StatusOK
        end
        @test FAKE_LOG[end] == "set 1 42.0"

        strings = fmi2String[C_NULL]
        for _strings in (strings, pointer(strings))
            strings[1] = C_NULL
            GC.@preserve strings begin
                @test fmi2GetString!(cGetString, c, vr, Csize_t(1), _strings) ==
                      fmi2StatusOK
            end
            @test unsafe_string(strings[1]) == FAKE_STRING
        end
    end

    @testset "Model Exchange buffers (arrays and pointers)" begin
        for f in (
            fmi2GetContinuousStates!,
            fmi2GetDerivatives!,
            fmi2GetEventIndicators!,
            fmi2GetNominalsOfContinuousStates!,
        )
            x = zeros(fmi2Real, 2)
            for _x in (x, pointer(x))
                fill!(x, 0.0)
                GC.@preserve x begin
                    @test f(cGetStates, c, _x, Csize_t(2)) == fmi2StatusOK
                end
                @test x == [-1.0, -2.0]
            end
        end

        x = fmi2Real[3.0, 4.0]
        for _x in (x, pointer(x))
            GC.@preserve x begin
                @test fmi2SetContinuousStates(cSetStates, c, _x, Csize_t(2)) == fmi2StatusOK
            end
            @test FAKE_LOG[end] == "states 3.0 2"
        end

        eventInfo = Ref(fmi2EventInfo())
        GC.@preserve eventInfo begin
            @test fmi2NewDiscreteStates!(
                cNewDiscreteStates,
                c,
                Base.unsafe_convert(Ptr{fmi2EventInfo}, eventInfo),
            ) == fmi2StatusOK
        end
        @test eventInfo[].valuesOfContinuousStatesChanged == fmi2True
        @test eventInfo[].nextEventTime == 1.5

        flags = zeros(fmi2Boolean, 2)
        GC.@preserve flags begin
            @test fmi2CompletedIntegratorStep!(
                cCompletedIntegratorStep,
                c,
                fmi2True,
                pointer(flags, 1),
                pointer(flags, 2),
            ) == fmi2StatusOK
        end
        @test flags == [fmi2True, fmi2False]
    end

    @testset "Co-Simulation status" begin
        value = zeros(fmi2Real, 1)
        GC.@preserve value begin
            @test fmi2GetRealStatus!(
                cGetRealStatus,
                c,
                fmi2StatusKindLastSuccessfulTime,
                pointer(value),
            ) == fmi2StatusOK
        end
        @test value == [1.5]
    end
end
