using KiteUtils
set_data_path()
using KiteViewers
set_data_path()
using Test

cd("..")
include("test_parking.jl")

@testset "KiteViewers.jl" begin
    segments=se().segments
    pos_kite   = kps4.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    @test isapprox(rad2deg(elevation), 69.51421682882923, rtol=1e-2)
    azimuth = azimuth_east(pos_kite)
    @test isapprox(rad2deg(azimuth), 0.1, rtol=2e-2, atol=10)
    force = winch_force(kps4) 
    @test isapprox(force, 461.0137819702637, rtol=2e-2)
end
