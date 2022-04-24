module KiteViewers

using GeometryBasics, Rotations, GLMakie, FileIO, LinearAlgebra, Printf, Parameters
using KiteUtils

export Viewer3D                                                  # types
export update_points                                             # functions

datapath = joinpath(dirname(dirname(pathof(KiteViewers))), "data")
KiteUtils.set_data_path(datapath)

include("viewer3D.jl")
include("common.jl")

end
