using KiteViewers, KiteUtils
using Test

cd("..")
include("test_steering.jl")

@testset "KiteViewers.jl" begin
    segments=se().segments
    pos_kite   = kps4.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    @test rad2deg(elevation) ≈ 70.31815477683752
    azimuth = azimuth_east(pos_kite)
    @test rad2deg(azimuth) ≈ 9.217613192065718
    force = winch_force(kps4) 
    @test force ≈ 495.7191503651492
end
