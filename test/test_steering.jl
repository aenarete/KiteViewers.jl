using Pkg
if ! ("KiteModels" ∈ keys(Pkg.project().dependencies))
    using TestEnv; TestEnv.activate()
end

using KiteViewers, KiteModels, KitePodModels, Rotations, StaticArrays

# change this to KPS3 or KPS4
const Model = KPS3

if ! @isdefined kcu;  const kcu = KCU(se());   end
if ! @isdefined kps4; const kps4 = Model(kcu); end

# the following values can be changed to match your interest
dt = 0.05
TIME = 30
TIME_LAPSE_RATIO = 5
STEPS = Int64(round(TIME/dt))
STATISTIC = false
SHOW_KITE = true
# end of user parameter section #

if ! @isdefined viewer; const viewer = Viewer3D(); show_window(viewer; show_kite=SHOW_KITE); end

include("../examples/timers.jl")

function update_system(kps::KPS3, reltime; segments=se().segments)
    scale = 0.1
    pos_kite   = kps.pos[end]
    pos_before = kps.pos[end-1]
    elevation = calc_elevation(pos_kite)
    azimuth = azimuth_east(pos_kite)
    v_reelout = kps.v_reel_out
    force = winch_force(kps)    
    if SHOW_KITE
        v_app = kps.v_apparent
        rotation = rot(pos_kite, pos_before, v_app)
        q = QuatRotation(rotation)
        orient = MVector{4, Float32}(Rotations.params(q))
        update_points(viewer.scene3D, kps.pos, segments, scale, reltime, elevation, azimuth, force, orient)
    else
        update_points(viewer.scene3D, pos, segments, scale, elevation, azimuth, force, reltime)
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
        update_system(kps4, reltime; segments=se().segments) 
        # sleep(dt/5)    
        wait_until(start_time+i*dt/TIME_LAPSE_RATIO)     
    end
    (integrator.p.iter - start) / steps
end

integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04, prn=STATISTIC)

av_steps = simulate(integrator, STEPS)
nothing
