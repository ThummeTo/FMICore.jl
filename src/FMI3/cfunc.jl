#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

This function instantiates a Model Exchange FMU (see Section 3). It is allowed to call this function only if modelDescription.xml includes a <ModelExchange> element.
"""
function fmi3InstantiateModelExchange(cfunc::Ptr{Nothing},
        instanceName::fmi3String,
        fmuInstantiationToken::fmi3String,
        fmuResourceLocation::fmi3String,
        visible::fmi3Boolean,
        loggingOn::fmi3Boolean,
        instanceEnvironment::fmi3InstanceEnvironment,
        logMessage::Ptr{Cvoid})

    status = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cuint, Cuint, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, fmuInstantiationToken, fmuResourceLocation,
        visible, loggingOn, instanceEnvironment, logMessage)

    @debug "fmi3InstantiateModelExchange(instanceName: $(instanceName), fmuType: $(fmuType), fmuInstantiationToken: $(fmuInstantiationToken), fmuResourceLocation: $(fmuResourceLocation), visible: $(visible), loggingOn: $(loggingOn)) → $(status)"
    return status
end
export fmi3InstantiateModelExchange

"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

This function instantiates a Co-Simulation FMU (see Section 4). It is allowed to call this function only if modelDescription.xml includes a <CoSimulation> element.
"""
function fmi3InstantiateCoSimulation(cfunc::Ptr{Nothing},
    instanceName::fmi3String,
    instantiationToken::fmi3String,
    resourcePath::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    eventModeUsed::fmi3Boolean,
    earlyReturnAllowed::fmi3Boolean,
    requiredIntermediateVariables::Array{fmi3ValueReference},
    nRequiredIntermediateVariables::Csize_t,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    intermediateUpdate::Ptr{Cvoid})

    status = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cint, Cint, Cint, Cint, Ptr{fmi3ValueReference}, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, instantiationToken, resourcePath,
        visible, loggingOn, eventModeUsed, earlyReturnAllowed, requiredIntermediateVariables,
        nRequiredIntermediateVariables, instanceEnvironment, logMessage, intermediateUpdate)
   
    @debug "fmi3InstantiateCoSimulation(instanceName: $(instanceName), fmuType: $(fmuType), fmuInstantiationToken: $(fmuInstantiationToken), fmuResourceLocation: $(fmuResourceLocation), visible: $(visible), loggingOn: $(loggingOn)) → $(status)"
    return status
end
export fmi3InstantiateCoSimulation

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1:: 2.3.1. Super State: FMU State Setable

This function instantiates a Scheduled Execution FMU (see Section 4). It is allowed to call this function only if modelDescription.xml includes a <ScheduledExecution> element.
"""
function fmi3InstantiateScheduledExecution(cfunc::Ptr{Nothing},
    instanceName::fmi3String,
    instantiationToken::fmi3String,
    resourcePath::fmi3String,
    visible::fmi3Boolean,
    loggingOn::fmi3Boolean,
    instanceEnvironment::fmi3InstanceEnvironment,
    logMessage::Ptr{Cvoid},
    clockUpdate::Ptr{Cvoid},
    lockPreemption::Ptr{Cvoid},
    unlockPreemption::Ptr{Cvoid})
    @assert false "Not tested!"

    status = ccall(cfunc,
        Ptr{Cvoid},
        (Cstring, Cstring, Cstring,
        Cint, Cint, Cint, Cint, Ptr{fmi3ValueReference}, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
        instanceName, instantiationToken, resourcePath,
        visible, loggingOn, eventModeUsed, earlyReturnAllowed, requiredIntermediateVariables,
        nRequiredIntermediateVariables, instanceEnvironment, logMessage, clockUpdate, lockPreemption, unlockPreemption)

    @debug "fmi3InstantiateScheduledExecution(instanceName: $(instanceName), fmuType: $(fmuType), fmuInstantiationToken: $(fmuInstantiationToken), fmuResourceLocation: $(fmuResourceLocation), visible: $(visible), loggingOn: $(loggingOn)) → $(status)"
    return status
end
export fmi3InstantiateScheduledExecution

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.4. Inquire Version Number of Header Files

This function returns fmi3Version of the fmi3Functions.h header file which was used to compile the functions of the FMU. This function call is allowed always and in all interface types.

The standard header file as documented in this specification has version "3.0-beta.2", so this function returns "3.0-beta.2".
"""
function fmi3GetVersion(cfunc::Ptr{Nothing})
    str = ccall(cfunc, fmi3String, ())
    @debug "fmi3GetVersion() → $(str)"
    return str
end
export fmi3GetVersion

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Disposes the given instance, unloads the loaded model, and frees all the allocated memory and other resources that have been allocated by the functions of the FMU interface. If a NULL pointer is provided for argument instance, the function call is ignored (does not have an effect).
"""
function fmi3FreeInstance!(cfunc::Ptr{Nothing}, c::fmi3Instance)

    ccall(cfunc, Cvoid, (Ptr{Cvoid},), c)
    @debug "fmi3FreeInstance(c: $(c)) → [nothing]"
    return nothing
end
export fmi3FreeInstance!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi3True, debug logging is enabled, otherwise it is switched off.
"""
function fmi3SetDebugLogging(cfunc::Ptr{Nothing}, c::fmi3Instance, logginOn::fmi3Boolean, nCategories::UInt, categories::Ptr{Nothing})
    status = ccall(cfunc,
                   fmi3Status,
                   (fmi3Instance, Cint, Csize_t, Ptr{Nothing}),
                   c, logginOn, nCategories, categories)
    @debug "fmi3SetDebugLogging(c: $(c), logginOn: $(loggingOn), nCategories: $(nCategories), categories: $(categories)) → $(status)"
    return status
end
export fmi3SetDebugLogging

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <Datatype initial = "exact" or "approx"> can be set with the “fmi3SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.4.7). Setting other variables is not allowed.
Also sets the simulation start and stop time.
"""
function fmi3EnterInitializationMode(cfunc::Ptr{Nothing}, c::fmi3Instance, toleranceDefined::fmi3Boolean,
    tolerance::fmi3Float64,
    startTime::fmi3Float64,
    stopTimeDefined::fmi3Boolean,
    stopTime::fmi3Float64)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, fmi3Boolean, fmi3Float64, fmi3Float64, fmi3Boolean, fmi3Float64),
          c, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)

    @debug "fmi3EnterInitializationMode(c: $(c), toleranceDefined: $(toleranceDefined), tolerance: $(tolerance), startTime: $(startTime), stopTimeDefined: $(stopTimeDefined), stopTime: $(stopTime)) → $(status)" 
    return status
end
export fmi3EnterInitializationMode

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Informs the FMU to exit Initialization Mode.
"""
function fmi3ExitInitializationMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
    
    @debug "fmi3ExitInitializationMode(c: $(c)) → $(status)" 
    return status
end
export fmi3ExitInitializationMode

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.4. Super State: Initialized

Informs the FMU that the simulation run is terminated.
"""
function fmi3Terminate(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc, fmi3Status, (fmi3Instance,), c)
    @debug "fmi3Terminate(c: $(c)) → $(status)" 
    return status
end
export fmi3Terminate

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.1. Super State: FMU State Setable

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi3InstantiateXXX would have been called.
"""
function fmi3Reset(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc, fmi3Status, (fmi3Instance,), c)
    @debug "fmi3Reset(c: $(c)) → $(status)" 
    return status
end
export fmi3Reset

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetFloat32!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float32}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float32}, Csize_t),
          c, vr, nvr, value, nvalue) 
    @debug "fmi3GetFloat32(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetFloat32!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetFloat32(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float32}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float32}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetFloat32(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetFloat32

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetFloat64!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float64}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetFloat64(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetFloat64!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetFloat64(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Float64}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetFloat64(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetFloat64

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt8!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int8}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int8}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetInt8(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetInt8!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt8(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int8}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int8}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetInt8(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetInt8

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt8!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt8}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt8}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetUInt8(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetUInt8!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt8(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt8}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt8}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetUInt8(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetUInt8

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt16!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int16}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int16}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetInt16(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetInt16!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt16(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int16}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int16}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetInt16(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetInt16

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt16!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt16}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt16}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetUInt16(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetUInt16!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt16(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt16}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt16}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetUInt16(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetUInt16

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt32!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int32}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetInt32(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetInt32!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt32(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int32}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetInt32(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetInt32

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt32!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt32}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt32}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetUInt32(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetUInt32!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt32(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt32}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt32}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetUInt32(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetUInt32

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetInt64!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int64}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int64}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetInt64(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetInt64!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetInt64(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Int64}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int64}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetInt64(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetInt64

# TODO test, no variable in FMUs
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetUInt64!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt64}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetUInt64(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetUInt64!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetUInt64(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3UInt64}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetUInt64(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetUInt64

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetBoolean!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Boolean}, nvalue::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Boolean}, Csize_t),
          c, vr, nvr, value, nvalue)
    @debug "fmi3GetBoolean(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetBoolean!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetBoolean(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Boolean}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Boolean}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetBoolean(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetBoolean

# TODO change to fmi3String when possible to test
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetString!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{Ptr{Cchar}}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t,  Ptr{Cchar}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3GetString(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetString!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""     
function fmi3SetString(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::Union{AbstractArray{Ptr{Cchar}}, AbstractArray{Ptr{UInt8}}}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{Cchar}, Csize_t),
                c, vr, nvr, value, nvalue)
    @debug "fmi3SetString(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetString

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValues - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetBinary!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, valueSizes::AbstractArray{Csize_t}, value::AbstractArray{fmi3Binary}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{Csize_t}, Ptr{fmi3Binary}, Csize_t),
                c, vr, nvr, valueSizes, value, nvalue)
    @debug "fmi3GetBinary(c: $(c), vr: $(vr), nvr: $(nvr), valueSizes: $(valueSizes), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetBinary!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetBinary(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, valueSizes::AbstractArray{Csize_t}, value::AbstractArray{fmi3Binary}, nvalue::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{Csize_t}, Ptr{fmi3Binary}, Csize_t),
                c, vr, nvr, valueSizes, value, nvalue)
    @debug "fmi3SetBinary(c: $(c), vr: $(vr), nvr: $(nvr), valueSizes: $(valueSizes), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetBinary

# TODO, Clocks not implemented so far thus not tested
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3GetClock!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Clock})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t,  Ptr{fmi3Clock}),
                c, vr, nvr, value)
    @debug "fmi3GetClock(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3GetClock!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.2. Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference.

nValue - is different from nvr if the value reference represents an array and therefore are more values tied to a single value reference.
"""
function fmi3SetClock(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, value::AbstractArray{fmi3Clock})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance,Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Clock}),
                c, vr, nvr, value)
    @debug "fmi3SetClock(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value), nvalue: $(nvalue)) → $(status)" 
    return status
end
export fmi3SetClock

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi3GetFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::Ref{fmi3FMUState})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3FMUState}),
                c, FMUstate)
    @debug "fmi3GetFMUState!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi3GetFMUState!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi3SetFMUState(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::fmi3FMUState)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3FMUState),
                c, FMUstate)
    @debug "fmi3SetFMUState!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi3SetFMUState

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3FreeFMUstate frees all memory and other resources allocated with the fmi3GetFMUstate call for this FMUstate.
"""
function fmi3FreeFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::Ref{fmi3FMUState})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3FMUState}),
                c, FMUstate)
    @debug "fmi3FreeFMUState!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi3FreeFMUState!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3SerializedFMUstateSize returns the size of the byte vector which is needed to store FMUstate in it.
"""
function fmi3SerializedFMUStateSize!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::fmi3FMUState, size::Ref{Csize_t})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{Cvoid}, Ptr{Csize_t}),
                c, FMUstate, size)
    @debug "fmi3SerializedFMUStateSize(c: $(c), FMUstate: $(FMUstate), size: $(size)) → $(status)"
    return status
end
export fmi3SerializedFMUStateSize!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi3SerializeFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, FMUstate::fmi3FMUState, serialzedState::AbstractArray{fmi3Byte}, size::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{Cvoid}, Ptr{Cchar}, Csize_t),
                c, FMUstate, serialzedState, size)
    @debug "fmi3SerializeFMUState(c: $(c), FMUstate: $(FMUstate), serialzedState: $(serializedState), size: $(size)) → $(status)"
    return status
end
export fmi3SerializeFMUState!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.6.4. Getting and Setting the Complete FMU State

fmi3DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi3DeSerializeFMUState!(cfunc::Ptr{Nothing}, c::fmi3Instance, serialzedState::AbstractArray{fmi3Byte}, size::Csize_t, FMUstate::Ref{fmi3FMUState})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{Cchar}, Csize_t, Ptr{fmi3FMUState}),
                c, serialzedState, size, FMUstate)
    @debug "fmi3DeSerializeFMUState(c: $(c), serializedState: $(serializedState), size: $(size), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi3DeSerializeFMUState!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3SetIntervalDecimal sets the interval until the next clock tick
"""
# TODO: Clocks and dependencies functions
# ToDo: Function is untested!
function fmi3SetIntervalDecimal(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervals::AbstractArray{fmi3Float64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}),
                c, vr, nvr, intervals)
    @debug "fmi3SetIntervalDecimal(c: $(c), vr: $(vr), nvr: $(nvr), intervals: $(intervals)) → $(status)"
    return status
end
export fmi3SetIntervalDecimal

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3SetIntervalFraction sets the interval until the next clock tick
Only allowed if the attribute 'supportsFraction' is set.
"""
# ToDo: Function is untested!
function fmi3SetIntervalFraction(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervalCounters::AbstractArray{fmi3UInt64}, resolutions::AbstractArray{fmi3UInt64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Ptr{fmi3UInt64}),
                c, vr, nvr, intervalCounters, resolutions)
    @debug "fmi3SetIntervalFraction(c: $(c), vr: $(vr), nvr: $(nvr), intervalCounters: $(intervalCounters), resolutions: $(resolutions)) → $(status)"
    return status
end
export fmi3SetIntervalFraction

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetIntervalDecimal retrieves the interval until the next clock tick.

For input Clocks it is allowed to call this function to query the next activation interval.
For changing aperiodic Clock, this function must be called in every Event Mode where this clock was activated.
For countdown aperiodic Clock, this function must be called in every Event Mode.
Clock intervals are computed in fmi3UpdateDiscreteStates (at the latest), therefore, this function should be called after fmi3UpdateDiscreteStates.
For information about fmi3IntervalQualifiers, call ?fmi3IntervalQualifier
"""
# ToDo: Function is untested!
function fmi3GetIntervalDecimal!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervals::AbstractArray{fmi3Float64}, qualifiers::fmi3IntervalQualifier)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Ptr{fmi3IntervalQualifier}),
                c, vr, nvr, intervals, qualifiers)
    @debug "fmi3GetIntervalDecimal(c: $(c), vr: $(vr), nvr: $(nvr), intervals: $(intervals), qualifiers: $(qualifiers)) → $(status)"
    return status
end
export fmi3GetIntervalDecimal!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetIntervalFraction retrieves the interval until the next clock tick.

For input Clocks it is allowed to call this function to query the next activation interval.
For changing aperiodic Clock, this function must be called in every Event Mode where this clock was activated.
For countdown aperiodic Clock, this function must be called in every Event Mode.
Clock intervals are computed in fmi3UpdateDiscreteStates (at the latest), therefore, this function should be called after fmi3UpdateDiscreteStates.
For information about fmi3IntervalQualifiers, call ?fmi3IntervalQualifier
"""
# ToDo: Function is untested!
function fmi3GetIntervalFraction!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, intervalCounters::AbstractArray{fmi3UInt64}, resolutions::AbstractArray{fmi3UInt64}, qualifiers::fmi3IntervalQualifier)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Ptr{fmi3UInt64}, Ptr{fmi3IntervalQualifier}),
                c, vr, nvr, intervalCounters, resolutions, qualifiers)
    @debug "fmi3GetIntervalFraction(c: $(c), vr: $(vr), nvr: $(nvr), intervalCounters: $(intervalCounters), resolutions: $(resolutions), qualifiers: $(qualifiers)) → $(status)"
    return status
end
export fmi3GetIntervalFraction!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetShiftDecimal retrieves the delay to the first Clock tick from the FMU.
"""
# ToDo: Function is untested!
function fmi3GetShiftDecimal!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, shifts::AbstractArray{fmi3Float64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}),
                c, vr, nvr, shifts)
    @debug "fmi3GetShiftDecimal(c: $(c), vr: $(vr), nvr: $(nvr), shifts: $(shifts)) → $(status)"
    return status
end
export fmi3GetShiftDecimal!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.9. Clocks

fmi3GetShiftFraction retrieves the delay to the first Clock tick from the FMU.
"""
# ToDo: Function is untested!
function fmi3GetShiftFraction!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nvr::Csize_t, shiftCounters::AbstractArray{fmi3UInt64}, resolutions::AbstractArray{fmi3UInt64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3UInt64}, Ptr{fmi3UInt64}),
                c, vr, nvr, shiftCounters, resolutions)
    @debug "fmi3GetShiftFraction(c: $(c), vr: $(vr), nvr: $(nvr), shiftCounters: $(shiftCounters), resolutions: $(resolutions)) → $(status)"
    return status
end
export fmi3GetShiftFraction!

"""
Source: FMISpec3.0, Version D5ef1c1: 5.2.2. State: Clock Activation Mode

During Clock Activation Mode (see 5.2.2.) after fmi3ActivateModelPartition has been called for a calculated, tunable or changing Clock the FMU provides the information on when the Clock will tick again, i.e. when the corresponding model partition has to be scheduled the next time.

Each fmi3ActivateModelPartition call is associated with the computation of an exposed model partition of the FMU and therefore to an input Clock.
"""
# ToDo: Function is untested!
function fmi3ActivateModelPartition(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::fmi3ValueReference, activationTime::AbstractArray{fmi3Float64})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3ValueReference, Ptr{fmi3Float64}),
                c, vr, activationTime)
    @debug "fmi3ActiveModelPartition(c: $(c), vr: $(vr), activationTime $(activationTime)) → $(status)"
    return status
end
export fmi3ActivateModelPartition

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The number of dependencies of a given variable, which may change if structural parameters are changed, can be retrieved by calling fmi3GetNumberOfVariableDependencies.

This information can only be retrieved if the 'providesPerElementDependencies' tag in the ModelDescription is set.
"""
# ToDo: Function is untested!
function fmi3GetNumberOfVariableDependencies!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::fmi3ValueReference, nvr::Ref{Csize_t})
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3ValueReference, Ptr{Csize_t}),
                c, vr, nvr)
    @debug "fmi3GetNumberOfVariableDependencies(c: $(c), vr: $(vr), nvr: $(nvr)) → $(status)"
    return status
end
export fmi3GetNumberOfVariableDependencies!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.10. Dependencies of Variables

The actual dependencies (of type dependenciesKind) can be retrieved by calling the function fmi3GetVariableDependencies:

dependent - specifies the valueReference of the variable for which the dependencies should be returned.

nDependencies - specifies the number of dependencies that the calling environment allocated space for in the result buffers, and should correspond to value obtained by calling fmi3GetNumberOfVariableDependencies.

elementIndicesOfDependent - must point to a buffer of size_t values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the element index of the dependent variable that dependency information is provided for. The element indices start with 1. Using the element index 0 means all elements of the variable. (Note: If an array has more than one dimension the indices are serialized in the same order as defined for values in Section 2.2.6.1.)

independents -  must point to a buffer of fmi3ValueReference values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the value reference of the independent variable that this dependency entry is dependent upon.

elementIndicesIndependents - must point to a buffer of size_t values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the element index of the independent variable that this dependency entry is dependent upon. The element indices start with 1. Using the element index 0 means all elements of the variable. (Note: If an array has more than one dimension the indices are serialized in the same order as defined for values in Section 2.2.6.1.)

dependencyKinds - must point to a buffer of dependenciesKind values of size nDependencies allocated by the calling environment. 
It is filled in by this function with the enumeration value describing the dependency of this dependency entry.
For more information about dependenciesKinds, call ?fmi3DependencyKind

If this function is called before the fmi3ExitInitializationMode call, it returns the initial dependencies. If this function is called after the fmi3ExitInitializationMode call, it returns the runtime dependencies. 
The retrieved dependency information of one variable becomes invalid as soon as a structural parameter linked to the variable or to any of its depending variables are set. As a consequence, if you change structural parameters affecting B or A, the dependency of B becomes invalid. The dependency information must change only if structural parameters are changed.

This information can only be retrieved if the 'providesPerElementDependencies' tag in the ModelDescription is set.
"""
# ToDo: Function is untested!
function fmi3GetVariableDependencies!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::fmi3ValueReference, elementIndiceOfDependents::AbstractArray{Csize_t}, independents::AbstractArray{fmi3ValueReference},  elementIndiceOfInpendents::AbstractArray{Csize_t}, dependencyKind::AbstractArray{fmi3DependencyKind}, ndependencies::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, fmi3ValueReference, Ptr{Csize_t}, Ptr{fmi3ValueReference}, Ptr{Csize_t}, Ptr{fmi3DependencyKind}, Csize_t),
                c, vr, elementIndiceOfDependents, independents, elementIndiceOfInpendents, dependencyKind, ndependencies)
    @debug "fmi3GetVariableDependencies(c: $(c), vr: $(vr), elementIndiceOfDependets: $(elementIndiceOfDependets), independents: $(independents), elementIndiceOfInpendents: $(elementIndiceOfInpendents), dependencyKind: $(dependencyKind), ndependencies: $(ndependencies)) → $(status)"
    return status
end
export fmi3GetVariableDependencies!

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

This function computes the directional derivatives v_{sensitivity} = J ⋅ v_{seed} of an FMU.

unknowns - contains value references to the unknowns.

nUnknowns - contains the length of argument unknowns.

knowns - contains value references of the knowns.

nKnowns - contains the length of argument knowns.

seed - contains the components of the seed vector.

nSeed - contains the length of seed.

sensitivity - contains the components of the sensitivity vector.

nSensitivity - contains the length of sensitivity.

This function can only be called if the 'ProvidesDirectionalDerivatives' tag in the ModelDescription is set.
"""
function fmi3GetDirectionalDerivative!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                       unknowns::AbstractArray{fmi3ValueReference},
                                       nUnknowns::Csize_t,
                                       knowns::AbstractArray{fmi3ValueReference},
                                       nKnowns::Csize_t,
                                       seed::AbstractArray{fmi3Float64},
                                       nSeed::Csize_t,
                                       sensitivity::AbstractArray{fmi3Float64},
                                       nSensitivity::Csize_t)
    @assert fmi3ProvidesDirectionalDerivatives(c.fmu) ["fmi3GetDirectionalDerivative!(...): This FMU does not support build-in directional derivatives!"]
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c, unknowns, nUnknowns, knowns, nKnowns, seed, nSeed, sensitivity, nSensitivity)
    @debug "fmi3GetDirectionalDerivative(c: $(c), unknowns: $(unknowns), nUnknowns: $(nUnknowns), knowns: $(knowns), nKnowns: $(nKnowns), seed: $(seed), nSeed: $(nSeed), sensitivity: $(sensitivity), nSensitivity: $(nSensitivity)) → $(status)"
    return status
end
export fmi3GetDirectionalDerivative!

# TODO not tested
"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.11. Getting Partial Derivatives

This function computes the adjoint derivatives v^T_{sensitivity}= v^T_{seed} ⋅ J of an FMU.

unknowns - contains value references to the unknowns.

nUnknowns - contains the length of argument unknowns.

knowns - contains value references of the knowns.

nKnowns - contains the length of argument knowns.

seed - contains the components of the seed vector.

nSeed - contains the length of seed.

sensitivity - contains the components of the sensitivity vector.

nSensitivity - contains the length of sensitivity.

This function can only be called if the 'ProvidesAdjointDerivatives' tag in the ModelDescription is set.
"""
function fmi3GetAdjointDerivative!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                       unknowns::AbstractArray{fmi3ValueReference},
                                       nUnknowns::Csize_t,
                                       knowns::AbstractArray{fmi3ValueReference},
                                       nKnowns::Csize_t,
                                       seed::AbstractArray{fmi3Float64},
                                       nSeed::Csize_t,
                                       sensitivity::AbstractArray{fmi3Float64},
                                       nSensitivity::Csize_t)
    @assert fmi3ProvidesAdjointDerivatives(c.fmu) ["fmi3GetAdjointDerivative!(...): This FMU does not support build-in adjoint derivatives!"]
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Float64}, Csize_t, Ptr{fmi3Float64}, Csize_t),
          c, unknowns, nUnknowns, knowns, nKnowns, seed, nSeed, sensitivity, nSensitivity)
    @debug "fmi3GetAdjointDerivative(c: $(c), unknowns: $(unknowns), nUnknowns: $(nUnknowns), knowns: $(knowns), nKnowns: $(nKnowns), seed: $(seed), nSeed: $(nSeed), sensitivity: $(sensitivity), nSensitivity: $(nSensitivity)) → $(status)"
    return status
end
export fmi3GetAdjointDerivative!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.2.12. Getting Derivatives of Continuous Outputs

Retrieves the n-th derivative of output values.

valueReferences - is a vector of value references that define the variables whose derivatives shall be retrieved. If multiple derivatives of a variable shall be retrieved, list the value reference multiple times.

nValueReferences - is the dimension of the arguments valueReferences and orders.

orders - contains the orders of the respective derivative (1 means the first derivative, 2 means the second derivative, …, 0 is not allowed). 
If multiple derivatives of a variable shall be retrieved, provide a list of them in the orders array, corresponding to a multiply occurring value reference in the valueReferences array.
The highest order of derivatives retrievable can be determined by the 'maxOutputDerivativeOrder' tag in the ModelDescription.

values - is a vector with the values of the derivatives. The order of the values elements is derived from a twofold serialization: the outer level corresponds to the combination of a value reference (e.g., valueReferences[k]) and order (e.g., orders[k]), and the inner level to the serialization of variables as defined in Section 2.2.6.1. The inner level does not exist for scalar variables.

nValues - is the size of the argument values. nValues only equals nValueReferences if all corresponding output variables are scalar variables.
"""
function fmi3GetOutputDerivatives!(cfunc::Ptr{Nothing}, c::fmi3Instance, vr::AbstractArray{fmi3ValueReference}, nValueReferences::Csize_t, order::AbstractArray{fmi3Int32}, values::AbstractArray{fmi3Float64}, nValues::Csize_t)
    status = ccall(cfunc,
                fmi3Status,
                (fmi3Instance, Ptr{fmi3ValueReference}, Csize_t, Ptr{fmi3Int32}, Ptr{fmi3Float64}, Csize_t),
                c, vr, nValueReferences, order, values, nValues)
    @debug "fmi3GetOutputDerivatives(c: $(c), vr: $(vr), nValueReferences: $(nValueReferences), order: $(order), value: $(value), nValues: $(nValues)) → $(status)"
    return status
end
export fmi3GetOutputDerivatives!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

If the importer needs to change structural parameters, it must move the FMU into Configuration Mode using fmi3EnterConfigurationMode.
"""
function fmi3EnterConfigurationMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc,
            fmi3Status,
            (fmi3Instance,),
            c)
    @debug "fmi3EnterConfigurationMode(c: $(c)) → $(status)"
    return status
end
export fmi3EnterConfigurationMode

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.6. State: Configuration Mode

Exits the Configuration Mode and returns to state Instantiated.
"""
function fmi3ExitConfigurationMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
    @debug "fmi3ExitConfigurationMode(c: $(c)) → $(status)"
    return status
end
export fmi3ExitConfigurationMode

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of continuous states.
This function can only be called in Model Exchange. 

fmi3GetNumberOfContinuousStates must be called after a structural parameter is changed. As long as no structural parameters changed, the number of states is given in the modelDescription.xml, alleviating the need to call this function.
"""
function fmi3GetNumberOfContinuousStates!(cfunc::Ptr{Nothing}, c::fmi3Instance, nContinuousStates::Ref{Csize_t})
    status = ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{Csize_t}),
            c, nContinuousStates)
    @debug "fmi3GetNumberOfContinuousStates(c: $(c), nContinuousStates: $(nContinuousStates)) → $(status)"
    return status
end
export fmi3GetNumberOfContinuousStates!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.2. State: Instantiated

This function returns the number of event indicators.
This function can only be called in Model Exchange. 

fmi3GetNumberOfEventIndicators must be called after a structural parameter is changed. As long as no structural parameters changed, the number of states is given in the modelDescription.xml, alleviating the need to call this function.
"""
function fmi3GetNumberOfEventIndicators!(cfunc::Ptr{Nothing}, c::fmi3Instance, nEventIndicators::Ref{Csize_t})
    ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{Csize_t}),
            c, nEventIndicators)
    @debug "fmi3GetNumberOfEventIndicators(c: $(c), nEventIndicators: $(nEventIndicators)) → $(status)"
    return status
end
export fmi3GetNumberOfEventIndicators!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the states at the current time instant.

This function must be called if fmi3UpdateDiscreteStates returned with valuesOfContinuousStatesChanged == fmi3True. Not allowed in Co-Simulation and Scheduled Execution.
"""
function fmi3GetContinuousStates!(cfunc::Ptr{Nothing}, c::fmi3Instance, nominals::AbstractArray{fmi3Float64}, nContinuousStates::Csize_t)
    status = ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
            c, nominals, nContinuousStates)
    @debug "fmi3GetContinuousStates(c: $(c), nominals: $(nominals), nContinuousStates: $(nContinuousStates)) → $(status)"
    return status
end
export fmi3GetContinuousStates!

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

Return the nominal values of the continuous states.

If fmi3UpdateDiscreteStates returned with nominalsOfContinuousStatesChanged == fmi3True, then at least one nominal value of the states has changed and can be inquired with fmi3GetNominalsOfContinuousStates.
Not allowed in Co-Simulation and Scheduled Execution.
"""
function fmi3GetNominalsOfContinuousStates!(cfunc::Ptr{Nothing}, c::fmi3Instance, x_nominal::AbstractArray{fmi3Float64}, nx::Csize_t)
    status = ccall(cfunc,
                    fmi3Status,
                    (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
                    c, x_nominal, nx)
    @debug "fmi3GetNominalsOfContinuousStates(c: $(c), x_nominal: $(x_nominal), nx: $(nx)) → $(status)"
    return status
end
export fmi3GetNominalsOfContinuousStates!

# TODO not testable not supported by FMU
"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.3. State: Initialization Mode

This function is called to trigger the evaluation of fdisc to compute the current values of discrete states from previous values. 
The FMU signals the support of fmi3EvaluateDiscreteStates via the capability flag providesEvaluateDiscreteStates.
"""
function fmi3EvaluateDiscreteStates(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc,
            fmi3Status,
            (fmi3Instance,),
            c)
    @debug "fmi3EvaluateDiscreteStates(c: $(c)) → $(status)"
    return status
end
export fmi3EvaluateDiscreteStates

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function is called to signal a converged solution at the current super-dense time instant. fmi3UpdateDiscreteStates must be called at least once per super-dense time instant.
"""
function fmi3UpdateDiscreteStates(cfunc::Ptr{Nothing}, c::fmi3Instance, discreteStatesNeedUpdate::Ref{fmi3Boolean}, terminateSimulation::Ref{fmi3Boolean}, 
                                    nominalsOfContinuousStatesChanged::Ref{fmi3Boolean}, valuesOfContinuousStatesChanged::Ref{fmi3Boolean},
                                    nextEventTimeDefined::Ref{fmi3Boolean}, nextEventTime::Ref{fmi3Float64})
    status = ccall(cfunc,
            fmi3Status,
            (fmi3Instance, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Float64}),
            c, discreteStatesNeedUpdate, terminateSimulation, nominalsOfContinuousStatesChanged, valuesOfContinuousStatesChanged, nextEventTimeDefined, nextEventTime)
    @debug "fmi3UpdateDiscreteStates(c: $(c), discreteStatesNeedUpdate: $(discreteStatesNeedUpdate), terminateSimulation: $(terminateSimulation), nominalsOfContinuousStatesChanged: $(nominalsOfContinuousStatesChanged), valuesOfContinuousStatesChanged: $(valuesOfContinuousStatesChanged), nextEventTimeDefined: $(nextEventTimeDefined), nextEventTime: $(nextEventTime)) → $(status)"
    return status
end
export fmi3UpdateDiscreteStates

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi3EnterContinuousTimeMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
    @debug "fmi3EnterContinuousTimeMode(c: $(c)) → $(status)"
    return status
end
export fmi3EnterContinuousTimeMode

"""
Source: FMISpec3.0, Version D5ef1c1: 2.3.5. State: Event Mode

This function must be called to change from Event Mode into Step Mode in Co-Simulation (see 4.2.).
"""
function fmi3EnterStepMode(cfunc::Ptr{Nothing}, c::fmi3Instance)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance,),
          c)
    @debug "fmi3EnterStepMode(c: $(c)) → $(status)"
    return status
end
export fmi3EnterStepMode

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi3SetTime(cfunc::Ptr{Nothing}, c::fmi3Instance, time::fmi3Float64)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, fmi3Float64),
          c, time)
    @debug "fmi3SetTime(c: $(c), time: $(time)) → $(status)"
    return status
end
export fmi3SetTime

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi3SetContinuousStates(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                 x::AbstractArray{fmi3Float64},
                                 nx::Csize_t)
    status = ccall(cfunc,
         fmi3Status,
         (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
         c, x, nx)
    @debug "fmi3SetContinuousStates(c: $(c), x: $(x), nx: $(nx)) → $(status)"
    return status    
end
export fmi3SetContinuousStates

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Compute first-oder state derivatives at the current time instant and for the current states.
"""
function fmi3GetContinuousStateDerivatives!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                            derivatives::AbstractArray{fmi3Float64},
                            nx::Csize_t)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
          c, derivatives, nx)
    @debug "fmi3GetContinuousStateDerivatives(c: $(c), derivatives: $(derivatives), nx: $(nx)) → $(status)"
    return status
end
export fmi3GetContinuousStateDerivatives!

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

Compute event indicators at the current time instant and for the current states. EventIndicators signal Events by their sign change.
"""
function fmi3GetEventIndicators!(cfunc::Ptr{Nothing}, c::fmi3Instance, eventIndicators::AbstractArray{fmi3Float64}, ni::Csize_t)
    status = ccall(cfunc,
                    fmi3Status,
                    (fmi3Instance, Ptr{fmi3Float64}, Csize_t),
                    c, eventIndicators, ni)
    @debug "fmi3GetEventIndicators(c: $(c), eventIndicators: $(eventIndicators), ni: $(ni)) → $(status)"
    return status
end
export fmi3GetEventIndicators!

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

This function must be called by the environment after every completed step of the integrator provided the capability flag needsCompletedIntegratorStep = true.
If enterEventMode == fmi3True, the event mode must be entered
If terminateSimulation == fmi3True, the simulation shall be terminated
"""
function fmi3CompletedIntegratorStep!(cfunc::Ptr{Nothing}, c::fmi3Instance,
                                      noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
                                      enterEventMode::Ref{fmi3Boolean},
                                      terminateSimulation::Ref{fmi3Boolean})
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}),
          c, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation)
    @debug "fmi3CompletedIntegratorStep(c: $(c), noSetFMUStatePriorToCurrentPoint: $(noSetFMUStatePriorToCurrentPoint), enterEventMode: $(enterEventMode), terminateSimulation: $(terminateSimulation)) → $(status)"
    return status
end
export fmi3CompletedIntegratorStep!

"""
Source: FMISpec3.0, Version D5ef1c1: 3.2.1. State: Continuous-Time Mode

The model enters Event Mode from the Continuous-Time Mode in ModelExchange oder Step Mode in CoSimulation and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi3EnterEventMode(cfunc::Ptr{Nothing}, c::fmi3Instance, stepEvent::fmi3Boolean, stateEvent::fmi3Boolean, rootsFound::AbstractArray{fmi3Int32}, nEventIndicators::Csize_t, timeEvent::fmi3Boolean)
    status = ccall(cfunc,
          fmi3Status,
          (fmi3Instance,fmi3Boolean, fmi3Boolean, Ptr{fmi3Int32}, Csize_t, fmi3Boolean),
          c, stepEvent, stateEvent, rootsFound, nEventIndicators, timeEvent)
    @debug "fmi3EnterEventMode(c: $(c), stepEvent: $(stepEvent), stateEvent: $(stateEvent), rootsFound: $(rootsFound), nEventIndicators: $(nEventIndicators), timeEvent: $(timeEvent)) → $(status)"
    return status
end
export fmi3EnterEventMode

"""
Source: FMISpec3.0, Version D5ef1c1: 4.2.1. State: Step Mode

The computation of a time step is started.
"""
function fmi3DoStep!(cfunc::Ptr{Nothing}, c::fmi3Instance, currentCommunicationPoint::fmi3Float64, communicationStepSize::fmi3Float64, noSetFMUStatePriorToCurrentPoint::fmi3Boolean,
                    eventEncountered::Ref{fmi3Boolean}, terminateSimulation::Ref{fmi3Boolean}, earlyReturn::Ref{fmi3Boolean}, lastSuccessfulTime::Ref{fmi3Float64})
    @assert cfunc != C_NULL ["fmi3DoStep(...): This FMU does not support fmi3DoStep, probably it's a ME-FMU with no CS-support?"]

    status = ccall(cfunc, fmi3Status,
          (fmi3Instance, fmi3Float64, fmi3Float64, fmi3Boolean, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Boolean}, Ptr{fmi3Float64}),
          c, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint, eventEncountered, terminateSimulation, earlyReturn, lastSuccessfulTime)
    @debug "fmi3DoStep(c: $(c), currentCommunicationPoint: $(currentCommunicationPoint), communicationStepSize: $(communicationStepSize), noSetFMUStatePriorToCurrentPoint: $(noSetFMUStatePriorToCurrentPoint), eventEncountered: $(eventEncountered), terminateSimulation: $(terminateSimulation), earlyReturn: $(earlyReturn), lastSuccessfulTime: $(lastSuccessfulTime)) → $(status)"
    return status
end
export fmi3DoStep!

