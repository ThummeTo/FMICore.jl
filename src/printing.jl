#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

"""
Log levels for non-standard printing of infos, warnings and errors.
"""
const FMULogLevel = Cuint
const FMULogLevelNone  = Cuint(0)
const FMULogLevelInfo  = Cuint(1)
const FMULogLevelWarn  = Cuint(2)
const FMULogLevelError = Cuint(3)
export FMULogLevel, FMULogLevelNone, FMULogLevelInfo, FMULogLevelWarn, FMULogLevelError 

"""
Prints a message with level `info` if the log level allows it.
"""
function logInfo(fmu::FMU, message, maxlog=0)
    if fmu.logLevel <= FMULogLevelInfo
        @info message maxlog=maxlog
    end
end
export logInfo

"""
Prints a message with level `warn` if the log level allows it.
"""
function logWarning(fmu::FMU, message, maxlog=0)
    if fmu.logLevel <= FMULogLevelWarn
        @warn message maxlog=maxlog
    end
end
export logWarning

"""
Prints a message with level `error` if the log level allows it.
"""
function logError(fmu::FMU, message, maxlog=0)
    if fmu.logLevel <= FMULogLevelError
        @error message maxlog=maxlog
    end
end
export logError

