using Pkg
if ! ("KiteModels" ∈ keys(Pkg.project().dependencies))
    using TestEnv; TestEnv.activate()
end

using KiteViewers, KiteModels, KitePodModels, Rotations

# change this to KPS3 or KPS4
const Model = KPS4

if ! @isdefined kcu;  const kcu = KCU(se());   end
if ! @isdefined kps4; const kps4 = Model(kcu); end

# the following values can be changed to match your interest
dt = 0.05
TIME = 30
TIME_LAPSE_RATIO = 10
STEPS = Int64(round(TIME/dt))
STATISTIC = false
SHOW_KITE = false
# end of user parameter section #

if ! @isdefined viewer; const viewer = Viewer3D(SHOW_KITE); end

include("../examples/timers.jl")

function update_system(kps::KPS3, reltime; segments=se().segments)
    scale = 0.1
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
    scale = 0.1
    pos_kite   = kps.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    azimuth = azimuth_east(pos_kite)
    force = winch_force(kps)    
    update_points(kps.pos, segments, scale, reltime, elevation, azimuth, force)
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
        if mod(i, TIME_LAPSE_RATIO) == 0 || i == steps
            update_system(kps4, reltime; segments=se().segments) 
            if start_time+dt > time() + 0.002
                wait_until(start_time+dt) 
            else
                sleep(0.001)
            end
            start_time = time()
        end
    end
    (integrator.p.iter - start) / steps
end

integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04, prn=STATISTIC)

av_steps = simulate(integrator, STEPS)
nothing
