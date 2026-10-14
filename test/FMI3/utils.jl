#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# The FMI 3 logger is not variadic, so it is implemented in Julia.
const LOG_MESSAGES = String[]

function logMessage(
    instanceEnvironment::fmi3InstanceEnvironment,
    status::fmi3Status,
    category::fmi3String,
    message::fmi3String,
)::Cvoid
    push!(LOG_MESSAGES, "[$(status)] $(unsafe_string(category)): $(unsafe_string(message))")
    return nothing
end

# FMI 3 expects the native path of the resources folder (with trailing separator), not an URI
resourcePath(path::String) = joinpath(path, "resources") * (Sys.iswindows() ? "\\" : "/")

function instantiate(fmu, type::fmi3Type; loggingOn::Bool = false)
    instanceName = "test_$(fmu.name)"
    token = instantiationToken(fmu.path)
    resources = resourcePath(fmu.path)
    logger = @cfunction(
        logMessage,
        Cvoid,
        (fmi3InstanceEnvironment, fmi3Status, fmi3String, fmi3String)
    )

    GC.@preserve instanceName token resources begin
        if type == fmi3TypeModelExchange
            return fmi3InstantiateModelExchange(
                dlsym(fmu.lib, :fmi3InstantiateModelExchange),
                pointer(instanceName),
                pointer(token),
                pointer(resources),
                fmi3False,
                fmi3Boolean(loggingOn),
                C_NULL,
                logger,
            )
        else
            return fmi3InstantiateCoSimulation(
                dlsym(fmu.lib, :fmi3InstantiateCoSimulation),
                pointer(instanceName),
                pointer(token),
                pointer(resources),
                fmi3False,
                fmi3Boolean(loggingOn),
                fmi3False, # eventModeUsed
                fmi3False, # earlyReturnAllowed
                fmi3ValueReference[],
                Csize_t(0),
                C_NULL,
                logger,
                C_NULL,
            )
        end
    end
end
