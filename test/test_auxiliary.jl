@testset "GRID'S read/convert" begin

    @test typeof(grid) == Array{GroundMotion.Point_vs30,1}
    @test length(grid) == TEST_GRID_SIZE

    @info("get PGA data grid")
    include("../examples/as2008.conf")
    pga_grid = gmpe_as2008(eq_6, config_as2008_pga, grid)
    @test typeof(pga_grid) == Array{GroundMotion.Point_pga_out,1}

    @info("convert to Point_vs30")
    A = convert_to_point_vs30(raw_grid)
    @test length(A) == 17

    @info("convert to float array")
    A = convert_to_float_array(grid)
    @test typeof(A) == Array{Float64,2}
    @test length(A) == 51
    @test round(sum(A[:, 3]), digits=2) == 12400.0
    A = convert_to_float_array(grid_dl)
    @test typeof(A) == Array{Float64,2}
    @test length(A) == 68
    @test round(sum(A[:, 4]), digits=2) == 15300.0
    A = convert_to_float_array(pga_grid)
    @test typeof(A) == Array{Float64,2}
    @test length(A) == 51
    @test round(sum(A[:, 3]), digits=2) == 4.39

    @info("convert pga to ssi")
    push!(pga_grid, Point_pga_out(140.0, 53.0, 0.00)) # add zero pga intensity
    push!(pga_grid, Point_pga_out(140.1, 53.1, 0.01)) # add negative SSI intensity
    B = convert_from_pga_to_ssi(pga_grid)
    C = convert_to_float_array(B)
    @test round(sum(C[:, 3]), digits=2) == 47.45

    @info("convert ssi to pga")
    B = convert_from_ssi_to_pga(B)
    B = convert_to_float_array(B)
    @test round(sum(B[:, 3]), digits=2) == 4.39
end
