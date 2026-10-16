#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# The FMI 2 logger is a variadic C function, so it is taken from the (pinned) callback library of FMIImport.jl.
const CALLBACK_LIBRARY_URL = "https://github.com/ThummeTo/FMIImport.jl/raw/v1.4.0/src/FMI2/callbackFunctions/binaries"

# downloads the callback library, `nothing` if not available for this platform
function getCallbackLibrary()
    platform = binaryPlatform("2.0")
    if isnothing(platform)
        return nothing
    end

    name = Sys.iswindows() ? "callbackFunctions.dll" : "libcallbackFunctions.$(Libdl.dlext)"
    return Downloads.download(
        "$(CALLBACK_LIBRARY_URL)/$(platform)/$(name)",
        joinpath(mktempdir(; prefix = "fmicore_"), name),
    )
end

mutable struct FMU2ComponentEnvironment
    logStatusOK::Bool
    logStatusWarning::Bool
    logStatusDiscard::Bool
    logStatusError::Bool
    logStatusFatal::Bool
    logStatusPending::Bool

    function FMU2ComponentEnvironment()
        return new(true, true, true, true, true, true)
    end
end

# [Note] FMUs may keep the pointers to the callback functions and the component environment,
#        so both must stay valid for the lifetime of the instances.
const COMPONENT_ENVIRONMENT = FMU2ComponentEnvironment()
const CALLBACK_FUNCTIONS = Ref{fmi2CallbackFunctions}()
const CALLBACK_LIBRARY = Ref(C_NULL)

function getCallbacks(cblibpath::String)
    CALLBACK_LIBRARY[] = dlopen(cblibpath)
    CALLBACK_FUNCTIONS[] = fmi2CallbackFunctions(
        dlsym(CALLBACK_LIBRARY[], :logger),
        C_NULL,
        C_NULL,
        C_NULL,
        pointer_from_objref(COMPONENT_ENVIRONMENT),
    )
    return Base.unsafe_convert(Ptr{fmi2CallbackFunctions}, CALLBACK_FUNCTIONS)
end

# unloads and removes the callback library (after all instances are freed)
function unloadCallbackLibrary(cblibpath::String)
    if CALLBACK_LIBRARY[] != C_NULL
        dlclose(CALLBACK_LIBRARY[])
        CALLBACK_LIBRARY[] = C_NULL
    end
    rm(dirname(cblibpath); recursive = true, force = true)
    return nothing
end

function instantiate(fmu, type::fmi2Type; loggingOn::Bool = false)
    instanceName = "test_$(fmu.name)"
    guid = instantiationToken(fmu.path)
    resources = resourceURI(fmu.path)

    return GC.@preserve instanceName guid resources fmi2Instantiate(
        dlsym(fmu.lib, :fmi2Instantiate),
        pointer(instanceName),
        type,
        pointer(guid),
        pointer(resources),
        fmu.callbacks,
        fmi2False,
        fmi2Boolean(loggingOn),
    )
end
