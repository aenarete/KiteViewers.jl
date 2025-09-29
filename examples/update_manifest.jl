# This script updates the Manifest.toml file for the current Julia version.
# It copies the Manifest.toml from the TestEnv environment to the current directory,
# renaming it according to the Julia version (e.g., Manifest-v1.10.toml).
# Usage: ./bin/install

using TestEnv; pr=TestEnv.activate()
using KiteViewers, KiteModels
src = joinpath(dirname(pr), "Manifest.toml")
if VERSION.minor==10
    dest = joinpath(pwd(), "Manifest-v1.10.toml")
elseif VERSION.minor==11
    dest = joinpath(pwd(), "Manifest-v1.11.toml")
elseif VERSION.minor==12
    dest = joinpath(pwd(), "Manifest-v1.12.toml")
else
    error("This script only supports Julia 1.10, 1.11, and 1.12")
end
cp(src, dest; force=true)
using Pkg
Pkg.activate(".")
Pkg.resolve()