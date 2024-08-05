using KiteViewers, KiteUtils
viewer::Viewer3D = Viewer3D(true);
segments=6
state=KiteUtils.demo_state_4p_3lines(segments*3+6)
update_system(viewer, state, scale=0.08, kite_scale=4.0)
nothing