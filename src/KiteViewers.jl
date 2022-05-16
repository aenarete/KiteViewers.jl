module KiteViewers

using GeometryBasics, Rotations, GLMakie, FileIO, LinearAlgebra, Printf, Parameters
import GeometryBasics:Point3f
using KiteUtils

export Viewer3D, AKV                   # types
export clear, update_system, save_png  # functions

const KITE_SPRINGS = 8 

datapath = joinpath(dirname(dirname(pathof(KiteViewers))), "data")
KiteUtils.set_data_path(datapath)

include("viewer3D.jl")
include("common.jl")

end
