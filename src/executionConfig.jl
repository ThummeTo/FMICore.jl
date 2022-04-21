#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
A mutable struct representing the excution configuration of a FMU.
For FMUs that have issues with calls like `fmi2Reset` or `fmi2FreeInstance`, this is pretty useful.
"""
mutable struct FMUExecutionConfiguration 
    terminate::Bool     # call fmi2Terminate before every training step / simulation
    reset::Bool         # call fmi2Reset before every training step / simulation
    setup::Bool         # call setup functions before every training step / simulation
    instantiate::Bool   # call fmi2Instantiate before every training step / simulation
    freeInstance::Bool  # call fmi2FreeInstance after every training step / simulation

    loggingOn::Bool     # enable FMU logging

    handleStateEvents::Bool                 # handle state events during simulation/training
    handleTimeEvents::Bool                  # handle time events during simulation/training

    assertOnError::Bool                     # wheter an exception is thrown if a fmi2XXX-command fails (>= fmi2StatusError)
    assertOnWarning::Bool                   # wheter an exception is thrown if a fmi2XXX-command warns (>= fmi2StatusWarning)

    autoTimeShift::Bool                     # wheter to shift all time-related functions for simulation intervals not starting at 0.0

    sensealg                                # algorithm for sensitivity estimation over solve call
    useComponentShadow::Bool                # whether FMU outputs/derivatives/jacobians should be cached for frule/rrule (useful for ForwardDiff)
    rootSearchInterpolationPoints::UInt     # number of root search interpolation points
    inPlace::Bool                           # whether faster in-place-fx should be used
    useVectorCallbacks::Bool                # whether to vector (faster) or scalar (slower) callbacks

    maxNewDiscreteStateCalls::UInt          # max calls for fmi2NewDiscreteStates before throwing an exception

    function FMUExecutionConfiguration()
        inst = new()

        inst.terminate = true 
        inst.reset = true
        inst.setup = true
        inst.instantiate = false 
        inst.freeInstance = false

        inst.loggingOn = false

        inst.handleStateEvents = true
        inst.handleTimeEvents = true

        inst.assertOnError = false
        inst.assertOnWarning = false

        inst.autoTimeShift = true

        inst.sensealg = nothing # auto
        inst.useComponentShadow = false
        inst.rootSearchInterpolationPoints = 100
        inst.inPlace = true
        inst.useVectorCallbacks = true

        inst.maxNewDiscreteStateCalls = 100

        return inst 
    end
end

FMU2ExecutionConfiguration = FMUExecutionConfiguration
FMU3ExecutionConfiguration = FMUExecutionConfiguration

# default for a "healthy" FMU - this is the fastetst 
FMU_EXECUTION_CONFIGURATION_RESET = FMUExecutionConfiguration()
FMU_EXECUTION_CONFIGURATION_RESET.terminate = true
FMU_EXECUTION_CONFIGURATION_RESET.reset = true
FMU_EXECUTION_CONFIGURATION_RESET.instantiate = false
FMU_EXECUTION_CONFIGURATION_RESET.freeInstance = false

# if your FMU has a problem with "fmi2Reset" - this is default
FMU_EXECUTION_CONFIGURATION_NO_RESET = FMUExecutionConfiguration() 
FMU_EXECUTION_CONFIGURATION_NO_RESET.terminate = false
FMU_EXECUTION_CONFIGURATION_NO_RESET.reset = false
FMU_EXECUTION_CONFIGURATION_NO_RESET.instantiate = true
FMU_EXECUTION_CONFIGURATION_NO_RESET.freeInstance = true

# if your FMU has a problem with "fmi2Reset" and "fmi2FreeInstance" - this is for weak FMUs (but slower)
FMU_EXECUTION_CONFIGURATION_NO_FREEING = FMUExecutionConfiguration() 
FMU_EXECUTION_CONFIGURATION_NO_FREEING.terminate = false
FMU_EXECUTION_CONFIGURATION_NO_FREEING.reset = false
FMU_EXECUTION_CONFIGURATION_NO_FREEING.instantiate = true
FMU_EXECUTION_CONFIGURATION_NO_FREEING.freeInstance = false