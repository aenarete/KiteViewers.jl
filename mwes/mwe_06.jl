using KiteViewers, KiteUtils
set = deepcopy(se())
set.segments=12
viewer=Viewer3D(set, true; precompile=true)
segments=set.segments
state=demo_state_4p(segments+1)
update_system(viewer, state, kite_scale=0.25)
sleep(5)
#close(viewer.screen)