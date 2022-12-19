#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

module FMICore

# check float size (32 or 64 bits)
juliaArch = Sys.WORD_SIZE
@assert (juliaArch == 64 || juliaArch == 32) "FMICore: Unknown Julia Architecture with $(juliaArch)-bit, must be 64- or 32-bit."
Creal = Cdouble
if juliaArch == 32
    Creal = Cfloat
end

"""
The mutable struct representing an abstract (version unknown) FMU.
"""
abstract type FMU end
export FMU

"""
ToDo.
"""
abstract type FMUSolution end
export FMUSolution

"""
ToDo.
"""
abstract type FMUExecutionConfiguration end
export FMUExecutionConfiguration

"""
ToDo.
"""
abstract type FMUEvent end
export FMUEvent

include("logging.jl")
include("jacobian.jl")

include("FMI2/cconst.jl")
include("FMI2/ctype.jl")
include("FMI2/cfunc.jl")
include("FMI2/convert.jl")
include("FMI2/struct.jl")

include("FMI3/cconst.jl")
include("FMI3/ctype.jl")
include("FMI3/cfunc.jl")
include("FMI3/convert.jl")
include("FMI3/struct.jl")

end # module
