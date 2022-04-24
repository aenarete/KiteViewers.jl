# KiteViewers

This package provides different kind of 2D and 3D viewers for kite power system.

## Exported types
Viewer3D

## Exported functions
update_points

## Examples
```julia
using KiteViewers
viewer=Viewer3D(true);
```

After some time a window with the 3D view of a kite power system should pop up.
If you keep the window open and execute the following code:

```julia
using KiteUtils#main
segments=6
state=demo_state(segments+1)
update_points(state.pos, segments, orient=state.orient)
```

you should see a kite on a tether.
The same example, but using the 4 point kite model:

```julia
using KiteUtils#main
segments=6
state=demo_state_4p(segments+1)
update_points(state.pos, segments, orient=state.orient)
```