#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

const ERR_MSG_CONT_TIME_MODE = "Function must be called in mode continuous time!\nThis is most probably because the FMU errored before. If no messages are printed, check that the FMU message prinintg is enabled (this is tool dependent and must be selected during export) and follow the message printing instructions under https://thummeto.github.io/FMI.jl/dev/features/#Debugging-/-Logging"