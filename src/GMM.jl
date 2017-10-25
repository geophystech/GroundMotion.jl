Module GMM

  # The distance() function is used, see https://github.com/JuliaGeo/Geodesy.jl for further read
  using Geodesy

  #****************
  #*    TYPES     *
  #****************

  ## VS30 data point
  mutable struct Point_vs30
    lon::Float64
    lat::Float64
    vs30::Float64
  end
  ## Output PGA data point after GMPE calculations
  mutable struct Point_gmpe_out
    lon::Float64
    lat::Float64
    r_rup::Float64
    g::Float64 #Acceleration of gravity in percent rounded to ggg.gg
  end
  ## earthquake location data
  mutable struct Earthquake
    lon::Float64
    lat::Float64
    depth::Float64
    local_mag::Float64
    moment_mag::Float64
  end
  Earthquake(x,y,z,k) = Earthquake(x,y,z,k,0) # Mw usually not ready right after earthquake 
  ## AS2008 GMPE paramaters
  mutable struct Params_as2008
    a1::Float64
    a2::Float64
    a3::Float64
    a4::Float64
    a5::Float64
    a8::Float64
    a10::Float64
    a18::Float64
    b::Float64
    c::Float64
    c1::Float64
    c4::Float64
    n::Float64
    vlin::Float64
    v1::Float64
    vs30_1100::Float64
  end
  ## AS2008 GMPE data point
  mutable struct Point_as2008
    lon::Float64
    lat::Float64
    vs30::Float64
    r_rup::Float64
    f1::Float64
    f5::Float64
    f8::Float64
    pga1100::Float64
    g::Float64 # Acceleration of gravity in fractions
  end

  #****************
  #*  FUNCTIONS   *
  #****************
  ## read VS30 file
  function read_vs30_file(filename::String)
    @time A = readdlm(filename)
    vs30_row_num = length(A[:,1])
    @time B = Array{Point_vs30}(0)
    @time for i=1:vs30_row_num
      B = push!(B,Point_vs30(A[i,1],A[i,2],A[i,3]))
    end
    return B
  end

  ## AS2008 PGA modeling
  function gmpe_as2008(eq::Earthquake,grid::Array{Point_vs30},config::Params_as2008,min_pga::Float64)
    vs30_row_num = length(grid[:,1])
    eq.moment_mag == 0 ? magnitude = eq.local_mag : magnitude = eq.moment_mag
    epicenter = LatLon(eq.lat, eq.lon)
    # define t6
    if magnitude < 5.5
      t6 = 1
    elseif magnitude <= 6.5 && magnitude >= 5.5
      t6 = (0.5 * (6.5 - magnitude) + 0.5)
    else 
      t6 = 0.5
    end
    # debug
    info("DEBUG pring")
    println("vs30_row_num=",vs30_row_num," ", 
            "magnitude=",magnitude," ",
            "epicenter=",epicenter," ",
            "t6=",t6," ")
    info("DEBUG pring")
    println(" vs30 ", " r_rup ", " f1 "," f8 ",
            " pga1100 "," f5 ", "g ")
    # modeling
    g = Array{Float64}(0)
    for i=1:vs30_row_num
      # rrup
      current_point = LatLon(grid[i].lat,grid[i].lon)
      r_rup = sqrt((distance(current_point,epicenter)/1000)^2 + eq.depth^2)
      # F1
      if magnitude <= config.c1
        f1 = config.a1 + config.a4 * (magnitude - config.c1) +
          config.a8 * (8.5 - magnitude)^2 + 
          (config.a2 + config.a3 * (magnitude - config.c1)) *
          log(sqrt(r_rup^2 + config.c4^2))
      else 
        f1 = config.a1 + config.a5 * (magnitude - config.c1) +
          config.a8 * (8.5 - magnitude)^2 +
          (config.a2 + config.a3 * (magnitude - config.c1)) *
              log(sqrt(r_rup^2 + config.c4^2))
      end
      # F8
      if r_rup < 100 
        f8 = 0;
      else 
        f8 = config.a18 * (r_rup - 100) * t6
      end
      # PGA1100
      pga1100 = exp((f1 + (config.a10 + config.b * config.n) *
                 log(config.vs30_1100 / config.vlin) + f8))
      # F5
      if grid[i].vs30 < config.vlin
        f5 =  config.a10 * log(grid[i].vs30 / config.vlin) -
          config.b * log(pga1100 + config.c) + config.b * 
          log(pga1100 + config.c * (grid[i].vs30 / config.vlin)^config.n)
      elseif (grid[i].vs30 > config.vlin) && (grid[i].vs30 < config.v1)
        f5 = (config.a10 + config.b * config.n) *
          log(grid[i].vs30 / config.vlin)
      else
        f5 = (config.a10 + config.b * config.n) * 
          log(config.v1 / config.vlin)
      end
      g = push!(g, round((exp(f1 + f5 + f8) * 100),2))
      # debug
      println(hcat(grid[i].vs30,r_rup,f1,f8,pga1100,f5,g[i]))
    end
    g
  end


end #module

