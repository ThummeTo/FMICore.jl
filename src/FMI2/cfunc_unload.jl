#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#
ret_val = fmi2StatusError
warn_str = "You can't call fun after fmi2Unload!"

"""
Source: FMISpec2.0.2[p.19]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function returns a new instance of an FMU.
"""
function fmi2Instantiate(cfunc::Nothing,
                         instanceName::fmi2String,
                         fmuType::fmi2Type,
                         fmuGUID::fmi2String,
                         fmuResourceLocation::fmi2String,
                         functions::Ptr{fmi2CallbackFunctions},
                         visible::fmi2Boolean,
                         loggingOn::fmi2Boolean)

    @warn warn_str
    return ret_val
end
export fmi2Instantiate

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

Disposes the given instance, unloads the loaded model, and frees all the allocated memory and other resources that have been allocated by the functions of the FMU interface.
If a null pointer is provided for “c”, the function call is ignored (does not have an effect).

Removes the component from the FMUs component list.
"""
function fmi2FreeInstance!(cfunc::Nothing, c::fmi2Component)

    @warn warn_str
    return nothing
end
export fmi2FreeInstance!

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the string to uniquely identify the “fmi2TypesPlatform.h” header file used for compilation of the functions of the FMU.
The standard header file, as documented in this specification, has fmi2TypesPlatform set to “default” (so this function usually returns “default”).
"""
function fmi2GetTypesPlatform(cfunc::Nothing)
    @warn warn_str
    return pointer("no version")
end
export fmi2GetTypesPlatform

"""
Source: FMISpec2.0.2[p.22]: 2.1.4 Inquire Platform and Version Number of Header Files

Returns the version of the “fmi2Functions.h” header file which was used to compile the functions of the FMU. The function returns “fmiVersion” which is defined in this header file. The standard header file as documented in this specification has version “2.0”
"""
function fmi2GetVersion(cfunc::Nothing)
    @warn warn_str
    return pointer("no version")
end
export fmi2GetVersion

"""
Source: FMISpec2.0.2[p.22]: 2.1.5 Creation, Destruction and Logging of FMU Instances

The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetDebugLogging(cfunc::Nothing, c::fmi2Component, logginOn::fmi2Boolean, nCategories::Csize_t, categories::Union{Ptr{fmi2String}, AbstractArray{fmi2String}})
    @warn warn_str
    return ret_val
end
export fmi2SetDebugLogging

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to setup the experiment. This function must be called after fmi2Instantiate and before fmi2EnterInitializationMode is called.The function controls debug logging that is output via the logger function callback. If loggingOn = fmi2True, debug logging is enabled, otherwise it is switched off.
"""
function fmi2SetupExperiment(cfunc::Nothing, 
                             c::fmi2Component,
                             toleranceDefined::fmi2Boolean,
                             tolerance::fmi2Real,
                             startTime::fmi2Real,
                             stopTimeDefined::fmi2Boolean,
                             stopTime::fmi2Real)

    @warn warn_str
    return ret_val
end
export fmi2SetupExperiment

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to enter Initialization Mode. Before calling this function, all variables with attribute <ScalarVariable initial = "exact" or "approx"> can be set with the “fmi2SetXXX” functions (the ScalarVariable attributes are defined in the Model Description File, see section 2.2.7). Setting other variables is not allowed. Furthermore, fmi2SetupExperiment must be called at least once before calling fmi2EnterInitializationMode, in order that startTime is defined.
"""
function fmi2EnterInitializationMode(cfunc::Nothing, c::fmi2Component)

    @warn warn_str
    return ret_val
end
export fmi2EnterInitializationMode

"""
Source: FMISpec2.0.2[p.23]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU to exit Initialization Mode.
"""
function fmi2ExitInitializationMode(cfunc::Nothing, c::fmi2Component)

    @warn warn_str
    return ret_val
end
export fmi2ExitInitializationMode

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Informs the FMU that the simulation run is terminated.
"""
function fmi2Terminate(cfunc::Nothing, c::fmi2Component)
  
    @warn warn_str
    return ret_val
end
export fmi2Terminate

"""
Source: FMISpec2.0.2[p.24]: 2.1.6 Initialization, Termination, and Resetting an FMU

Is called by the environment to reset the FMU after a simulation run. The FMU goes into the same state as if fmi2Instantiate would have been called.
"""
function fmi2Reset(cfunc::Nothing, c::fmi2Component)

    @warn warn_str
    return ret_val
end
export fmi2Reset

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetReal!(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}})

    @warn warn_str
    return ret_val
end
export fmi2GetReal!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetReal(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}})

    @warn warn_str
    return ret_val
end
export fmi2SetReal

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetInteger!(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Integer}, Ptr{fmi2Integer}})

    @warn warn_str
    return ret_val
end
export fmi2GetInteger!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetInteger(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Integer}, Ptr{fmi2Integer}})

    @warn warn_str
    return ret_val
end
export fmi2SetInteger

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetBoolean!(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Boolean}, Ptr{fmi2Boolean}})
    @warn warn_str
    return ret_val
end
export fmi2GetBoolean!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetBoolean(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2Boolean}, Ptr{fmi2Boolean}})
    @warn warn_str
    return ret_val
end
export fmi2SetBoolean

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2GetString!(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2String}, Ptr{fmi2String}})
    @warn warn_str
    return ret_val
end
export fmi2GetString!

"""
Source: FMISpec2.0.2[p.24]: 2.1.7 Getting and Setting Variable Values

Functions to get and set values of variables idetified by their valueReference
"""
function fmi2SetString(cfunc::Nothing, c::fmi2Component, vr::Union{AbstractArray{fmi2ValueReference}, Ptr{fmi2ValueReference}}, nvr::Csize_t, value::Union{AbstractArray{fmi2String}, Ptr{fmi2String}})
    @warn warn_str
    return ret_val
end
export fmi2SetString

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2GetFMUstate makes a copy of the internal FMU state and returns a pointer to this copy
"""
function fmi2GetFMUstate!(cfunc::Nothing, c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    @warn warn_str
    return ret_val
end
export fmi2GetFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SetFMUstate copies the content of the previously copied FMUstate back and uses it as actual new FMU state.
"""
function fmi2SetFMUstate(cfunc::Nothing, c::fmi2Component, FMUstate::fmi2FMUstate)
    @warn warn_str
    return ret_val
end
export fmi2SetFMUstate

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2FreeFMUstate frees all memory and other resources allocated with the fmi2GetFMUstate call for this FMUstate.
"""
function fmi2FreeFMUstate!(cfunc::Nothing, c::fmi2Component, FMUstate::Ref{fmi2FMUstate})
    @warn warn_str
    return ret_val
end
export fmi2FreeFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializedFMUstateSize returns the size of the byte vector, in order that FMUstate can be stored in it.
"""
function fmi2SerializedFMUstateSize!(cfunc::Nothing, c::fmi2Component, FMUstate::fmi2FMUstate, size::Ref{Csize_t})
    @warn warn_str
    return ret_val
end
export fmi2SerializedFMUstateSize!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2SerializeFMUstate serializes the data which is referenced by pointer FMUstate and copies this data in to the byte vector serializedState of length size
"""
function fmi2SerializeFMUstate!(cfunc::Nothing, c::fmi2Component, FMUstate::fmi2FMUstate, serialzedState::AbstractArray{fmi2Byte}, size::Csize_t)
    @warn warn_str
    return ret_val
end
export fmi2SerializeFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.8 Getting and Setting the Complete FMU State

fmi2DeSerializeFMUstate deserializes the byte vector serializedState of length size, constructs a copy of the FMU state and returns FMUstate, the pointer to this copy.
"""
function fmi2DeSerializeFMUstate!(cfunc::Nothing, c::fmi2Component, serializedState::AbstractArray{fmi2Byte}, size::Csize_t, FMUstate::Ref{fmi2FMUstate})
    @warn warn_str
    return ret_val
end
export fmi2DeSerializeFMUstate!

"""
Source: FMISpec2.0.2[p.26]: 2.1.9 Getting Partial Derivatives

This function computes the directional derivatives of an FMU.

    ΔvUnknown = ∂h / ∂vKnown ⋅ ΔvKnown
"""
function fmi2GetDirectionalDerivative!(cfunc::Nothing, 
                                       c::fmi2Component,
                                       vUnknown_ref::AbstractArray{fmi2ValueReference},
                                       nUnknown::Csize_t,
                                       vKnown_ref::AbstractArray{fmi2ValueReference},
                                       nKnown::Csize_t,
                                       ΔvKnown::AbstractArray{fmi2Real},
                                       ΔvUnknown::AbstractArray{fmi2Real})
    @warn warn_str
    return ret_val
end
export fmi2GetDirectionalDerivative!

# Functions specificly for Co-Simulation

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Sets the n-th time derivative of real input variables.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2SetRealInputDerivatives(cfunc::Nothing, c::fmi2Component, vr::AbstractArray{fmi2ValueReference}, nvr::Csize_t, order::AbstractArray{fmi2Integer}, value::AbstractArray{fmi2Real})
    @warn warn_str
    return ret_val
end
export fmi2SetRealInputDerivatives

"""
Source: FMISpec2.0.2[p.104]: 4.2.1 Transfer of Input / Output Values and Parameters

Retrieves the n-th derivative of output values.
vr defines the value references of the variables
the array order specifies the corresponding order of derivation of the variables
"""
function fmi2GetRealOutputDerivatives!(cfunc::Nothing, c::fmi2Component, vr::AbstractArray{fmi2ValueReference}, nvr::Csize_t, order::AbstractArray{fmi2Integer}, value::AbstractArray{fmi2Real})
    @warn warn_str
    return ret_val
end
export fmi2GetRealOutputDerivatives!

"""
Source: FMISpec2.0.2[p.104]: 4.2.2 Computation

The computation of a time step is started.
"""
function fmi2DoStep(cfunc::Nothing, c::fmi2Component, currentCommunicationPoint::fmi2Real, communicationStepSize::fmi2Real, noSetFMUStatePriorToCurrentPoint::fmi2Boolean)
    @warn warn_str
    return ret_val
end
export fmi2DoStep

"""
Source: FMISpec2.0.2[p.105]: 4.2.2 Computation

Can be called if fmi2DoStep returned fmi2Pending in order to stop the current asynchronous execution.
"""
function fmi2CancelStep(cfunc::Nothing, c::fmi2Component)
    @warn warn_str
    return ret_val
end
export fmi2CancelStep

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStatus!(cfunc::Nothing, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Status})
    @warn warn_str
    return ret_val
end
export fmi2GetStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetRealStatus!(cfunc::Nothing, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Real})
    @warn warn_str
    return ret_val
end
export fmi2GetRealStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetIntegerStatus!(cfunc::Nothing, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Integer})
    @warn warn_str
    return ret_val
end
export fmi2GetIntegerStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetBooleanStatus!(cfunc::Nothing, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2Boolean})
    @warn warn_str
    return ret_val
end
export fmi2GetBooleanStatus!

"""
Source: FMISpec2.0.2[p.106]: 4.2.3 Retrieving Status Information from the Slave

Informs the master about the actual status of the simulation run. Which status information is to be returned is specified by the argument fmi2StatusKind.
"""
function fmi2GetStringStatus!(cfunc::Nothing, c::fmi2Component, s::fmi2StatusKind, value::Ptr{fmi2String})
    @warn warn_str
    return ret_val
end
export fmi2GetStringStatus!

# Model Exchange specific Functions

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new time instant and re-initialize caching of variables that depend on time, provided the newly provided time value is different to the previously set time value (variables that depend solely on constants or parameters need not to be newly computed in the sequel, but the previously computed values can be reused).
"""
function fmi2SetTime(cfunc::Nothing, c::fmi2Component, time::fmi2Real)
    @warn warn_str
    return ret_val
end
export fmi2SetTime

"""
Source: FMISpec2.0.2[p.83]: 3.2.1 Providing Independent Variables and Re-initialization of Caching

Set a new (continuous) state vector and re-initialize caching of variables that depend on the states. Argument nx is the length of vector x and is provided for checking purposes
"""
function fmi2SetContinuousStates(cfunc::Nothing, c::fmi2Component, x::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, nx::Csize_t)
    @warn warn_str
    return ret_val
end
export fmi2SetContinuousStates

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The model enters Event Mode from the Continuous-Time Mode and discrete-time equations may become active (and relations are not “frozen”).
"""
function fmi2EnterEventMode(cfunc::Nothing, c::fmi2Component)
    @warn warn_str
    return ret_val
end
export fmi2EnterEventMode

"""
Source: FMISpec2.0.2[p.84]: 3.2.2 Evaluation of Model Equations

The FMU is in Event Mode and the super dense time is incremented by this call.
"""
function fmi2NewDiscreteStates!(cfunc::Nothing, c::fmi2Component, eventInfo::Ptr{fmi2EventInfo})
    @warn warn_str
    return ret_val
end
export fmi2NewDiscreteStates!

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

The model enters Continuous-Time Mode and all discrete-time equations become inactive and all relations are “frozen”.
This function has to be called when changing from Event Mode (after the global event iteration in Event Mode over all involved FMUs and other models has converged) into Continuous-Time Mode.
"""
function fmi2EnterContinuousTimeMode(cfunc::Nothing, c::fmi2Component)
    @warn warn_str
    return ret_val
end
export fmi2EnterContinuousTimeMode

"""
Source: FMISpec2.0.2[p.85]: 3.2.2 Evaluation of Model Equations

This function must be called by the environment after every completed step of the integrator provided the capability flag completedIntegratorStepNotNeeded = false.
If enterEventMode == fmi2True, the event mode must be entered
If terminateSimulation == fmi2True, the simulation shall be terminated
"""
function fmi2CompletedIntegratorStep!(cfunc::Nothing, 
                                      c::fmi2Component,
                                      noSetFMUStatePriorToCurrentPoint::fmi2Boolean,
                                      enterEventMode::Ptr{fmi2Boolean},
                                      terminateSimulation::Ptr{fmi2Boolean})
    @warn warn_str
    return ret_val
end
export fmi2CompletedIntegratorStep!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute state derivatives at the current time instant and for the current states.
"""
function fmi2GetDerivatives!(cfunc::Nothing, 
                            c::fmi2Component,
                            derivatives::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}},
                            nx::Csize_t)
    @warn warn_str
    return ret_val
end
export fmi2GetDerivatives!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Compute event indicators at the current time instant and for the current states.
"""
function fmi2GetEventIndicators!(cfunc::Nothing, c::fmi2Component, eventIndicators::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, ni::Csize_t)
    @warn warn_str
    return ret_val
end
export fmi2GetEventIndicators!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the new (continuous) state vector x.
"""
function fmi2GetContinuousStates!(cfunc::Nothing, c::fmi2Component,
                                 x::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}},
                                 nx::Csize_t)
    @warn warn_str
    return ret_val
end
export fmi2GetContinuousStates!

"""
Source: FMISpec2.0.2[p.86]: 3.2.2 Evaluation of Model Equations

Return the nominal values of the continuous states.
"""
function fmi2GetNominalsOfContinuousStates!(cfunc::Nothing, c::fmi2Component, x_nominal::Union{AbstractArray{fmi2Real}, Ptr{fmi2Real}}, nx::Csize_t)
    @warn warn_str
    return ret_val
end
export fmi2GetNominalsOfContinuousStates!