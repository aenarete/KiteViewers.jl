using KiteViewers
viewer::Viewer3D = Viewer3D()
clear_viewer(viewer)

# KiteViewers.running[]=true
on(viewer.btn_OK.clicks) do c
    println(viewer.menu.i_selected[])
    println(viewer.menu.selection[])
end
nothing