#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

function logInfo(component::FMU2Component, message, status::fmi2Status=fmi2StatusOK)
    if component.loggingOn == fmi2True
        ccall(component.callbackFunctions.logger, 
              Cvoid, 
              (fmi2ComponentEnvironment,                        fmi2String,             fmi2Status, fmi2String, fmi2String), 
              component.callbackFunctions.componentEnvironment, component.instanceName, status,     "info",     message * "\n")
    end
end
function logInfo(::Nothing, message, status::fmi2Status=fmi2StatusOK)
    @info "logInfo(nothing, $(message), $(status))"
end

function logWarning(component::FMU2Component, message, status::fmi2Status=fmi2StatusWarning)
    if component.loggingOn == fmi2True
        ccall(component.callbackFunctions.logger, 
              Cvoid, 
              (fmi2ComponentEnvironment,                        fmi2String,             fmi2Status, fmi2String, fmi2String), 
              component.callbackFunctions.componentEnvironment, component.instanceName, status,     "warning",  message * "\n")
    end
end
function logWarning(::Nothing, message, status::fmi2Status=fmi2StatusOK)
    @warn "logWarning(nothing, $(message), $(status))"
end

function logError(component::FMU2Component, message, status::fmi2Status=fmi2StatusError)
    if component.loggingOn == fmi2True
        ccall(component.callbackFunctions.logger, 
              Cvoid, 
              (fmi2ComponentEnvironment,                        fmi2String,             fmi2Status, fmi2String, fmi2String), 
              component.callbackFunctions.componentEnvironment, component.instanceName, status,     "error",    message * "\n")
    end
end
function logError(::Nothing, message, status::fmi2Status=fmi2StatusOK)
    @error "logError(nothing, $(message), $(status))"
end