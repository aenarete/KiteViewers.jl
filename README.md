# KiteViewers

This package provides different kind of 2D and 3D viewers for kite power system.

## Exported types
Viewer3D

## Exported functions
update_points

## Examples
    using KiteViewers
    viewer=Viewer3D(true);

After some time a window with the 3D view of a kite power system should pop up.

    using StaticArrays
    segments=6
    pos=zeros(SVector{segements+1, MVector{3, Float64}})
    update_points(pos, segments)



