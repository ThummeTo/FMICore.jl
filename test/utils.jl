#
# Copyright (c) 2021 Tobias Thummerer, Lars Mikelsons, Josef Kircher
# Licensed under the MIT license. See LICENSE file in the project root for details.
#

# Shared helpers for the FMI 2 and FMI 3 tests: the tests run against the (pinned) Modelica Reference FMUs.

using Downloads, ZipFile, Libdl

const REFERENCE_FMUS_VERSION = "0.0.41"
const REFERENCE_FMUS_URL = "https://github.com/modelica/Reference-FMUs/releases/download/v$(REFERENCE_FMUS_VERSION)/Reference-FMUs.zip"
const REFERENCE_FMUS_ZIP = Ref("")

# downloads the Reference FMUs release (once per test run)
function referenceFMUsZip()
    if !isfile(REFERENCE_FMUS_ZIP[])
        REFERENCE_FMUS_ZIP[] = Downloads.download(REFERENCE_FMUS_URL)
    end
    return REFERENCE_FMUS_ZIP[]
end

function unzip(reader::ZipFile.Reader, target::String)
    for f in reader.files
        path = normpath(joinpath(target, f.name))
        if endswith(f.name, "/") || endswith(f.name, "\\")
            mkpath(path)
        else
            mkpath(dirname(path))
            write(path, read(f))
        end
    end
    close(reader)
    return target
end

# extracts the Reference FMU `fmiVersion/name.fmu` and returns the path of the unzipped FMU
function referenceFMU(fmiVersion::String, name::String)
    archive = ZipFile.Reader(referenceFMUsZip())
    index = findfirst(f -> f.name == "$(fmiVersion)/$(name).fmu", archive.files)
    @assert !isnothing(index) "Reference FMU `$(fmiVersion)/$(name).fmu` not found."
    data = read(archive.files[index])
    close(archive)

    return unzip(ZipFile.Reader(IOBuffer(data)), mktempdir(; prefix = "fmicore_"))
end

# platform folder of the FMU binaries for this Julia, `nothing` if there are no Reference FMU binaries
function binaryPlatform(fmiVersion::String)
    if fmiVersion == "2.0"
        if Sys.ARCH == :x86_64
            Sys.iswindows() && return "win64"
            Sys.islinux() && return "linux64"
            Sys.isapple() && return "darwin64"
        elseif Sys.ARCH == :i686 && Sys.iswindows()
            return "win32"
        end
    elseif fmiVersion == "3.0"
        arch = Dict(:x86_64 => "x86_64", :i686 => "x86", :aarch64 => "aarch64")
        if haskey(arch, Sys.ARCH)
            Sys.iswindows() && return "$(arch[Sys.ARCH])-windows"
            Sys.islinux() && return "$(arch[Sys.ARCH])-linux"
            Sys.isapple() && return "$(arch[Sys.ARCH])-darwin"
        end
    end
    return nothing
end

# returns the unzipped FMU path and the binary path, the binary path is `nothing` if not available for this platform
function referenceFMUBinary(fmiVersion::String, name::String)
    path = referenceFMU(fmiVersion, name)
    platform = binaryPlatform(fmiVersion)
    if isnothing(platform)
        return path, nothing
    end

    binary = joinpath(path, "binaries", platform, name * "." * Libdl.dlext)
    return path, (isfile(binary) ? binary : nothing)
end

# loads the binary of a Reference FMU, returns `(name, path, lib)` or `nothing` if not available for this platform
function loadReferenceFMU(fmiVersion::String, name::String)
    path, binary = referenceFMUBinary(fmiVersion, name)
    if isnothing(binary)
        return nothing
    end
    return (name = name, path = path, lib = dlopen(binary))
end

# URI of the resources folder of an unzipped FMU
resourceURI(path::String) =
    "file:///" * replace(joinpath(path, "resources"), "\\" => "/") * "/"

# GUID (FMI 2) or instantiation token (FMI 3) from the model description of an unzipped FMU
function instantiationToken(path::String)
    md = read(joinpath(path, "modelDescription.xml"), String)
    # [Note] `String`, because the pointer of a `SubString` is not null-terminated
    return String(match(r"(?:guid|instantiationToken)=\"([^\"]*)\"", md).captures[1])
end

# unloads the binary and removes the unzipped FMU (on Windows, loaded binaries can't be removed at exit)
function unloadReferenceFMU(fmu)
    dlclose(fmu.lib)
    rm(fmu.path; recursive = true, force = true)
    return nothing
end
