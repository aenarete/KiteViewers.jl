module KiteViewers

using PrecompileTools: @setup_workload, @compile_workload 
using GLMakie

export Viewer3D

const    running   = Observable(false)

mutable struct Viewer3D
    fig::Figure
    screen::GLMakie.Screen
    btn_PLAY::Button
    btn_AUTO::Button
end

function Viewer3D() 
    fig = Figure(size=(200, 200), backgroundcolor=RGBf(0.7, 0.8, 1))
    sub_fig = fig[1,1]
 
    fig[2, 1] = buttongrid = GridLayout(tellwidth=false)
    l_sublayout = GridLayout()
    fig[1:3, 1] = l_sublayout
    l_sublayout[:v] = [buttongrid]

    btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
    btn_AUTO        = Button(sub_fig, label = "Autolabel")
    
    buttongrid[1, 1:2] = [btn_PLAY_PAUSE, btn_AUTO]
    gl_screen = display(fig)

    Viewer3D(fig, gl_screen, btn_PLAY_PAUSE, btn_AUTO)
end

@setup_workload begin
	@compile_workload begin
		viewer=Viewer3D()
        close(viewer.screen)
        nothing
	end
end

end
