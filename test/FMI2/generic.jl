#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# value references of the Reference FMUs (BouncingBall: h, v, g; Feedthrough: inputs and outputs; VanDerPol: x0, der(x0), x1, der(x1))
const BB_H, BB_V, BB_G = fmi2ValueReference.((1, 3, 5))
const FT_REAL_IN, FT_REAL_OUT = fmi2ValueReference.((7, 8))
const FT_INTEGER_IN, FT_INTEGER_OUT = fmi2ValueReference.((19, 20))
const FT_BOOLEAN_IN, FT_BOOLEAN_OUT = fmi2ValueReference.((27, 28))
const FT_STRING_IN, FT_STRING_OUT = fmi2ValueReference.((29, 30))
const VDP_X0, VDP_DER_X0, VDP_X1, VDP_DER_X1 = fmi2ValueReference.((1, 2, 3, 4))

# BouncingBall
function test_generic(fmu, type::fmi2Type)
    lib = fmu.lib

    @test unsafe_string(fmi2GetTypesPlatform(dlsym(lib, :fmi2GetTypesPlatform))) ==
          "default"
    @test unsafe_string(fmi2GetVersion(dlsym(lib, :fmi2GetVersion))) == "2.0"

    component = instantiate(fmu, type)
    @test component != C_NULL

    for loggingOn in (fmi2False, fmi2True)
        @test fmi2StatusOK == fmi2SetDebugLogging(
            dlsym(lib, :fmi2SetDebugLogging),
            component,
            loggingOn,
            Csize_t(0),
            fmi2String[],
        )
    end

    @test fmi2StatusOK == fmi2SetupExperiment(
        dlsym(lib, :fmi2SetupExperiment),
        component,
        fmi2False,
        fmi2Real(0.0),
        fmi2Real(0.0),
        fmi2True,
        fmi2Real(1.0),
    )

    # get, set and free FMU state
    stateRef = Ref(fmi2FMUstate())
    @test fmi2StatusOK ==
          fmi2GetFMUstate!(dlsym(lib, :fmi2GetFMUstate), component, stateRef)
    state = stateRef[]
    @test state != C_NULL

    @test fmi2StatusOK == fmi2SetFMUstate(dlsym(lib, :fmi2SetFMUstate), component, state)

    size = Ref{Csize_t}(0)
    @test fmi2StatusOK == fmi2SerializedFMUstateSize!(
        dlsym(lib, :fmi2SerializedFMUstateSize),
        component,
        state,
        size,
    )
    @test size[] > 0

    serializedState = Vector{fmi2Byte}(undef, size[])
    @test fmi2StatusOK == fmi2SerializeFMUstate!(
        dlsym(lib, :fmi2SerializeFMUstate),
        component,
        state,
        serializedState,
        size[],
    )

    stateRef = Ref(fmi2FMUstate())
    @test fmi2StatusOK == fmi2DeSerializeFMUstate!(
        dlsym(lib, :fmi2DeSerializeFMUstate),
        component,
        serializedState,
        size[],
        stateRef,
    )
    @test stateRef[] != C_NULL
    @test fmi2StatusOK ==
          fmi2FreeFMUstate(dlsym(lib, :fmi2FreeFMUstate), component, stateRef)
    @test stateRef[] == C_NULL

    @test fmi2StatusOK ==
          fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)

    # parameter
    @test fmi2StatusOK ==
          fmi2SetReal(dlsym(lib, :fmi2SetReal), component, [BB_G], Csize_t(1), [-3.71])
    value = zeros(fmi2Real, 1)
    @test fmi2StatusOK ==
          fmi2GetReal!(dlsym(lib, :fmi2GetReal), component, [BB_G], Csize_t(1), value)
    @test value == [-3.71]

    @test fmi2StatusOK ==
          fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    # outputs (start values), pointer arguments
    vrs = [BB_H, BB_V]
    values = zeros(fmi2Real, 2)
    GC.@preserve vrs values begin
        @test fmi2StatusOK == fmi2GetReal!(
            dlsym(lib, :fmi2GetReal),
            component,
            pointer(vrs),
            Csize_t(2),
            pointer(values),
        )
    end
    @test values == [1.0, 0.0]

    @test fmi2StatusOK == fmi2Terminate(dlsym(lib, :fmi2Terminate), component)
    @test fmi2StatusOK == fmi2Reset(dlsym(lib, :fmi2Reset), component)
    @test isnothing(fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component))
end

# Feedthrough (all FMI 2 data types)
function test_generic_io(fmu, type::fmi2Type)
    lib = fmu.lib

    component = instantiate(fmu, type)
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

    @test fmi2StatusOK == fmi2SetReal(
        dlsym(lib, :fmi2SetReal),
        component,
        [FT_REAL_IN],
        Csize_t(1),
        fmi2Real[0.8],
    )
    @test fmi2StatusOK == fmi2SetInteger(
        dlsym(lib, :fmi2SetInteger),
        component,
        [FT_INTEGER_IN],
        Csize_t(1),
        [typemin(fmi2Integer)],
    )
    @test fmi2StatusOK == fmi2SetBoolean(
        dlsym(lib, :fmi2SetBoolean),
        component,
        [FT_BOOLEAN_IN],
        Csize_t(1),
        [fmi2True],
    )
    str = "anything"
    GC.@preserve str begin
        @test fmi2StatusOK == fmi2SetString(
            dlsym(lib, :fmi2SetString),
            component,
            [FT_STRING_IN],
            Csize_t(1),
            fmi2String[pointer(str)],
        )
    end

    @test fmi2StatusOK ==
          fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    value = zeros(fmi2Real, 1)
    @test fmi2StatusOK == fmi2GetReal!(
        dlsym(lib, :fmi2GetReal),
        component,
        [FT_REAL_OUT],
        Csize_t(1),
        value,
    )
    @test value == [0.8]

    value = zeros(fmi2Integer, 1)
    @test fmi2StatusOK == fmi2GetInteger!(
        dlsym(lib, :fmi2GetInteger),
        component,
        [FT_INTEGER_OUT],
        Csize_t(1),
        value,
    )
    @test value == [typemin(fmi2Integer)]

    value = zeros(fmi2Boolean, 1)
    @test fmi2StatusOK == fmi2GetBoolean!(
        dlsym(lib, :fmi2GetBoolean),
        component,
        [FT_BOOLEAN_OUT],
        Csize_t(1),
        value,
    )
    @test value == [fmi2True]

    value = fmi2String[C_NULL]
    @test fmi2StatusOK == fmi2GetString!(
        dlsym(lib, :fmi2GetString),
        component,
        [FT_STRING_OUT],
        Csize_t(1),
        value,
    )
    @test unsafe_string(value[1]) == "anything"

    @test fmi2StatusOK == fmi2Terminate(dlsym(lib, :fmi2Terminate), component)
    fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component)
end

# VanDerPol (der(x0) = x1, der(x1) = mu * (1 - x0^2) * x1 - x0 with x0 = 2, x1 = 0, mu = 1)
function test_derivatives(fmu)
    lib = fmu.lib

    component = instantiate(fmu, fmi2TypeModelExchange)
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

    # columns of the jacobian d(der(x0), der(x1)) / d(x0, x1)
    for (known, column) in ((VDP_X0, [0.0, -1.0]), (VDP_X1, [1.0, -3.0]))
        sensitivity = zeros(fmi2Real, 2)
        @test fmi2StatusOK == fmi2GetDirectionalDerivative!(
            dlsym(lib, :fmi2GetDirectionalDerivative),
            component,
            [VDP_DER_X0, VDP_DER_X1],
            Csize_t(2),
            [known],
            Csize_t(1),
            fmi2Real[1.0],
            sensitivity,
        )
        @test sensitivity ≈ column
    end

    fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component)
end
