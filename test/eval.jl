#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

using PkgEval
using FMICore

config = Configuration(; julia = "1.10");

package = Package(; name = "FMICore");

@info "PkgEval"
result = evaluate([config], [package])

@info "Result"
println(result)

@info "Log"
println(result.log)
