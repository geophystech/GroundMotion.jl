## AS2008 model tests
@testset "AS2008 GMPE PGA" begin
  # init model parameters
  include("../examples/as2008.conf")
  # test at epicenter with M7.0, VS=350 
  @test pga_as2008(eq_7,config_as2008,grid_epicenter)[1].pga == 22.45
  # run PGA modeling on grid without minpga M6.0
  A = pga_as2008(eq_6,config_as2008,grid)
  @test length(A) == TEST_GRID_SIZE
  @test round(sum([A[i].pga for i=1:length(A)]),2) == 4.39
  # run PGA modeling on grid with minpga M6.0
  A = pga_as2008(eq_6,config_as2008,grid,0.22)
  @test length(A) == WITH_MINPGA
  @test round(sum([A[i].pga for i=1:length(A)]),2) == 2.86
  # run PGA modeling with M4.0
  A = pga_as2008(eq_4,config_as2008,grid)
  @test length(A) == TEST_GRID_SIZE
  @test round(sum([A[i].pga for i=1:length(A)]),2) == 0.21
  # run PGA modeling for plotting M6.0
  A = pga_as2008(eq_6,config_as2008)
  @test length(A) == SIMULATION_ARRAY_SIZE
  @test round(sum(A),2) == 573.5
  # run PGA Modeling M=4
  @test round(sum(pga_as2008(eq_4,config_as2008)),2) == 84.36
  # run PGA Modeling M=7 
  @test round(sum(pga_as2008(eq_7,config_as2008)),2) == 1486.84
  # run PGA Modeling M=7 with VS30 = 900
  @test round(sum(pga_as2008(eq_7,config_as2008,900)),2) == 1031.1
  # run PGA Modeling M=7 with VS30 = 1600 
  @test round(sum(pga_as2008(eq_7,config_as2008,1600)),2) == 817.23
end 