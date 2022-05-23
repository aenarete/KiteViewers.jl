using Pkg, Timers
if ! ("KiteModels" ∈ keys(Pkg.project().dependencies))
    using TestEnv; TestEnv.activate()
end

using KiteViewers, KiteModels, KitePodModels, Joysticks

# change this to KPS3 or KPS4
const Model = KPS4

if ! @isdefined kcu;    const kcu = KCU(se());   end
if ! @isdefined kps4;   const kps4 = Model(kcu); end
if ! @isdefined js;
    const js = open_joystick();
    const jsaxes = JSState(); 
    const jsbuttons = JSButtonState()
    async_read!(js, jsaxes, jsbuttons)
end

# the following values can be changed to match your interest
dt = 0.05
TIME_LAPSE_RATIO = 1
SHOW_KITE = true
# end of user parameter section #

if ! @isdefined viewer; const viewer = Viewer3D(SHOW_KITE); end

function update_system2(kps)
    sys_state = SysState(kps)
    KiteViewers.update_system(viewer, sys_state; scale = 0.08, kite_scale=3)
end 

function simulate(integrator)
    start = integrator.p.iter
    start_time_ns = time_ns()
    clear_viewer(viewer)
    i=1
    j=0; k=0
    GC.gc()
    max_time = 0
    while true
        v_ro = 0.0
        if i > 100
            depower = 0.25 - jsaxes.y*0.4
            if depower < 0.25; depower = 0.25; end
            set_depower_steering(kps4.kcu, depower, jsaxes.x)
            v_ro = jsaxes.u * 8.0 
        end   
        t_sim = @elapsed KiteModels.next_step!(kps4, integrator, v_ro=v_ro, dt=dt)
        t_gc = 0.0
        if t_sim < 0.1*dt
            t_gc = @elapsed GC.gc(false)
        end
        if mod(i, TIME_LAPSE_RATIO) == 0 
            update_system2(kps4) 
            wait_until(start_time_ns + 1e9*dt, always_sleep=true) 
            mtime = 0
            if i > 10/dt 
                # if we missed the deadline by more than 2 ms
                mtime = time_ns() - start_time_ns
                if mtime > dt*1e9 + 2e6
                    print(".")
                    j += 1
                end
                k +=1
            end
            if mtime > max_time
                max_time = mtime
            end            
            start_time_ns = time_ns()
        end
        if viewer.stop break end
        i += 1
    end
    misses = j/k * 100
    println("\nMissed the deadline for $(round(misses, digits=2)) %. Max time: $(round((max_time*1e-6), digits=1)) ms")
    (integrator.p.iter - start) / i
end

function play()
    integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04)
    av_iter = simulate(integrator)
    println("Average iterations per step: $av_iter")
end

function async_play()
    if viewer.stop
        @async begin
            play()
            stop(viewer)
        end
    end
end

on(viewer.btn_PLAY.clicks) do c; async_play(); end
on(jsbuttons.btn1) do val; if val async_play() end; end

on(viewer.btn_STOP.clicks) do c; stop(viewer); end
on(jsbuttons.btn2) do val; if val stop(viewer) end; end

play()
stop(viewer)
nothing
