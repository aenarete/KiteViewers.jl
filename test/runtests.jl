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
    @test isapprox(rad2deg(elevation), 65.14614262632229, rtol=1e-2)
    azimuth = azimuth_east(pos_kite)
    @test isapprox(rad2deg(azimuth), 33.24375094213839, rtol=2e-2, atol=10)
    force = winch_force(kps4) 
    @test isapprox(force, 593.6905956072441, rtol=2e-2)
end
