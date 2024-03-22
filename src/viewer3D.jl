#= MIT License

Copyright (c) 2020, 2021 Uwe Fechner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. =#

@consts begin
    SCALE = 1.2 
    INITIAL_HEIGHT =  80.0*se().zoom # meter, for demo
    MAX_HEIGHT     = 200.0*se().zoom # meter, for demo
    KITE = FileIO.load(joinpath(dirname(get_data_path()), se().model))
    FLYING     = [false]
    PLAYING    = [false]
    GUI_ACTIVE = [false]
    AXIS_LABEL_SIZE = 30
    TEXT_SIZE = 16
    running   = Observable(false)
    starting  = [0]
    zoom      = [1.0]
    steering  = [0.0]
    textnode  = Observable("")  # lower left
    textnode2  = Observable("") # upper right
    fontsize  = Observable(TEXT_SIZE)
    fontsize2 = Observable(AXIS_LABEL_SIZE)
    status = Observable("")
    p1 = Observable(Vector{Point2f}(undef, 6000)) # 5 min
    p2 = Observable(Vector{Point2f}(undef, 6000)) # 5 min
    pos_x = Observable(0.0f0)

    points          = Vector{Point3f}(undef, se().segments+1+4)
    quat            = Observable(Quaternionf(0,0,0,1))                                     # orientation of the kite
    kite_pos        = Observable(Point3f(1,0,0))                                           # position of the kite
    positions       = Observable([Point3f(x,0,0) for x in 1:se().segments+KITE_SPRINGS])   # positions of the tether segments
    part_positions  = Observable([Point3f(x,0,0) for x in 1:se().segments+1+4])            # positions of the tether particles
    markersizes     = Observable([Point3f(1,1,1) for x in 1:se().segments+KITE_SPRINGS])   # includes the segment length
    rotations       = Observable([Point3f(1,0,0) for x in 1:se().segments+KITE_SPRINGS])   # unit vectors corresponding with
                                                                                           #   the orientation of the segments 
end 

"""
    abstract type AbstractKiteViewer

All kite viewers must inherit from this type. All methods that are defined on this type must work
with all kite viewers. All exported methods must work on this type. 
"""
abstract type AbstractKiteViewer end

"""
    const AKV = AbstractKiteViewer

Short alias for the AbstractKiteViewer. 
"""
const AKV = AbstractKiteViewer

mutable struct Viewer3D <: AKV
    fig::Figure
    scene3D::LScene
    screen::GLMakie.Screen
    btn_PLAY::Button
    btn_AUTO::Button
end

function clear_viewer(kv::AKV)
    kv.stop = false
    kv.step = 1
    kv.energy = 0
    status[] = "Running..."
end

function stop(kv::AKV)
    kv.stop = true
    status[]="Stopped"
end

function set_status(kv::AKV, status_text)
    status[] = status_text
end

function Viewer3D(show_kite=true, autolabel="Autopilot") 
    fig = Figure(size=(840, 900), backgroundcolor=RGBf(0.7, 0.8, 1))
    sub_fig = fig[1,1]
    scene2D = LScene(fig[3,1], show_axis=false, height=16)
    scene3D = LScene(sub_fig, show_axis=false, scenekw=(limits=Rect(-7,-10.0,0, 11,10,11), size=(800, 800)))

    fontsize[]  = TEXT_SIZE
    fontsize2[] = AXIS_LABEL_SIZE
 
    fig[2, 1] = buttongrid = GridLayout(tellwidth=false)
    l_sublayout = GridLayout()
    fig[1:3, 1] = l_sublayout
    l_sublayout[:v] = [scene3D, buttongrid, scene2D]

    btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
    btn_AUTO        = Button(sub_fig, label = autolabel)
    
    buttongrid[1, 1:2] = [btn_PLAY_PAUSE, btn_AUTO]
    gl_screen = display(fig)

    s = Viewer3D(fig, scene3D, gl_screen, btn_PLAY_PAUSE, btn_AUTO)

    s
end

function save_png(viewer; filename="video", index = 1)
    buffer = IOBuffer()
    @printf(buffer, "%06i", index) 
    save(filename * String(take!(buffer)) * ".png", viewer.scene)
end
