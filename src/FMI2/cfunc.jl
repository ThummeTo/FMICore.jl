#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function returns a new instance of an FMU.
"""
function fmi2Instantiate(cfunc::Ptr{Nothing},
                         instanceName::fmi2String,
                         fmuType::fmi2Type,
                         fmuGUID::fmi2String,
                         fmuResourceLocation::fmi2String,
                         functions::Ptr{fmi2CallbackFunctions},
                         visible::fmi2Boolean,
                         loggingOn::fmi2Boolean)

    status = ccall(cfunc,
          Ptr{Cvoid},
          (fmi2String, fmi2Type, fmi2String, fmi2String, Ptr{Cvoid}, fmi2Boolean, fmi2Boolean),
          instanceName, fmuType, fmuGUID, fmuResourceLocation, functions, visible, loggingOn)

    @debug "fmi2Instantiate(instanceName: $(instanceName), fmuType: $(fmuType), fmuGUID: $(fmuGUID), fmuResourceLocation: $(fmuResourceLocation), functions: $(functions), visible: $(visible), loggingOn: $(loggingOn)) → $(status)"
    return status
end
export fmi2Instantiate

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Disposes the given instance, unloads the loaded model, and frees all the allocated memory and other resources that have been allocated by the functions of the FMU interface.
If a null pointer is provided for “c”, the function call is ignored (does not have an effect).

Removes the component from the FMUs component list.
"""
function fmi2FreeInstance!(cfunc::Ptr{Nothing}, c::fmi2Component)

    ccall(cfunc, Cvoid, (fmi2Component,), c)
    @debug "fmi2FreeInstance(c: $(c)) → [nothing]"
    return nothing
end
export fmi2FreeInstance!

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the string to uniquely identify the “fmi2TypesPlatform.h” header file used for compilation of the functions of the FMU.
The standard header file, as documented in this specification, has fmi2TypesPlatform set to “default” (so this function usually returns “default”).
"""
function fmi2GetTypesPlatform(cfunc::Ptr{Nothing})
    str = ccall(cfunc, fmi2String, ())
    @debug "fmi2GetTypesPlatform() → $(str)"
    return str
end
export fmi2GetTypesPlatform

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the version of the “fmi2Functions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0”
"""
function fmi2GetVersion(cfunc::Ptr{Nothing})
    str = ccall(cfunc, fmi2String, ())
    @debug "fmi2GetVersion() → $(str)"
    return str
end
export fmi2GetVersion

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetDebugLogging(cfunc::Ptr{Nothing}, c::fmi2Component, logginOn::fmi2Boolean, nCategories::Csize_t, categories::Union{Ptr{fmi2String}, AbstractArray{fmi2String}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Component, Csize_t, Ptr{fmi2String}),
          c, logginOn, nCategories, categories)
    @debug "fmi2SetDebugLogging(c: $(c), logginOn: $(loggingOn), nCategories: $(nCategories), categories: $(categories)) → $(status)"
    return status
end
export fmi2SetDebugLogging

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to setup the experiment. This function must be called after fmi2Instantiate and before fmi2EnterInitializationMode is called.The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetupExperiment(cfunc::Ptr{Nothing}, 
                             c::fmi2Component,
                             toleranceDefined::fmi2Boolean,
                             tolerance::fmi2Real,
                             startTime::fmi2Real,
                             stopTimeDefined::fmi2Boolean,
                             stopTime::fmi2Real)

    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Boolean, fmi2Real, fmi2Real, fmi2Boolean, fmi2Real),
          c, toleranceDefined, tolerance, startTime, stopTimeDefined, stopTime)
    @debug "fmi2SetupExperiment(c: $(c), toleranceDefined: $(toleranceDefined), tolerance: $(tolerance), startTime: $(startTime), stopTimeDefined: $(stopTimeDefined), stopTime: $(stopTime)) → $(status)"
    return status
end
export fmi2SetupExperiment

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <ScalarVariable initial = "exact" or "approx"> can be set with the “fmi2SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.2.7). Setting other variables is not allowed. Furthermore, fmi2SetupExperiment must be called at least once before calling fmi2EnterInitializationMode, in order that startTime is defined.
"""
function fmi2EnterInitializationMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2EnterInitializationMode(c: $(c)) → $(status)" 
    return status
end
export fmi2EnterInitializationMode

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to exit Initialization Mode.
"""
function fmi2ExitInitializationMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2ExitInitializationMode(c: $(c)) → $(status)" 
    return status
end
export fmi2ExitInitializationMode

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU that the simulation run is terminated.
"""
function fmi2Terminate(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc, 
          fmi2Status, 
          (fmi2Component,), 
          c)
    @debug "fmi2Terminate(c: $(c)) → $(status)" 
    return status
end
export fmi2Terminate

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi2Instantiate would have been called.
"""
function fmi2Reset(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc, 
          fmi2Status, 
          (fmi2Component,), 
          c)
    @debug "fmi2Reset(c: $(c)) → $(status)" 
    return status
end
export fmi2Reset

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetReal!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}),
          c, vr, nvr, value)
    @debug "fmi2GetReal(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)" 
    return status
end
export fmi2GetReal!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetReal(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}),
          c, vr, nvr, value)
    @debug "fmi2SetReal(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value))"
    return status
end
export fmi2SetReal

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetInteger!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Integer}, Ptr{fmi2Integer}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}),
          c, vr, nvr, value)
    @debug "fmi2GetInteger(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end
export fmi2GetInteger!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetInteger(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Integer}, Ptr{fmi2Integer}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}),
          c, vr, nvr, value)
    @debug "fmi2SetInteger(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end
export fmi2SetInteger

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetBoolean!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Boolean}, Ptr{fmi2Boolean}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}),
          c, vr, nvr, value)
    @debug "fmi2GetBoolean(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end
export fmi2GetBoolean!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetBoolean(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Boolean}, Ptr{fmi2Boolean}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Boolean}),
          c, vr, nvr, value)
    @debug "fmi2SetBoolean(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end
export fmi2SetBoolean

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetString!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2String}, Ptr{fmi2String}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String}),
          c, vr, nvr, value)
    @debug "fmi2GetString(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end
export fmi2GetString!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetString(cfunc::Ptr{Nothing}, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2String}, Ptr{fmi2String}})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2String}),
          c, vr, nvr, value)
    @debug "fmi2SetString(c: $(c), vr: $(vr), nvr: $(nvr), value: $(value)) → $(status)"
    return status
end
export fmi2SetString

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi2GetFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2FMUstate}),
          c, FMUstate)
    @debug "fmi2GetFMUstate!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi2GetFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi2SetFMUstate(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::fmi2FMUstate)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2FMUstate),
          c, FMUstate)
    @debug "fmi2SetFMUstate(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi2SetFMUstate

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2FreeFMUstate frees all memory and other resources allocated with the fmi2GetFMUstate call for this FMUstate.
"""
function fmi2FreeFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2FMUstate}),
          c, FMUstate)
    @debug "fmi2FreeFMUstate!(c: $(c), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi2FreeFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializedFMUstateSize returns the size of the byte vector, in order that FMUstate can be stored in it.
"""
function fmi2SerializedFMUstateSize!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::fmi2FMUstate, size::Ref{Csize_t})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2FMUstate, Ptr{Csize_t}),
          c, FMUstate, size)
    @debug "fmi2SerializedFMUstateSize(c: $(c), FMUstate: $(FMUstate), size: $(size)) → $(status)"
    return status
end
export fmi2SerializedFMUstateSize!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi2SerializeFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, FMUstate::fmi2FMUstate, serialzedState::AbstractArray{fmi2Byte}, size::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2FMUstate, Ptr{fmi2Byte}, Csize_t),
          c, FMUstate, serialzedState, size)
    @debug "fmi2SerializeFMUstate(c: $(c), FMUstate: $(FMUstate), serialzedState: $(serializedState), size: $(size)) → $(status)"
    return status
end
export fmi2SerializeFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi2DeSerializeFMUstate!(cfunc::Ptr{Nothing}, c::fmi2Component, serializedState::AbstractArray{fmi2Byte}, size::Csize_t, FMUstate::Ref{fmi2FMUstate})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Byte}, Csize_t, Ptr{fmi2FMUstate}),
          c, serializedState, size, FMUstate)
    @debug "fmi2DeSerializeFMUstate(c: $(c), serializedState: $(serializedState), size: $(size), FMUstate: $(FMUstate)) → $(status)"
    return status
end
export fmi2DeSerializeFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.9 Getting Partial Derivatives

This function computes the directional derivatives of an FMU.

    ΔvUnknown = ∂h / ∂vKnown ⋅ ΔvKnown
"""
function fmi2GetDirectionalDerivative!(cfunc::Ptr{Nothing}, 
                                       c::fmi2Component,
                                       vUnknown_ref::AbstractArray{fmi2ValueReference},
                                       nUnknown::Csize_t,
                                       vKnown_ref::AbstractArray{fmi2ValueReference},
                                       nKnown::Csize_t,
                                       ΔvKnown::AbstractArray{fmi2Real},
                                       ΔvUnknown::AbstractArray{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Real}, Ptr{fmi2Real}),
          c, vUnknown_ref, nUnknown, vKnown_ref, nKnown, ΔvKnown, ΔvUnknown)
    @debug "fmi2GetDirectionalDerivative(c: $(c), vUnknown_ref: $(vUnknown_ref), nUnknown: $(nUnknown), vKnown_ref: $(vKnown_ref), nKnown: $(nKnown), ΔvKnown: $(ΔvKnown), ΔvUnknown: $(ΔvUnknown)) → $(status)"
    return status
end
export fmi2GetDirectionalDerivative!

# Functions specificly for Co-Simulation

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Sets the n-th time derivative of real input variables.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2SetRealInputDerivatives(cfunc::Ptr{Nothing}, c::fmi2Component, vr::AbstractArray{fmi2ValueReference}, nvr::Csize_t, order::AbstractArray{fmi2Integer}, value::AbstractArray{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}, Ptr{fmi2Real}),
          c, vr, nvr, order, value)
    @debug "fmi2SetRealInputDerivatives(c: $(c), vr: $(vr), nvr: $(nvr), order: $(order), value: $(value)) → $(status)"
    return status
end
export fmi2SetRealInputDerivatives

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Retrieves the n-th derivative of output values.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2GetRealOutputDerivatives!(cfunc::Ptr{Nothing}, c::fmi2Component, vr::AbstractArray{fmi2ValueReference}, nvr::Csize_t, order::AbstractArray{fmi2Integer}, value::AbstractArray{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2ValueReference}, Csize_t, Ptr{fmi2Integer}, Ptr{fmi2Real}),
          c, vr, nvr, order, value)
    @debug "fmi2GetRealOutputDerivatives(c: $(c), vr: $(vr), nvr: $(nvr), order: $(order), value: $(value)) → $(status)"
    return status
end
export fmi2GetRealOutputDerivatives!

"""
Source: FMISpec2.0.2[p.104]: 4.2.2 Computation

The computation of a time step is started.
"""
function fmi2DoStep(cfunc::Ptr{Nothing}, c::fmi2Component, currentCommunicationPoint::fmi2Real, communicationStepSize::fmi2Real, noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    status = ccall(cfunc, fmi2Status,
          (fmi2Component, fmi2Real, fmi2Real, fmi2Boolean),
          c, currentCommunicationPoint, communicationStepSize, noSetFMUStatePriorToCurrentPoint)
    @debug "fmi2DoStep(c: $(c), currentCommunicationPoint: $(currentCommunicationPoint), communicationStepSize: $(communicationStepSize), noSetFMUStatePriorToCurrentPoint: $(noSetFMUStatePriorToCurrentPoint)) → $(status)"
    return status
end
export fmi2DoStep

"""
Source: FMISpec2.0.2[p.105]: 4.2.2 Computation

Can be called if fmi2DoStep returned fmi2Pending in order to stop the current asynchronous execution.
"""
function fmi2CancelStep(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc, 
          fmi2Status, 
          (fmi2Component,), 
          c)
    @debug "fmi2CancelStep(c: $(c)) → $(status)"
    return status
end
export fmi2CancelStep

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Status})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Status}),
          c, s, value)
    @debug "fmi2GetStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end
export fmi2GetStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetRealStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Real})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Real}),
          c, s, value)
    @debug "fmi2GetRealStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end
export fmi2GetRealStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetIntegerStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Integer})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Integer}),
          c, s, value)
    @debug "fmi2GetIntegerStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end
export fmi2GetIntegerStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetBooleanStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Boolean})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2Boolean}),
          c, s, value)
    @debug "fmi2GetBooleanStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end
export fmi2GetBooleanStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStringStatus!(cfunc::Ptr{Nothing}, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2String})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2StatusKind, Ptr{fmi2String}),
          c, s, value)
    @debug "fmi2GetStringStatus(c: $(c), s: $(s), value: $(value)) → $(status)"
    return status
end
export fmi2GetStringStatus!

# Model Exchange specific Functions

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi2SetTime(cfunc::Ptr{Nothing}, c::fmi2Component, time::fmi2Real)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Real),
          c, time)
    @debug "fmi2SetTime(c: $(c), time: $(time)) → $(status)"
    return status
end
export fmi2SetTime

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi2SetContinuousStates(cfunc::Ptr{Nothing}, c::fmi2Component, x::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, nx::Csize_t)
    status = ccall(cfunc,
         fmi2Status,
         (fmi2Component, Ptr{fmi2Real}, Csize_t),
         c, x, nx)
    @debug "fmi2SetContinuousStates(c: $(c), x: $(x), nx: $(nx)) → $(status)"
    return status
end
export fmi2SetContinuousStates

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The model enters Event Mode from the Continuous-Time Mode and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi2EnterEventMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2EnterEventMode(c: $(c)) → $(status)"
    return status
end
export fmi2EnterEventMode

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The FMU is in Event Mode and the super dense time is incremented by this call.
"""
function fmi2NewDiscreteStates!(cfunc::Ptr{Nothing}, c::fmi2Component, eventInfo::Ptr{fmi2EventInfo})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2EventInfo}),
          c, eventInfo)
    @debug "fmi2NewDiscreteStates(c: $(c), eventInfo: $(eventInfo)) → $(status)"
    return status
end
export fmi2NewDiscreteStates!

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi2EnterContinuousTimeMode(cfunc::Ptr{Nothing}, c::fmi2Component)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component,),
          c)
    @debug "fmi2EnterContinuousTimeMode(c: $(c)) → $(status)"
    return status
end
export fmi2EnterContinuousTimeMode

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

This function must be called by the environment after every completed step of the integrator provided the capability flag completedIntegratorStepNotNeeded = false.
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated
"""
function fmi2CompletedIntegratorStep!(cfunc::Ptr{Nothing}, 
                                      c::fmi2Component,
                                      noSetFMUStatePriorToCurrentPoint::fmi2Boolean,
                                      enterEventMode::Ptr{fmi2Boolean},
                                      terminateSimulation::Ptr{fmi2Boolean})
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, fmi2Boolean, Ptr{fmi2Boolean}, Ptr{fmi2Boolean}),
          c, noSetFMUStatePriorToCurrentPoint, enterEventMode, terminateSimulation)
    @debug "fmi2CompletedIntegratorStep(c: $(c), noSetFMUStatePriorToCurrentPoint: $(noSetFMUStatePriorToCurrentPoint), enterEventMode: $(enterEventMode), terminateSimulation: $(terminateSimulation)) → $(status)"
    return status
end
export fmi2CompletedIntegratorStep!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute state derivatives at the current time instant and for the current states.
"""
function fmi2GetDerivatives!(cfunc::Ptr{Nothing}, 
                            c::fmi2Component,
                            derivatives::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}},
                            nx::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, derivatives, nx)
    @debug "fmi2GetDerivatives(c: $(c), derivatives: $(derivatives), nx: $(nx)) → $(status)"
    return status
end
export fmi2GetDerivatives!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute event indicators at the current time instant and for the current states.
"""
function fmi2GetEventIndicators!(cfunc::Ptr{Nothing}, c::fmi2Component, eventIndicators::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, ni::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, eventIndicators, ni)
    @debug "fmi2GetEventIndicators(c: $(c), eventIndicators: $(eventIndicators), ni: $(ni)) → $(status)"
    return status
end
export fmi2GetEventIndicators!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the new (continuous) state vector x.
"""
function fmi2GetContinuousStates!(cfunc::Ptr{Nothing}, c::fmi2Component,
                                 x::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}},
                                 nx::Csize_t)
    status = ccall(cfunc, 
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, x, nx)
    @debug "fmi2GetContinuousStates(c: $(c), x: $(x), nx: $(nx)) → $(status)"
    return status
end
export fmi2GetContinuousStates!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the nominal values of the continuous states.
"""
function fmi2GetNominalsOfContinuousStates!(cfunc::Ptr{Nothing}, c::fmi2Component, x_nominal::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, nx::Csize_t)
    status = ccall(cfunc,
          fmi2Status,
          (fmi2Component, Ptr{fmi2Real}, Csize_t),
          c, x_nominal, nx)
    @debug "fmi2GetNominalsOfContinuousStates(c: $(c), x_nominal: $(x_nominal), nx: $(nx)) → $(status)"
    return status
end
export fmi2GetNominalsOfContinuousStates!