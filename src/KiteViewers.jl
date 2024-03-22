module KiteViewers

using PrecompileTools: @setup_workload, @compile_workload 
using GeometryBasics, Rotations, GLMakie, FileIO, LinearAlgebra, Printf, Parameters, Reexport
import GeometryBasics:Point3f, GeometryBasics.Point2f
using KiteUtils

export Viewer3D, AbstractKiteViewer, AKV                        # types
export clear_viewer, update_system, save_png, stop, set_status  # functions
@reexport using GLMakie: on

const KITE_SPRINGS = 8 

function __init__()
    if isdir(joinpath(pwd(), "data")) && isfile(joinpath(pwd(), "data", "system.yaml"))
        set_data_path(joinpath(pwd(), "data"))
    end
end

include("viewer3D.jl")

@setup_workload begin
	@compile_workload begin
		viewer=Viewer3D()
        close(viewer.screen)
        nothing
	end
end

end
