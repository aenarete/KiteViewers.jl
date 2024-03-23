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

last_status::String=""

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
    cam::Camera3D
    screen::GLMakie.Screen
    btn_RESET::Button
    btn_ZOOM_in::Button
    btn_ZOOM_out::Button
    btn_PLAY::Button
    btn_AUTO::Button
    btn_PARKING::Button
    btn_STOP::Button
    sw::Toggle
    step::Int64
    energy::Float64
    show_kite::Bool
    stop::Bool
end

function clear_viewer(kv::AKV)
    kv.step = 1
    kv.energy = 0
    stop(kv)
end

function stop(kv::AKV)
    kv.stop = true
    status[]="Stopped"
    running[]=false
end

function pause(kv::AKV)
    global last_status
    kv.stop = true
    last_status=status[]
    status[]="Paused"
end

function set_status(kv::AKV, status_text)
    global last_status
    if status_text != "Paused"
        last_status = status[]
    end
    status[] = status_text
end

function Viewer3D(show_kite=true, autolabel="Autopilot"; precompile=false) 
    global last_status
    fig = Figure(size=(840, 900), backgroundcolor=RGBf(0.7, 0.8, 1))
    sub_fig = fig[1,1]
    scene2D = LScene(fig[3,1], show_axis=false, height=16)
    scene3D = LScene(sub_fig, show_axis=false, scenekw=(limits=Rect(-7,-10.0,0, 11,10,11), size=(800, 800)))

    create_coordinate_system(scene3D)
    cam = cameracontrols(scene3D.scene)

    FLYING[1] = false
    PLAYING[1] = false
    GUI_ACTIVE[1] = true

    reset_view(cam, scene3D)

    fontsize[]  = TEXT_SIZE
    fontsize2[] = AXIS_LABEL_SIZE
    text!(scene3D, "z", position = Point3f(0, 0, 14.6), fontsize = fontsize2, align = (:center, :center), show_axis = false)
    text!(scene3D, "x", position = Point3f(17, 0,0), fontsize = fontsize2, align = (:center, :center), show_axis = false)
    text!(scene3D, "y", position = Point3f( 0, 14.5, 0), fontsize = fontsize2, align = (:center, :center), show_axis = false)

    text!(scene2D, status, position = Point2f( 20, 0), fontsize = TEXT_SIZE, align = (:left, :bottom), show_axis = false, space=:pixel)
    textnode2[]="depower\nsteering:"

    fig[2, 1] = buttongrid = GridLayout(tellwidth=false)
    l_sublayout = GridLayout()
    fig[1:3, 1] = l_sublayout
    l_sublayout[:v] = [scene3D, buttongrid, scene2D]

    btn_RESET       = Button(sub_fig, label = "RESET")
    btn_ZOOM_in     = Button(sub_fig, label = "Zoom +")
    btn_ZOOM_out    = Button(sub_fig, label = "Zoom -")
    if precompile
        btn_PLAY_PAUSE  = Button(sub_fig, label = " RUN ")
    else
        btn_PLAY_PAUSE  = Button(sub_fig, label = @lift($running ? "PAUSE" : " RUN "))
    end
    btn_AUTO        = Button(sub_fig, label = autolabel)
    btn_PARKING     = Button(sub_fig, label = "Parking")  
    btn_STOP        = Button(sub_fig, label = "STOP")
    sw = Toggle(sub_fig, active = false)
    label = Label(sub_fig, "repeat")
    
    buttongrid[1, 1:9] = [btn_PLAY_PAUSE, btn_ZOOM_in, btn_ZOOM_out, btn_RESET, btn_AUTO, btn_PARKING, btn_STOP, sw, label]
    gl_screen = display(fig)

    FLYING[1] = false
    PLAYING[1] = false
    GUI_ACTIVE[1] = true

    reset_view(cam, scene3D)

    s = Viewer3D(fig, scene3D, cam, gl_screen, btn_RESET, btn_ZOOM_in, btn_ZOOM_out, btn_PLAY_PAUSE, btn_AUTO, btn_PARKING, btn_STOP, sw, 0, 0, show_kite, false)
    init_system(s.scene3D; show_kite=show_kite)

    camera = cameracontrols(s.scene3D.scene)
    reset_view(camera, s.scene3D)
    set_status(s, "Stopped")

    on(s.btn_RESET.clicks) do c
        reset_view(camera, s.scene3D)
        zoom[1] = 1.0
    end

    on(s.btn_ZOOM_in.clicks) do c    
        zoom[1] *= 1.2
        reset_and_zoom(camera, s.scene3D, zoom[1])
    end

    on(s.btn_ZOOM_out.clicks) do c
        zoom[1] /= 1.2
        reset_and_zoom(camera, s.scene3D, zoom[1])
    end
    on(s.btn_STOP.clicks) do c
        stop(s)
    end
    on(s.btn_PLAY.clicks) do c
        if running[]
            last_status=status[]
            status[]="Paused"
            running[]=false
        else
            set_status(s, last_status)
            running[]=true
        end
        s.stop = ! running[]
    end
    status[] = "Stopped"
    s
end

function save_png(viewer; filename="video", index = 1)
    buffer = IOBuffer()
    @printf(buffer, "%06i", index) 
    save(filename * String(take!(buffer)) * ".png", viewer.scene)
end
