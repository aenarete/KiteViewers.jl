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
    KITE = FileIO.load(joinpath(dirname(datapath), se().model))
    FLYING     = [false]
    PLAYING    = [false]
    GUI_ACTIVE = [false]
    AXIS_LABEL_SIZE = 30
    TEXT_SIZE = 16
    running   = Node(false)
    starting  = [0]
    zoom      = [1.0]
    steering  = [0.0]
    textnode  = Node("")  # lower left
    textnode2  = Node("") # upper right
    textsize  = Node(TEXT_SIZE)
    textsize2 = Node(AXIS_LABEL_SIZE)
    status = Node("")
    p1 = Node(Vector{Point2f}(undef, 6000)) # 5 min
    p2 = Node(Vector{Point2f}(undef, 6000)) # 5 min
    pos_x = Node(0.0f0)

    points          = Vector{Point3f}(undef, se().segments+1+4)
    quat            = Node(Quaternionf0(0,0,0,1))                                     # orientation of the kite
    kite_pos        = Node(Point3f(1,0,0))                                           # position of the kite
    positions       = Node([Point3f(x,0,0) for x in 1:se().segments+KITE_SPRINGS])   # positions of the tether segments
    part_positions  = Node([Point3f(x,0,0) for x in 1:se().segments+1+4])            # positions of the tether particles
    markersizes     = Node([Point3f(1,1,1) for x in 1:se().segments+KITE_SPRINGS])   # includes the segment length
    rotations       = Node([Point3f(1,0,0) for x in 1:se().segments+KITE_SPRINGS])   # unit vectors corresponding with
                                                                                      #   the orientation of the segments 
    energy = [0.0]
end 

# struct that stores the state of the 3D viewer
mutable struct Viewer3D
    scene::Scene
    layout::GridLayout
    scene3D::LScene
    cam::Camera3D
    screen::GLMakie.Screen
    btn_RESET::Button
    btn_ZOOM_in::Button
    btn_ZOOM_out::Button
end

function Viewer3D(show_kite=true)
    KiteUtils.set_data_path(datapath)
    scene, layout = layoutscene(resolution = (840, 900), backgroundcolor = RGBf(0.7, 0.8, 1))
    scene3D = LScene(scene, scenekw = (show_axis=false, limits = Rect(-7,-10.0,0, 11,10,11), resolution = (800, 800)), raw=false)
    create_coordinate_system(scene3D)
    cam = cameracontrols(scene3D.scene)

    FLYING[1] = false
    PLAYING[1] = false
    GUI_ACTIVE[1] = true

    reset_view(cam, scene3D)

    textsize[]  = TEXT_SIZE
    textsize2[] = AXIS_LABEL_SIZE
    text!(scene3D, "z", position = Point3f(0, 0, 14.6), textsize = textsize2, align = (:center, :center), show_axis = false)
    text!(scene3D, "x", position = Point3f(17, 0,0), textsize = textsize2, align = (:center, :center), show_axis = false)
    text!(scene3D, "y", position = Point3f( 0, 14.5, 0), textsize = textsize2, align = (:center, :center), show_axis = false)

    text!(scene, status, position = Point2f( 20, 0), textsize = TEXT_SIZE, align = (:left, :bottom), show_axis = false)
    status[]="Stopped"

    layout[1, 1] = scene3D
    layout[2, 1] = buttongrid = GridLayout(tellwidth = false)

    l_sublayout = GridLayout()
    layout[1:3, 1] = l_sublayout
    l_sublayout[:v] = [scene3D, buttongrid]

    btn_RESET       = Button(scene, label = "RESET")
    btn_ZOOM_in     = Button(scene, label = "Zoom +")
    btn_ZOOM_out    = Button(scene, label = "Zoom -")
    btn_PLAY_PAUSE  = Button(scene, label = @lift($running ? "PAUSE" : " PLAY  "))
    btn_STOP        = Button(scene, label = "STOP")
    sw = Toggle(scene, active = false)
    label = Label(scene, "repeat")
    
    buttongrid[1, 1:7] = [btn_PLAY_PAUSE, btn_ZOOM_in, btn_ZOOM_out, btn_RESET, btn_STOP, sw, label]

    gl_screen = display(scene)
    s = Viewer3D(scene, layout, scene3D, cam, gl_screen, btn_RESET, btn_ZOOM_in, btn_ZOOM_out)

    init_system(s.scene3D; show_kite=show_kite)

    camera = cameracontrols(s.scene3D.scene)
    reset_view(camera, s.scene3D)

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
    status[] = "Stopped"
    return s
end

function save_png(viewer; filename="video", index = 1)
    # scene.center = false
    buffer = IOBuffer()
    @printf(buffer, "%06i", index) 
    save(filename * String(take!(buffer)) * ".png", viewer.scene)
end
