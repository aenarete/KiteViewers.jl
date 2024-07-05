using KiteUtils
set_data_path()
using KiteViewers
set_data_path(joinpath(dirname(dirname(pathof(KiteViewers))), "data"))
using Test

cd("..")
include("test_steering.jl")

@testset "KiteViewers.jl" begin
    segments=se().segments
    pos_kite   = kps4.pos[segments+1] # well, this is the position of the pod...
    elevation = calc_elevation(pos_kite)
    @test isapprox(rad2deg(elevation), 69.29496863407165, rtol=1e-2)
    azimuth = azimuth_east(pos_kite)
    @test isapprox(rad2deg(azimuth), 8.108681940337314, rtol=2e-2, atol=10)
    force = winch_force(kps4) 
    @test isapprox(force, 467.76002941588166, rtol=2e-2)
end
