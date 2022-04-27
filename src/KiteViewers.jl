module KiteViewers

using GeometryBasics, Rotations, GLMakie, FileIO, LinearAlgebra, Printf, Parameters
import GeometryBasics:Point3f
using KiteUtils

export Viewer3D                      # types
export update_points, update_system  # functions

const KITE_SPRINGS = 8 

datapath = joinpath(dirname(dirname(pathof(KiteViewers))), "data")
KiteUtils.set_data_path(datapath)

include("viewer3D.jl")
include("common.jl")

end
