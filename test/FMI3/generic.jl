#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# value references of the Reference FMUs (BouncingBall: h, v, g; VanDerPol: x0, der(x0), x1, der(x1))
const BB_H, BB_V, BB_G = fmi3ValueReference.((1, 3, 5))
const VDP_X0, VDP_DER_X0, VDP_X1, VDP_DER_X1 = fmi3ValueReference.((1, 2, 3, 4))

# Feedthrough: (type, input, output, value), the outputs equal the inputs
const FT_VALUES = (
    (:Float32, 1, 2, fmi3Float32(0.5)),
    (:Float64, 7, 8, fmi3Float64(0.8)),
    (:Int8, 11, 12, typemin(fmi3Int8)),
    (:UInt8, 13, 14, typemax(fmi3UInt8)),
    (:Int16, 15, 16, typemin(fmi3Int16)),
    (:UInt16, 17, 18, typemax(fmi3UInt16)),
    (:Int32, 19, 20, typemin(fmi3Int32)),
    (:UInt32, 21, 22, typemax(fmi3UInt32)),
    (:Int64, 23, 24, typemin(fmi3Int64)),
    (:UInt64, 25, 26, typemax(fmi3UInt64)),
    (:Boolean, 27, 28, fmi3True),
)
const FT_STRING_IN, FT_STRING_OUT = fmi3ValueReference.((29, 30))
const FT_BINARY_IN, FT_BINARY_OUT = fmi3ValueReference.((31, 32))
const FT_ENUMERATION_IN, FT_ENUMERATION_OUT = fmi3ValueReference.((33, 34))

# BouncingBall
function test_generic(fmu, type::fmi3Type)
    lib = fmu.lib

    @test unsafe_string(fmi3GetVersion(dlsym(lib, :fmi3GetVersion))) == "3.0"

    instance = instantiate(fmu, type)
    @test instance != C_NULL

    for loggingOn in (fmi3False, fmi3True)
        @test fmi3StatusOK == fmi3SetDebugLogging(
            dlsym(lib, :fmi3SetDebugLogging),
            instance,
            loggingOn,
            UInt(0),
            fmi3String[],
        )
    end

    # get, set and free FMU state
    stateRef = Ref(fmi3FMUState())
    @test fmi3StatusOK == fmi3GetFMUState!(dlsym(lib, :fmi3GetFMUState), instance, stateRef)
    state = stateRef[]
    @test state != C_NULL

    @test fmi3StatusOK == fmi3SetFMUState(dlsym(lib, :fmi3SetFMUState), instance, state)

    size = Ref{Csize_t}(0)
    @test fmi3StatusOK == fmi3SerializedFMUStateSize!(
        dlsym(lib, :fmi3SerializedFMUStateSize),
        instance,
        state,
        size,
    )
    @test size[] > 0

    serializedState = Vector{fmi3Byte}(undef, size[])
    @test fmi3StatusOK == fmi3SerializeFMUState!(
        dlsym(lib, :fmi3SerializeFMUState),
        instance,
        state,
        serializedState,
        size[],
    )

    stateRef = Ref(fmi3FMUState())
    @test fmi3StatusOK == fmi3DeSerializeFMUState!(
        dlsym(lib, :fmi3DeserializeFMUState),
        instance,
        serializedState,
        size[],
        stateRef,
    )
    @test stateRef[] != C_NULL
    @test fmi3StatusOK ==
          fmi3FreeFMUState(dlsym(lib, :fmi3FreeFMUState), instance, stateRef)
    @test stateRef[] == C_NULL

    @test fmi3StatusOK == fmi3EnterInitializationMode(
        dlsym(lib, :fmi3EnterInitializationMode),
        instance,
        fmi3False,
        fmi3Float64(0.0),
        fmi3Float64(0.0),
        fmi3True,
        fmi3Float64(1.0),
    )

    # parameter
    @test fmi3StatusOK == fmi3SetFloat64(
        dlsym(lib, :fmi3SetFloat64),
        instance,
        [BB_G],
        Csize_t(1),
        [-3.71],
        Csize_t(1),
    )
    value = zeros(fmi3Float64, 1)
    @test fmi3StatusOK == fmi3GetFloat64!(
        dlsym(lib, :fmi3GetFloat64),
        instance,
        [BB_G],
        Csize_t(1),
        value,
        Csize_t(1),
    )
    @test value == [-3.71]

    @test fmi3StatusOK ==
          fmi3ExitInitializationMode(dlsym(lib, :fmi3ExitInitializationMode), instance)

    # outputs (start values), pointer arguments
    vrs = [BB_H, BB_V]
    values = zeros(fmi3Float64, 2)
    GC.@preserve vrs values begin
        @test fmi3StatusOK == fmi3GetFloat64!(
            dlsym(lib, :fmi3GetFloat64),
            instance,
            pointer(vrs),
            Csize_t(2),
            pointer(values),
            Csize_t(2),
        )
    end
    @test values == [1.0, 0.0]

    @test fmi3StatusOK == fmi3Terminate(dlsym(lib, :fmi3Terminate), instance)
    @test fmi3StatusOK == fmi3Reset(dlsym(lib, :fmi3Reset), instance)
    @test isnothing(fmi3FreeInstance(dlsym(lib, :fmi3FreeInstance), instance))
end

# Feedthrough (all FMI 3 data types)
function test_generic_io(fmu, type::fmi3Type)
    lib = fmu.lib

    instance = instantiate(fmu, type)
    @test instance != C_NULL
    @test fmi3StatusOK == fmi3EnterInitializationMode(
        dlsym(lib, :fmi3EnterInitializationMode),
        instance,
        fmi3False,
        fmi3Float64(0.0),
        fmi3Float64(0.0),
        fmi3False,
        fmi3Float64(0.0),
    )

    for (T, input, _, value) in FT_VALUES
        set = getfield(FMICore, Symbol("fmi3Set", T))
        @test fmi3StatusOK == set(
            dlsym(lib, Symbol("fmi3Set", T)),
            instance,
            [fmi3ValueReference(input)],
            Csize_t(1),
            [value],
            Csize_t(1),
        )
    end

    str = "anything"
    binary = fmi3Byte[1, 2, 3]
    GC.@preserve str binary begin
        @test fmi3StatusOK == fmi3SetString(
            dlsym(lib, :fmi3SetString),
            instance,
            [FT_STRING_IN],
            Csize_t(1),
            fmi3String[pointer(str)],
            Csize_t(1),
        )
        @test fmi3StatusOK == fmi3SetBinary(
            dlsym(lib, :fmi3SetBinary),
            instance,
            [FT_BINARY_IN],
            Csize_t(1),
            Csize_t[length(binary)],
            fmi3Binary[pointer(binary)],
            Csize_t(1),
        )
    end
    # enumerations are set and get as `Int64`
    @test fmi3StatusOK == fmi3SetInt64(
        dlsym(lib, :fmi3SetInt64),
        instance,
        [FT_ENUMERATION_IN],
        Csize_t(1),
        [fmi3Int64(2)],
        Csize_t(1),
    )

    @test fmi3StatusOK ==
          fmi3ExitInitializationMode(dlsym(lib, :fmi3ExitInitializationMode), instance)

    for (T, _, output, value) in FT_VALUES
        get = getfield(FMICore, Symbol("fmi3Get", T, "!"))
        values = zeros(typeof(value), 1)
        @test fmi3StatusOK == get(
            dlsym(lib, Symbol("fmi3Get", T)),
            instance,
            [fmi3ValueReference(output)],
            Csize_t(1),
            values,
            Csize_t(1),
        )
        @test values == [value]
    end

    strings = fmi3String[C_NULL]
    @test fmi3StatusOK == fmi3GetString!(
        dlsym(lib, :fmi3GetString),
        instance,
        [FT_STRING_OUT],
        Csize_t(1),
        strings,
        Csize_t(1),
    )
    @test unsafe_string(strings[1]) == "anything"

    sizes = zeros(Csize_t, 1)
    binaries = fmi3Binary[C_NULL]
    @test fmi3StatusOK == fmi3GetBinary!(
        dlsym(lib, :fmi3GetBinary),
        instance,
        [FT_BINARY_OUT],
        Csize_t(1),
        sizes,
        binaries,
        Csize_t(1),
    )
    @test unsafe_wrap(Array, binaries[1], sizes[1]) == fmi3Byte[1, 2, 3]

    enumeration = zeros(fmi3Int64, 1)
    @test fmi3StatusOK == fmi3GetInt64!(
        dlsym(lib, :fmi3GetInt64),
        instance,
        [FT_ENUMERATION_OUT],
        Csize_t(1),
        enumeration,
        Csize_t(1),
    )
    @test enumeration == [2]

    @test fmi3StatusOK == fmi3Terminate(dlsym(lib, :fmi3Terminate), instance)
    fmi3FreeInstance(dlsym(lib, :fmi3FreeInstance), instance)
end

# VanDerPol (der(x0) = x1, der(x1) = mu * (1 - x0^2) * x1 - x0 with x0 = 2, x1 = 0, mu = 1)
function test_derivatives(fmu)
    lib = fmu.lib

    instance = instantiate(fmu, fmi3TypeModelExchange)
    @test instance != C_NULL
    @test fmi3StatusOK == fmi3EnterInitializationMode(
        dlsym(lib, :fmi3EnterInitializationMode),
        instance,
        fmi3False,
        fmi3Float64(0.0),
        fmi3Float64(0.0),
        fmi3False,
        fmi3Float64(0.0),
    )
    @test fmi3StatusOK ==
          fmi3ExitInitializationMode(dlsym(lib, :fmi3ExitInitializationMode), instance)

    unknowns = [VDP_DER_X0, VDP_DER_X1]

    # columns of the jacobian d(der(x0), der(x1)) / d(x0, x1)
    for (known, column) in ((VDP_X0, [0.0, -1.0]), (VDP_X1, [1.0, -3.0]))
        sensitivity = zeros(fmi3Float64, 2)
        @test fmi3StatusOK == fmi3GetDirectionalDerivative!(
            dlsym(lib, :fmi3GetDirectionalDerivative),
            instance,
            unknowns,
            Csize_t(2),
            [known],
            Csize_t(1),
            fmi3Float64[1.0],
            Csize_t(1),
            sensitivity,
            Csize_t(2),
        )
        @test sensitivity ≈ column
    end

    # rows of the jacobian
    for (seed, row) in (([1.0, 0.0], [0.0, 1.0]), ([0.0, 1.0], [-1.0, -3.0]))
        sensitivity = zeros(fmi3Float64, 2)
        @test fmi3StatusOK == fmi3GetAdjointDerivative!(
            dlsym(lib, :fmi3GetAdjointDerivative),
            instance,
            unknowns,
            Csize_t(2),
            [VDP_X0, VDP_X1],
            Csize_t(2),
            seed,
            Csize_t(2),
            sensitivity,
            Csize_t(2),
        )
        @test sensitivity ≈ row
    end

    fmi3FreeInstance(dlsym(lib, :fmi3FreeInstance), instance)
end
