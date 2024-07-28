# example for running the script twice is failing

using Pkg, Timers
if ! ("KitePodModels" ∈ keys(Pkg.project().dependencies))
    using TestEnv; TestEnv.activate()
end

using KiteViewers, KiteModels, KitePodModels, Rotations
using KiteUtils

const Model = KPS4

if ! @isdefined kcu;  const kcu = KCU(se());   end
if ! @isdefined kps4; const kps4 = Model(kcu); end

# the following values can be changed to match your interest
dt = 0.05
TIME = 50
TIME_LAPSE_RATIO = 5
STEPS = Int64(round(TIME/dt))
STATISTIC = false
SHOW_VIEWER = true
SHOW_KITE = true
SAVE_PNG  = false
PLOT_PERFORMANCE = false
# end of user parameter section #

SHOW_KITE = false

time_vec::Vector{Float64} = zeros(div(STEPS, TIME_LAPSE_RATIO))
viewer::Viewer3D = Viewer3D(SHOW_KITE)

# viewer=Viewer3D(true);
segments=6
state=demo_state_4p(segments+1)
update_system(viewer, state, kite_scale=0.25)
nothing