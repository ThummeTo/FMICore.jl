#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMICore

# Check float size on system (32 or 64 bits)
juliaArch = Sys.WORD_SIZE
@assert (juliaArch == 64 || juliaArch == 32) "FMICore: Unknown Julia Architecture with $(juliaArch)-bit, must be 64- or 32-bit."
Creal = Cdouble
if juliaArch == 32
    Creal = Cfloat
end

# abstract types for inheritance 
abstract type fmiModelDescription end 
export fmiModelDescription

include("FMI2/cconst.jl")
include("FMI3/cconst.jl")

include("FMI2/ctype.jl")
include("FMI3/ctype.jl")

include("FMI2/cfunc.jl")
include("FMI3/cfunc.jl")

include("FMI2/cfunc_unload.jl")
# ToDo: include("FMI3/cfunc_unload.jl")

end # module
