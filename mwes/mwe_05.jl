using KiteViewers, KiteUtils
se().segments=12
viewer=Viewer3D(se(), true; precompile=true, menus=true)
segments=se().segments
state=demo_state_4p(segments+1)
update_system(viewer, state, kite_scale=0.25)
sleep(5)
close(viewer.screen)