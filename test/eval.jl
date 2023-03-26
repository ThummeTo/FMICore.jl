using PkgEval
using FMICore

config = Configuration(; julia="1.8");

package = Package(; name="FMICore");

@info "PkgEval"
result = evaluate([config], [package])

@info "Result"
println(result)

@info "Log"
println(result["log"])