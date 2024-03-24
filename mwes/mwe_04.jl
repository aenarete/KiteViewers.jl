using GLMakie

const running    = Observable(false)
fig = Figure(size=(400, 400), backgroundcolor=RGBf(0.7, 0.8, 1))
sub_fig = fig[1,1]
fig[2, 1] = buttongrid = GridLayout(tellwidth=true)
btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
btn_STOP = Button(sub_fig, label="STOP")
buttongrid[1, 1:2] = [btn_PLAY_PAUSE, btn_STOP]

menu1 = Menu(fig, bbox = fig.scene.viewport, options = ["plot", "save as jld2", "save as pdf"], default = "plot")
menu1.width[]=100
menu1.halign[]=:left
menu1.valign[]=:top
menu1.alignmode[]=Outside(10)
fig