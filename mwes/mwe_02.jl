using GLMakie

const running    = Observable(false)
fig = Figure(size=(840, 900), backgroundcolor=RGBf(0.7, 0.8, 1))
sub_fig = fig[1,1]
fig[2, 1] = buttongrid = GridLayout(tellwidth=false)
btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
buttongrid[1, 1:1] = [btn_PLAY_PAUSE]
fig