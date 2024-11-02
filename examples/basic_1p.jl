using KiteViewers, KiteUtils
viewer::Viewer3D = Viewer3D(true);
segments=6
state=demo_state(segments+1)
update_system(viewer, state; ned=false)
nothing