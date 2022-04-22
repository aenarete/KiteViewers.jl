using KiteViewers, KiteModels
viewer = Viewer3D()
init_system(viewer.scene3D)

# change this to KPS3 or KPS4
const Model = KPS3

if ! @isdefined kcu;  const kcu = KCU(se());   end
if ! @isdefined kps4; const kps4 = Model(kcu); end

# the following values can be changed to match your interest
dt = 0.05
TIME = 60
STEPS = Int64(round(TIME/dt))
FRONT_VIEW = false
ZOOM = true
STATISTIC = false
# end of user parameter section #

function plot2d(pos, reltime; zoom=ZOOM, front=FRONT_VIEW, segments=se().segments)
    scale=0.1
    update_points(viewer.scene3D, pos, segments, scale)
end 

function simulate(integrator, steps, plot=false)
    start = integrator.p.iter
    for i in 1:steps
        KiteModels.next_step!(kps4, integrator, dt=dt)     
        reltime = i*dt
        plot2d(kps4.pos, reltime; zoom=ZOOM, front=FRONT_VIEW, segments=se().segments) 
        # sleep(dt)         
    end
    (integrator.p.iter - start) / steps
end

integrator = KiteModels.init_sim!(kps4, stiffness_factor=0.04, prn=STATISTIC)

av_steps = simulate(integrator, STEPS, true)
nothing
