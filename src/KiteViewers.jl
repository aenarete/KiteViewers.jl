module KiteViewers

using PrecompileTools: @setup_workload, @compile_workload 
using GLMakie

export Viewer3D

const    running   = Observable(false)

function Viewer3D() 
    fig = Figure(size=(200, 200))
    sub_fig = fig[1,1]
    fig[2, 1] = buttongrid = GridLayout()

    # btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
    btn_PLAY_PAUSE  = Button(sub_fig, label = "RUN")
    btn_AUTO        = Button(sub_fig)
    
    buttongrid[1, 1:2] = [btn_PLAY_PAUSE, btn_AUTO]
    display(fig)
end

@setup_workload begin
	@compile_workload begin
		screen=Viewer3D()
        close(screen)
        nothing
	end
end

end
