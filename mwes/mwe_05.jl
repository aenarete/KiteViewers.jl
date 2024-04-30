using KiteViewers, KiteUtils
se().segments=12
viewer=Viewer3D(se(), true; precompile=false, menus=true)
segments=se().segments
state=demo_state_4p(segments+1)
update_system(viewer, state, kite_scale=0.25)

on(viewer.menu_project.i_selected) do c
    println(viewer.menu_project.i_selected[])
    println(viewer.menu_project.selection[])
end
# sleep(5)
# close(viewer.screen)