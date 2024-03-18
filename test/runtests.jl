using KiteUtils
set_data_path()
using KiteViewers
set_data_path()
using Test

cd("..")
include("test_steering.jl")

@testset "KiteViewers.jl" begin
    segments=se().segments
    pos_kite   = kps4.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    @test isapprox(rad2deg(elevation), 69.49651592080296, rtol=1e-3)
    azimuth = azimuth_east(pos_kite)
    @test isapprox(rad2deg(azimuth), 2.2941958048609155, rtol=2e-2, atol=1)
    force = winch_force(kps4) 
    @test isapprox(force, 461.637574830213, rtol=1e-2)
end
