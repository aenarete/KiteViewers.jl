using KiteUtils
set_data_path()
using KiteViewers
set_data_path()
using Test

cd("..")
include("test_parking.jl")

@testset "KiteViewers.jl" begin
    segments=load_settings("system.yaml").segments
    pos_kite   = kps4.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    @test isapprox(rad2deg(elevation), 69.32731405922591, rtol=1e-2)
    azimuth = azimuth_east(pos_kite)
    @test isapprox(rad2deg(azimuth), -0.11154443486464477, rtol=2e-2, atol=10)
    force = winch_force(kps4) 
    @test isapprox(force, 460.9357175124477, rtol=2e-2)
end
