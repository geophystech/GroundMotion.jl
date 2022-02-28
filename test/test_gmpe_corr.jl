# Tests for weighted averaging method
@testset "GMPE corr on PGA grid" begin
  @info("tests on load  GMPE grid")
  GRID = read_pga_file("SakhGMPE.txt")
  @test maximum([x.pga for x in GRID]) == 1.84
  @info("tests on load/convert intensity measures")
  intensity_mesuares_ssi = read_intensity_file("felt_reports.txt")
  @test sum([x.intensity for x in intensity_mesuares_ssi]) == 38.8
  intensity_mesuares_pga = convert_from_ssi_to_pga(intensity_mesuares_ssi)
  @test round(sum(sum([x.intensity for x in intensity_mesuares_pga])), digits=2) == 18.38
  # convert back
  intensity_mesuares_ssi_back = convert_from_pga_to_ssi(intensity_mesuares_pga)
  @test sum([x.intensity for x in intensity_mesuares_ssi_back]) == 38.81 # round issue
  @info("Run test on pga grid case SSI out")
  include("../examples/gmpe-corr.conf")
  D = gmpe_corr(config_gmpe_corr_base,GRID,intensity_mesuares_ssi,intensity_in_pga=false,pga_out=false)
  @test round(sum([x.ssi for x in D]), digits=2) == 291769.35
  @test D[120797].ssi == 5.75
  @test D[118134].ssi == 5.85
  @info("Run test on pga grid case PGA out")
  D = gmpe_corr(config_gmpe_corr_base,GRID,intensity_mesuares_pga,intensity_in_pga=true,pga_out=false)
  @test round(sum([x.ssi for x in D]), digits=2) == 291776.63 # round issue
  @test D[120797].ssi == 5.75
  @test D[118134].ssi == 5.85
  @info("Run test on pga grid case PGA out")
  D = gmpe_corr(config_gmpe_corr_base,GRID,intensity_mesuares_ssi,intensity_in_pga=false,pga_out=true)
  @test round(sum([x.pga for x in D]), digits=2) == 22516.2 # round issue
  @test D[120797].pga == 3.57
  @test D[118134].pga == 3.91
end
