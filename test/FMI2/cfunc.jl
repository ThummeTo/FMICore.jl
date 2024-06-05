#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# [ToDo] tests for FMI2
using Libdl

include("utils.jl")

function test_status_ok(status)
    @test typeof(status) == fmi2Status
    @test status == fmi2StatusOK
end

binarypath, fmu_path = get_os_binaries()
@test binarypath != ""
if binarypath != ""
    lib = dlopen(binarypath)

    ## fmi2GetTypesPlatform
    cGetTypesPlatform = dlsym(lib, :fmi2GetTypesPlatform)
    test = fmi2GetTypesPlatform(cGetTypesPlatform)
    @test unsafe_string(test) == "default"
    
    ## fmi2GetVersion TODO get Version from modelDescription.xml
    vers = fmi2GetVersion(dlsym(lib, :fmi2GetVersion))
    @test unsafe_string(vers) == "2.0"

    ## fmi2Instantiate
    cInstantiate = dlsym(lib, :fmi2Instantiate)
    compAddr = fmi2Instantiate(cInstantiate, instantiate_args(fmu_path)...)
    @test compAddr != Ptr{Cvoid}(C_NULL)
    component = fmi2Component(compAddr)

    test_status_ok(fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2False, Unsigned(0), AbstractArray{fmi2String}([])))
    test_status_ok(fmi2SetDebugLogging(dlsym(lib, :fmi2SetDebugLogging), component, fmi2True, Unsigned(0), AbstractArray{fmi2String}([])))

    ## fmi2SetupExperiment

    test_status_ok(fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(0.0)))



    # get and Set State
    state = fmi2FMUstate()
    stateRef = Ref(state)

    test_status_ok(fmi2GetFMUstate!(dlsym(lib, :fmi2GetFMUstate), component, stateRef))
    state = stateRef[]

    @test typeof(state) == fmi2FMUstate
    
    test_status_ok(fmi2SetFMUstate(dlsym(lib, :fmi2SetFMUstate), component, state))

    # Initialization Mode

    
    test_status_ok(fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component))

    test_status_ok(fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component))

    test_status_ok(fmi2Reset(dlsym(lib, :fmi2Reset), component))

    

    # # @test fmi2DoStep(component, 0.1) == 0

    # Nach dem Standard sollte das hier nötig sein, ist es aber mit unserer FMU nicht
    fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)

    test_status_ok(fmi2Terminate(dlsym(lib, :fmi2Terminate), component))

    ## fmi2FreeInstance
    @test isnothing(fmi2FreeInstance(dlsym(lib, :fmi2FreeInstance), component))


end




# Callback Functions werden in FMIImport.jl/c.jl definiert

# Download
# Unzip
# OS-Distinction
    # Dynamic Linking
# Tests
