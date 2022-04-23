using KiteViewers, KiteModels, KitePodModels
viewer = Viewer3D()
init_system(viewer.scene3D)

# change this to KPS3 or KPS4
const Model = KPS3

if ! @isdefined kcu;  const kcu = KCU(se());   end
if ! @isdefined kps4; const kps4 = Model(kcu); end

# the following values can be changed to match your interest
dt = 0.05
TIME = 40
TIME_LAPSE_RATIO = 10
STEPS = Int64(round(TIME/dt))
FRONT_VIEW = false
ZOOM = true
STATISTIC = false
# end of user parameter section #

# finish: time in seconds since epoch
@inline function wait_until(finish)
    delta = 0.0002
    if finish - 0.002 > time()
        sleep(finish - time() - 0.001)
    end
    # sleep 
    while finish - delta > time()
        Base.Libc.systemsleep(delta)
    end
    # busy waiting
    while finish > time()-0.95e-6
    end
    nothing
end

function plot2d(pos, reltime; zoom=ZOOM, front=FRONT_VIEW, segments=se().segments)
    scale=0.1
    update_points(viewer.scene3D, pos, segments, scale, reltime)
end 

function simulate(integrator, steps)
    start = integrator.p.iter
    start_time = time()
    for i in 1:steps
        if steps == 300
            set_depower_steering(kcu, 0.25, 0.01)
        elseif steps == 301
            set_depower_steering(kcu, 0.25, 0.01)
        elseif steps == 302
            set_depower_steering(kcu, 0.25, 0.01)
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
