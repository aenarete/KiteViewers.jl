using TestEnv; pr=TestEnv.activate()
using KiteViewers, KiteModels
src = joinpath(dirname(pr), "Manifest.toml")
dest = joinpath(pwd(), "Manifest-v1.10.toml")
cp(src, dest; force=true)
using Pkg
Pkg.activate(".")
Pkg.resolve()