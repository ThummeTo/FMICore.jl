#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMICore

# fmi2Real/fmi3Float64 is always a C `double` per the FMI spec (fmi2TypesPlatform.h),
# regardless of the host Julia's pointer width -- 32-bit only affects pointer size, not `double`.
Creal = Cdouble

# abstract types for inheritance 
abstract type fmiModelDescription end
export fmiModelDescription

const SI_UNITS = (:kg, :m, :s, :A, :K, :mol, :cd, :rad)

include("FMI2/cconst.jl")
include("FMI3/cconst.jl")

include("FMI2/ctype.jl")
include("FMI3/ctype.jl")

include("FMI2/cfunc.jl")
include("FMI3/cfunc.jl")

include("FMI2/cfunc_unload.jl")
# ToDo: include("FMI3/cfunc_unload.jl")

end # module
