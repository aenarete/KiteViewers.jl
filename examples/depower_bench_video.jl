using Pkg
if ! ("KiteModels" ∈ keys(Pkg.project().dependencies))
    using TestEnv; TestEnv.activate()
end

using KiteViewers, KiteModels, KitePodModels, Rotations

# example program that shows
# a. how to create a video
# b. how to create a performance plot (simulation speed vs time)
const Model = KPS4

if ! @isdefined kcu;  const kcu = KCU(se());   end
if ! @isdefined kps4; const kps4 = Model(kcu); end

# the following values can be changed to match your interest
dt = 0.05
TIME = 50
TIME_LAPSE_RATIO = 10
STEPS = Int64(round(TIME/dt))
STATISTIC = false
SHOW_VIEWER = true
SHOW_KITE = false
SAVE_PNG  = false
PLOT_PERFORMANCE = false
# end of user parameter section #

if ! @isdefined time_vec; const time_vec = zeros(div(STEPS, TIME_LAPSE_RATIO)); end
if ! @isdefined viewer; const viewer = Viewer3D(SHOW_KITE); end

# ffmpeg -r:v 20 -i "video%06d.png" -codec:v libx264 -preset veryslow -pix_fmt yuv420p -crf 10 -an "video.mp4"

include("timers.jl")

function update_system(kps::KPS3, reltime; segments=se().segments)
    scale = 0.08
    pos_kite   = kps.pos[end]
    pos_before = kps.pos[end-1]
    elevation = calc_elevation(pos_kite)
    azimuth = azimuth_east(pos_kite)
    force = winch_force(kps)    
    if SHOW_KITE
        v_app = kps.v_apparent
        rotation = rot(pos_kite, pos_before, v_app)
        q = QuatRotation(rotation)
        orient = MVector{4, Float32}(Rotations.params(q))
        update_points(kps.pos, segments, scale, reltime, elevation, azimuth, force, orient=orient)
    else
        update_points(kps.pos, segments, scale, reltime, elevation, azimuth, force)
    end
end 

function update_system(kps::KPS4, reltime; segments=se().segments)
    scale = 0.08
    force = winch_force(kps)    
    heading = calc_heading(kps)
    course = calc_course(kps)
    update_points(kps.pos, segments, scale, reltime, force, kite_scale=3.5, heading=heading, course=course)
end 

function simulate(integrator, steps; log=false)
    start = integrator.p.iter
    start_time = time()
    time_ = 0.0
    for i in 1:steps
        iter = kps4.iter
        if i == 300
            set_depower_steering(kps4.kcu, 0.30, 0.0)
        elseif i == 640
            set_depower_steering(kps4.kcu, 0.35, 0.0)    
        end
        KiteModels.next_step!(kps4, integrator, dt=dt)     
        reltime = i*dt
        if mod(i, TIME_LAPSE_RATIO) == 0 || i == steps
            if SHOW_VIEWER update_system(kps4, reltime; segments=se().segments) end
            if log
                save_png(viewer, index=div(i, TIME_LAPSE_RATIO))
            end
            if SHOW_VIEWER
                if start_time+dt > time() + 0.002
                    wait_until(start_time+dt) 
                else
                    sleep(0.001)
                end
            end
            start_time = time()
            time_vec[div(i, TIME_LAPSE_RATIO)]=time_/(TIME_LAPSE_RATIO*dt)*100.0
            time_ = 0.0
        end
        time_ += (kps4.iter - iter)*1.5e-6
    end
    (integrator.p.iter - start) / steps
end

integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04, prn=STATISTIC)

av_steps = simulate(integrator, STEPS, log=SAVE_PNG)
if PLOT_PERFORMANCE
    using Plots
    plot(range(0.5,TIME,step=0.5), time_vec, ylabel="CPU time [%]", xlabel="Simulation time [s]", legend=false)
    savefig("performance.png")
end
# mean with :Dense integrator: 6.66% CPU time, 15 times realtime
# mean with :GMRES integrator: 1.96% CPU time, 51 times realtime
