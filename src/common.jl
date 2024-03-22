# draw the kite power system, consisting of the tether, the kite and the state (text and numbers)
function init_system(scene; show_kite=true)
    sphere = Sphere(Point3f(0, 0, 0), Float32(0.07 * SCALE))
    meshscatter!(scene, part_positions, marker=sphere, markersize=1.0, color=:yellow)
    cyl = Cylinder(Point3f(0,0,-0.5), Point3f(0,0,0.5), Float32(0.035 * SCALE))        
    meshscatter!(scene, positions, marker=cyl, rotations=rotations, markersize=markersizes, color=:yellow)
    if show_kite
        meshscatter!(scene, kite_pos, marker=KITE, markersize = 0.25, rotations=quat, color=:blue)
    end
    if Sys.islinux()
        lin_font="/usr/share/fonts/truetype/ttf-bitstream-vera/VeraMono.ttf"
        if isfile(lin_font)
            font=lin_font
        else
            font="/usr/share/fonts/truetype/freefont/FreeMono.ttf"
        end
    else
        font="Courier New"
    end
    if se().fixed_font != ""
        font=se().fixed_font
    end
    text!(scene, textnode, position  = Point2f(50, 110), fontsize=TEXT_SIZE, font=font, align = (:left, :top), show_axis = false, space=:pixel)
    text!(scene, textnode2, position  = Point2f(630, 750), fontsize=TEXT_SIZE, font=font, align = (:left, :bottom), show_axis = false, space=:pixel)
end

# update the kite power system, consisting of the tether, the kite and the state (text and numbers)
function update_system(kv::AKV, state::SysState; scale=1.0, kite_scale=1.0)
    segments=se().segments
    azimuth = state.azimuth
    if azimuth ≈ 0 # suppress -0 and replace it with 0
        azimuth=zero(azimuth)
    end
    fourpoint = length(state.Z) > segments+1
    if fourpoint
        height = state.Z[end-2]
    else
        height = state.Z[end]
    end
    # move the particles to the correct position
    for i in range(1, length=se().segments+1)
        points[i] = Point3f(state.X[i], state.Y[i], state.Z[i]) * scale
    end
    if fourpoint
        pos_pod = Point3f(state.X[segments+1], state.Y[segments+1], state.Z[segments+1]) * scale
        # enlarge 4 point kite
        for i in segments+2:length(state.Z)
            pos_abs = Point3f(state.X[i], state.Y[i], state.Z[i]) * scale
            pos_rel = pos_abs-pos_pod
            points[i] = pos_abs + (kite_scale-1.0) * pos_rel
        end
    end
    part_positions[] = [(points[k]) for k in 1:length(state.Z)]

    function calc_positions(s)
        tmp = [(points[k] + points[k+1])/2 for k in 1:segments]
        if fourpoint
            push!(tmp, (points[s+1]+points[s+4]) / 2) # S6
            push!(tmp, (points[s+2]+points[s+5]) / 2) # S8
            push!(tmp, (points[s+3]+points[s+5]) / 2) # S7
            push!(tmp, (points[s+2]+points[s+4]) / 2) # S2
            push!(tmp, (points[s+1]+points[s+5]) / 2) # S5
            push!(tmp, (points[s+4]+points[s+3]) / 2) # S4
            push!(tmp, (points[s+1]+points[s+2]) / 2) # S1
            push!(tmp, (points[s+3]+points[s+2]) / 2) # S9
        end
        tmp
    end
    function calc_markersizes(s)
        tmp = [Point3f(1, 1, norm(points[k+1] - points[k])) for k in 1:segments]
        if fourpoint
            push!(tmp, Point3f(1, 1, norm(points[s+1] - points[s+4]))) # S6
            push!(tmp, Point3f(1, 1, norm(points[s+2] - points[s+5]))) # S8
            push!(tmp, Point3f(1, 1, norm(points[s+3] - points[s+5]))) # S7
            push!(tmp, Point3f(1, 1, norm(points[s+2] - points[s+4]))) # S2
            push!(tmp, Point3f(1, 1, norm(points[s+1] - points[s+5]))) # S5
            push!(tmp, Point3f(1, 1, norm(points[s+4] - points[s+3]))) # S4
            push!(tmp, Point3f(1, 1, norm(points[s+1] - points[s+2]))) # S1
            push!(tmp, Point3f(1, 1, norm(points[s+3] - points[s+2]))) # S9
        end
        tmp
    end
    function calc_rotations(s)
        tmp = [normalize(points[k+1] - points[k]) for k in 1:segments]
        if fourpoint
            push!(tmp, normalize(points[s+1] - points[s+4]))
            push!(tmp, normalize(points[s+2] - points[s+5]))
            push!(tmp, normalize(points[s+3] - points[s+5]))
            push!(tmp, normalize(points[s+2] - points[s+4]))
            push!(tmp, normalize(points[s+1] - points[s+5]))
            push!(tmp, normalize(points[s+4] - points[s+3]))
            push!(tmp, normalize(points[s+1] - points[s+2]))
            push!(tmp, normalize(points[s+3] - points[s+2]))
        end
        tmp
    end

    # move, scale and turn the cylinder correctly
    positions[]   = calc_positions(segments)
    markersizes[] = calc_markersizes(segments)
    rotations[]   = calc_rotations(segments)

    if fourpoint
        s = segments
        q0 = state.orient                                     # SVector in the order w,x,y,z
        quat[]     = Quaternionf(q0[2], q0[3], q0[4], q0[1])  # the constructor expects the order x,y,z,w
        kite_pos[] = 0.8 * 0.5 * (points[s+4] + points[s+5]) + 0.2 * points[s+1]
    else
        # move and turn the kite to the new position
        q0 = state.orient                                     # SVector in the order w,x,y,z
        quat[]     = Quaternionf(q0[2], q0[3], q0[4], q0[1]) # the constructor expects the order x,y,z,w
        kite_pos[] = Point3f(state.X[segments+1], state.Y[segments+1], state.Z[segments+1]) * scale
    end
end

function reset_view(cam, scene3D)
    update_cam!(scene3D.scene, Vec3f(-15.425113, -18.925116, 5.5), Vec3f(-1.5, -5.0, 5.5))
end

function zoom_scene(camera, scene, zoom=1.0f0)
    @extractvalue camera (fov, near, lookat, eyeposition, upvector)
    dir_vector = eyeposition - lookat
    new_eyeposition = lookat + dir_vector * (2.0f0 - zoom)
    update_cam!(scene, new_eyeposition, lookat)
end

function reset_and_zoom(camera, scene3D, zoom)
    reset_view(camera, scene3D)
    if ! (zoom ≈ 1.0) 
        zoom_scene(camera, scene3D.scene, zoom)  
    end
end