using GLMakie

const running    = Observable(false)
fig = Figure(size=(200, 200), backgroundcolor=RGBf(0.7, 0.8, 1))
sub_fig = fig[1,1]
fig[2, 1] = buttongrid = GridLayout(tellwidth=false)
btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
buttongrid[1, 1:1] = [btn_PLAY_PAUSE]
fig
textnode2  = Observable("") 
TEXT_SIZE = 16
font="/usr/share/fonts/truetype/ttf-bitstream-vera/VeraMono.ttf"
txt=text!(fig.scene, textnode2, position  = Point2f(100, 100), fontsize=TEXT_SIZE, font=font, align = (:left, :bottom), show_axis = false, space=:pixel)
textnode2[]="depower\nsteering:"

last = nothing
on(fig.scene.events.window_area) do x
    global last
    last = x
    println("New value of fig.scene.events.window_area is $x")
    println(x.widths[1])
end
fig