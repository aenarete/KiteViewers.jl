using Pkg, Timers
if ! ("KiteModels" ∈ keys(Pkg.project().dependencies))
    using TestEnv; TestEnv.activate()
end

using KiteViewers, KiteModels, KitePodModels, Rotations, Joysticks

# change this to KPS3 or KPS4
const Model = KPS4

if ! @isdefined kcu;    const kcu = KCU(se());   end
if ! @isdefined kps4;   const kps4 = Model(kcu); end
if ! @isdefined js;     const js = open_joystick(); end
if ! @isdefined jsaxes; 
    const jsaxes = JSState(); 
    async_read_jsaxes!(js, jsaxes)
end

# the following values can be changed to match your interest
dt = 0.05
TIME = 45
TIME_LAPSE_RATIO = 1
STEPS = Int64(round(TIME/dt))
STATISTIC = false
SHOW_KITE = true
# end of user parameter section #

if ! @isdefined viewer; const viewer = Viewer3D(SHOW_KITE); end

function update_system2(kps)
    sys_state = SysState(kps)
    KiteViewers.update_system(viewer, sys_state; scale = 0.08, kite_scale=3)
end 

function simulate(integrator, steps)
    start = integrator.p.iter
    start_time_ns = time_ns()
    clear_viewer(viewer)
    for i in 1:steps
        if i == 300
            set_depower_steering(kps4.kcu, 0.25, 0.2)
        elseif i == 303
            set_depower_steering(kps4.kcu, 0.25, 0.0)   
        elseif i == 600
            set_depower_steering(kps4.kcu, 0.25, -0.2)
        elseif i == 622
            set_depower_steering(kps4.kcu, 0.25, 0.0)           
        end
        # KitePodModels.on_timer(kcu, dt)
        KiteModels.next_step!(kps4, integrator, dt=dt)     
        reltime = i*dt
        if mod(i, TIME_LAPSE_RATIO) == 0 || i == steps
            update_system2(kps4) 
            wait_until(start_time_ns + 1e9*dt, always_sleep=true) 
            start_time_ns = time_ns()
        end
        if viewer.stop break end
    end
    (integrator.p.iter - start) / steps
end

function play()
    integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04, prn=STATISTIC)
    simulate(integrator, STEPS)
end

on(viewer.btn_PLAY.clicks) do c
    if viewer.stop
        @async begin
            play()
            stop(viewer)
        end
    end
end
on(viewer.btn_STOP.clicks) do c
   stop(viewer)
end
play()
stop(viewer)
nothing
