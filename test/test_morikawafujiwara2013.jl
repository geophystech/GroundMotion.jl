## Morikawa and Fujiwara 2013 GMPE tests
@testset "Morikawa and Fujiwara 2013 GMPE PGA" begin
  # init model parameters
  include("../examples/morikawa-fujiwara-2013.conf")
  ## test at epicenter on grid M7.0
#  @test pga_simidorikawa1999(eq_7,config_simidorikawa1999_crustal,grid_epicenter)[1].pga == 59.04
  ## run PGA modeling on grid withoit minpga Depth <= 30 M6.0
#  S_c = pga_simidorikawa1999(eq_6,config_simidorikawa1999_crustal,grid)
#  @test length(S_c) == TEST_GRID_SIZE
#  @test round(sum([S_c[i].pga for i=1:length(S_c)]),2) == 6.98
#  S_intp = pga_simidorikawa1999(eq_6,config_simidorikawa1999_interplate,grid)
#  @test length(S_intp) == TEST_GRID_SIZE 
#  @test round(sum([S_intp[i].pga for i=1:length(S_intp)]),2) == 8.38
#  S_intra = pga_simidorikawa1999(eq_6,config_simidorikawa1999_intraplate,grid)
#  @test length(S_intra) == TEST_GRID_SIZE
#  @test round(sum([S_intra[i].pga for i=1:length(S_intra)]),2) == 13.9
  ## run PGA modeling on grid with minpga Depth <= 30 M6.0
#  S_c = pga_simidorikawa1999(eq_6,config_simidorikawa1999_crustal,grid,0.34)
#  @test length(S_c) == WITH_MINPGA
#  @test round(sum([S_c[i].pga for i=1:length(S_c)]),2) == 4.61
  ## run PGA modeling on grid with minpga Depth > 30 M6.0
#  eq_30 = Earthquake(143.04,51.92,35,6.0)
#  S_c = pga_simidorikawa1999(eq_30,config_simidorikawa1999_crustal,grid,0.15)
#  @test length(S_c) == WITH_MINPGA
#  @test round(sum([S_c[i].pga for i=1:length(S_c)]),2) == 2.04
  ## run PGA modeling for plotting Depth <= 30 M6.0
#  S_c = pga_simidorikawa1999(eq_6,config_simidorikawa1999_crustal)
#  @test length(S_c) == SIMULATION_ARRAY_SIZE
#  @test round(sum(S_c),2) == 1096.79
#  S_intp = pga_simidorikawa1999(eq_6,config_simidorikawa1999_interplate)
#  @test round(sum(S_intp),2) == 1318.74
#  S_intra = pga_simidorikawa1999(eq_6,config_simidorikawa1999_intraplate)
#  @test round(sum(S_intra),2) == 2188.89
#  ## run PGA modeling for plotting Depth > 30 M6.0
#  S_c = pga_simidorikawa1999(eq_30,config_simidorikawa1999_crustal)
#  @test round(sum(S_c),2) == 722.93
end
