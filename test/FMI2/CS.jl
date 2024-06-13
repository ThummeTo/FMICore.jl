# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using Libdl

function test_CS(lib, cblibpath)
    component = fmi2Instantiate(dlsym(lib, :fmi2Instantiate), pointer("test_cs"), fmi2TypeCoSimulation, pointer("{3c564ab6-a92a-48ca-ae7d-591f819b1d93}"), pointer("file:///"), Ptr{fmi2CallbackFunctions}(pointer_from_objref(get_callbacks(cblibpath))), fmi2Boolean(false), fmi2Boolean(false))

    test_status_ok(fmi2SetupExperiment(dlsym(lib, :fmi2SetupExperiment),component, fmi2Boolean(false), fmi2Real(0.0), fmi2Real(0.0), fmi2Boolean(false), fmi2Real(1.0)))

    
    fmi2EnterInitializationMode(dlsym(lib, :fmi2EnterInitializationMode), component)
    fmi2ExitInitializationMode(dlsym(lib, :fmi2ExitInitializationMode), component)
    test_status_ok(fmi2DoStep(dlsym(lib, :fmi2DoStep), component, fmi2Real(0.0), fmi2Real(0.1), fmi2False))

    status = fmi2Status(fmi2StatusOK)
    statusptr = pointer([status])
    # Async is not supported in this FMU, so the status should be fmi2StatusDiscard
    test_status_discard(fmi2GetStatus!(dlsym(lib, :fmi2GetStatus), component, fmi2StatusKindDoStepStatus, Ptr{fmi2Status}(statusptr)))
    
    
    status = fmi2Real(0.0)
    statusptr = pointer([status])
    test_status_ok(fmi2GetRealStatus!(dlsym(lib, :fmi2GetRealStatus), component, fmi2StatusKindLastSuccessfulTime, Ptr{fmi2Real}(statusptr)))
    
    status = fmi2Integer(0)
    statusptr = pointer([status])
    # Async is not supported in this FMU, so the status should be fmi2StatusDiscard
    test_status_discard(fmi2GetIntegerStatus!(dlsym(lib, :fmi2GetIntegerStatus), component, Cuint(2), Ptr{fmi2Integer}(statusptr)))
    
    status = fmi2Boolean(false)
    statusptr = pointer([status])
    # Async is not supported in this FMU, so the status should be fmi2StatusDiscard
    test_status_discard(fmi2GetBooleanStatus!(dlsym(lib, :fmi2GetBooleanStatus), component, Cuint(2), Ptr{fmi2Boolean}(statusptr)))

    status = "test"
    statusptr = pointer(status)
    # Async is not supported in this FMU, so the status should be fmi2StatusDiscard
    test_status_discard(fmi2GetStringStatus!(dlsym(lib, :fmi2GetStringStatus), component, Cuint(2), Ptr{fmi2String}(statusptr)))


    fmireference = [fmi2ValueReference(16777220)]
    status = fmi2SetRealInputDerivatives(dlsym(lib, :fmi2SetRealInputDerivatives), component, fmireference, Csize_t(1), [fmi2Integer(1)],  fmi2Real.([1.0]))
    # this should warn because the FMU does not have any inputs
    @test status == fmi2StatusWarning
    @test typeof(status) == fmi2Status

    fmireference = [fmi2ValueReference(16777220)]
    values = zeros(fmi2Real, 1)
    status = fmi2GetRealOutputDerivatives!(dlsym(lib, :fmi2GetRealOutputDerivatives), component, fmireference, Csize_t(1), [fmi2Integer(1)], values)
    # this should warn because the FMU does not have any outputs
    @test status == fmi2StatusWarning
    @test typeof(status) == fmi2Status


    fmi2Terminate(dlsym(lib, :fmi2Terminate), component)

end
