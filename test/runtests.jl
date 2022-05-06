using KiteViewers, KiteUtils
using Test

cd("..")
include("test_steering.jl")

@testset "KiteViewers.jl" begin
    segments=se().segments
    pos_kite   = kps4.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    @test isapprox(rad2deg(elevation), 70.31815477683752, rtol=1e-3)
    azimuth = azimuth_east(pos_kite)
    @test isapprox(rad2deg(azimuth), 9.18521251498438, rtol=2e-2)
    force = winch_force(kps4) 
    @test isapprox(force, 495.7191503651492, rtol=1e-2)
end
