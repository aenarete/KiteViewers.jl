let
    using KiteViewers, KiteModels, KitePodModels, Rotations, StaticArrays

    # change this to KPS3 or KPS4
    Model = KPS3

    if ! @isdefined kcu;  kcu = KCU(se());   end
    if ! @isdefined kps4; kps4 = Model(kcu); end

    # the following values can be changed to match your interest
    dt = 0.05
    TIME = 0.25
    TIME_LAPSE_RATIO = 5
    STEPS = Int64(round(TIME/dt))
    FRONT_VIEW = false
    ZOOM = true
    STATISTIC = false
    SHOW_KITE = true
    # end of user parameter section #

    viewer = Viewer3D(SHOW_KITE)

    include("../examples/timers.jl")

    function plot2d(pos, reltime; zoom=ZOOM, front=FRONT_VIEW, segments=se().segments)
        scale = 0.1
        pos_kite   = pos[end]
        pos_before = pos[end-1]
        v_reelout = kps4.v_reel_out
        force = winch_force(kps4)
        if SHOW_KITE
            v_app = kps4.v_apparent
            rotation = rot(pos_kite, pos_before, v_app)
            q = QuatRotation(rotation)
            orient = MVector{4, Float32}(Rotations.params(q))
            update_points(pos, segments, scale, reltime, force; orient=orient)
        else
            update_points(pos, segments, scale, reltime, force, kite_scale=3.5)
        end
    end 

    function simulate(integrator, steps)
        start = integrator.p.iter
        start_time = time()
        for i in 1:steps
            if i == 300
                set_depower_steering(kps4.kcu, 0.25, 0.1)
            elseif i == 302
                set_depower_steering(kps4.kcu, 0.25, -0.1)
            elseif i == 304
                set_depower_steering(kps4.kcu, 0.25, 0.0)            
            end
            # KitePodModels.on_timer(kcu, dt)
            KiteModels.next_step!(kps4, integrator, dt=dt)     
            reltime = i*dt
            plot2d(kps4.pos, reltime; zoom=ZOOM, front=FRONT_VIEW, segments=se().segments) 
            # sleep(dt/5)    
            wait_until(start_time+i*dt/TIME_LAPSE_RATIO)     
        end
        (integrator.p.iter - start) / steps
    end

    integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04, prn=STATISTIC)

    av_steps = simulate(integrator, STEPS)
    nothing
end

@info "Precompile script has completed execution."