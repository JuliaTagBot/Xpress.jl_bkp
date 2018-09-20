using Compat
using Compat.Libdl

depsfile = joinpath(dirname(@__FILE__),"deps.jl")

if isfile(depsfile)
    rm(depsfile)
end

function write_depsfile(path)
    f = open(depsfile,"w")
    if Compat.Sys.iswindows()
        path = replace(path, "\\" => "\\\\")
    end
    println(f,"const xprs = \"$(path)\"")
    close(f)
end


libname = string(Compat.Sys.iswindows() ? "" : "lib", "xprs", ".", Libdl.dlext)
paths_to_try = String[]

push!(paths_to_try, libname)

if haskey(ENV, "XPRESSDIR")
  push!(paths_to_try, joinpath(ENV["XPRESSDIR"], Compat.Sys.iswindows() ? "bin" : "lib", libname))
end

found = false
for l in paths_to_try
    d = Libdl.dlopen_e(l)
    if d != C_NULL
        found = true
        Compat.@info("found $l")
        write_depsfile(l)
        break
    end
end

if !found
    error("Unable to locate Xpress installation, please check your enviroment variable XPRESSDIR . Note that Xpress must be obtained separately from fico.com")
end
