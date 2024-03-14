module KiteViewers

using GeometryBasics, Rotations, GLMakie, FileIO, LinearAlgebra, Printf, Parameters, Reexport
import GeometryBasics:Point3f, GeometryBasics.Point2f
using KiteUtils

export Viewer3D, AbstractKiteViewer, AKV                        # types
export clear_viewer, update_system, save_png, stop, set_status  # functions
@reexport using GLMakie: on

const KITE_SPRINGS = 8 

if ! isdir(get_data_path())
    datapath = joinpath(dirname(dirname(pathof(KiteViewers))), "data")
    KiteUtils.set_data_path(datapath)
end

include("viewer3D2.jl")
# include("common.jl")

@with_kw mutable struct KiteLogger
    states::Vector{SysState{7}} = SysState{7}[]
end

end
