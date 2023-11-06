#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function unload_fmi2GetTypesPlatform()
    @assert false "The function `fmi2GetTypesPlatform` is not callable anymore, because the FMU is unloaded!"
    str = "" 
    return pointer(str)
end

function unload_fmi2GetVersion()
    @assert false "The function `fmi2GetVersion()` is not callable anymore, because the FMU is unloaded!"
    str = "" 
    return pointer(str)
end

# 2.1.5
function unload_fmi2Instantiate(_instanceName::fmi2String,
                                         fmuType::fmi2Type,
                                         _fmuGUID::fmi2String,
                                         _fmuResourceLocation::fmi2String,
                                         _functions::Ptr{fmi2CallbackFunctions},
                                         visible::fmi2Boolean,
                                         loggingOn::fmi2Boolean)
    
    @assert false "The function `fmi2Instantiate` is not callable anymore, because the FMU is unloaded!"
    return C_NULL
end

function unload_fmi2FreeInstance(_component::fmi2Component)
    @assert false "The function `fmi2FreeInstance` is not callable anymore, because the FMU is unloaded!"
    return nothing
end

function unload_fmi2SetDebugLogging(_component::fmi2Component, loggingOn::fmi2Boolean, nCategories::Csize_t, categories::Ptr{fmi2String})
    @assert false "The function `fmi2SetDebugLogging` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetupExperiment(_component::fmi2Component, toleranceDefined::fmi2Boolean, tolerance::fmi2Real, startTime::fmi2Real, stopTimeDefined::fmi2Boolean, stopTime::fmi2Real)
    @assert false "The function `fmi2SetupExperiment` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2EnterInitializationMode(_component::fmi2Component)
    @assert false "The function `fmi2EnterInitializationMode` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2ExitInitializationMode(_component::fmi2Component)
    @assert false "The function `fmi2ExitInitializationMod` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2Terminate(_component::fmi2Component)
    @assert false "The function `fmi2Terminate` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2Reset(_component::fmi2Component)
    @assert false "The function `fmi2Reset` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetReal(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Real})
    @assert false "The function `fmi2GetReal` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetInteger(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Integer})
    @assert false "The function `fmi2GetInteger` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetBoolean(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Boolean})
    @assert false "The function `fmi2GetBoolean` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetString(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2String})
    @assert false "The function `fmi2GetString` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetReal(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Real})
    @assert false "The function `fmi2SetReal` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetInteger(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Integer})
    @assert false "The function `fmi2SetInteger` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetBoolean(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2Boolean})
    @assert false "The function `fmi2SetBoolean` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetString(_component::fmi2Component, _vr::Ptr{fmi2ValueReference}, nvr::Csize_t, _value::Ptr{fmi2String})
    @assert false "The function `fmi2SetString` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetTime(_component::fmi2Component, time::fmi2Real)
    @assert false "The function `fmi2SetTime` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2SetContinuousStates(_component::fmi2Component, _x::Ptr{fmi2Real}, nx::Csize_t)
    @assert false "The function `fmi2SetContinuousStates` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2EnterEventMode(_component::fmi2Component)
    @assert false "The function `fmi2EnterEventMode` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2NewDiscreteStates(_component::fmi2Component, _fmi2eventInfo::Ptr{fmi2EventInfo})
    @assert false "The function `fmi2NewDiscreteStates` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2EnterContinuousTimeMode(_component::fmi2Component)
    @assert false "The function `fmi2EnterContinuousTimeMode` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2CompletedIntegratorStep(_component::fmi2Component, noSetFMUStatePriorToCurrentPoint::fmi2Boolean, enterEventMode::Ptr{fmi2Boolean}, terminateSimulation::Ptr{fmi2Boolean})
    @assert false "The function `fmi2CompletedIntegratorStep` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetDerivatives(_component::fmi2Component, _derivatives::Ptr{fmi2Real}, nx::Csize_t)
    @assert false "The function `fmi2GetDerivatives` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetEventIndicators(_component::fmi2Component, _eventIndicators::Ptr{fmi2Real}, ni::Csize_t)
    @assert false "The function `fmi2GetEventIndicators` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetContinuousStates(_component::fmi2Component, _x::Ptr{fmi2Real}, nx::Csize_t)
    @assert false "The function `fmi2GetContinuousStates` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

function unload_fmi2GetNominalsOfContinuousStates(_component::fmi2Component, _x_nominal::Ptr{fmi2Real}, nx::Csize_t)
    @assert false "The function `fmi2GetNominalsOfContinuousStates` is not callable anymore, because the FMU is unloaded!"
    return fmi2StatusFatal
end

# ToDo: Add CS functions!