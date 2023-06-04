@testset "GMPE corr on PGA grid (weighted averaging method)" begin

    @info("tests on load  GMPE grid")
    GRID = read_pga_file("SakhGMPE.txt")
    @test maximum([x.pga for x in GRID]) == 1.84

    @info("tests on load/convert intensity measures")
    intensity_mesuares_ssi = read_intensity_file("felt_reports.txt")
    @test [x.intensity for x in intensity_mesuares_ssi] |> sum == 38.8
    intensity_mesuares_pga = convert_from_ssi_to_pga(intensity_mesuares_ssi)
    @test [
              x.intensity for x in intensity_mesuares_pga
          ] |> sum |> x -> round(x, digits=2) == 18.38
    intensity_mesuares_ssi_back = convert_from_pga_to_ssi(
        intensity_mesuares_pga
    ) # convert back
    @test [
        x.intensity for x in intensity_mesuares_ssi_back
    ] |> sum == 38.81 # round issue

    @info("Run test on pga grid case SSI out")
    include("../examples/gmpe-corr.conf")
    D = gmpe_corr(
        config_gmpe_corr_base, GRID, intensity_mesuares_ssi,
        intensity_in_pga=false, pga_out=false
    )
    @test [x.ssi for x in D] |> sum |> x -> round(x, digits=2) == 291769.35
    @test D[120797].ssi == 5.75
    @test D[118134].ssi == 5.85

    @info("Run test on pga grid case PGA out")
    D = gmpe_corr(
        config_gmpe_corr_base, GRID, intensity_mesuares_pga,
        intensity_in_pga=true, pga_out=false
    )
    @test [x.ssi for x in D] |> sum |> x -> round(x, digits=2) == 291776.63 # round issue
    @test D[120797].ssi == 5.75
    @test D[118134].ssi == 5.85

    @info("Run test on pga grid case PGA out")
    D = gmpe_corr(
        config_gmpe_corr_base, GRID, intensity_mesuares_ssi,
        intensity_in_pga=false, pga_out=true
    )
    @test [x.pga for x in D] |> sum |> x -> round(x, digits=2) == 22516.2 # round issue
    @test D[120797].pga == 3.57
    @test D[118134].pga == 3.91
end
