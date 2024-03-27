using KiteViewers, KiteUtils
viewer::Viewer3D = Viewer3D()
clear_viewer(viewer)

# KiteViewers.running[]=true
on(viewer.btn_OK.clicks) do c
    println(viewer.menu.i_selected[])
    println(viewer.menu.selection[])
end
on(viewer.menu_rel_tol.i_selected) do c
    println(viewer.menu_rel_tol.i_selected[])
    println(viewer.menu_rel_tol.selection[])
end
state = KiteViewers.KiteUtils.demo_state(7)
state.e_mech=77
viewer.step=2
update_system(viewer, state)
nothing