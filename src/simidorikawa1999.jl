## Si-Midorikawa (1999) PGA modeling
function gmpe_simidorikawa1999(eq::Earthquake,grid::Array{Point_vs30},config::Params_simidorikawa1999,min_pga::Number=0)
  vs30_row_num = length(grid[:,1])
  eq.moment_mag == 0 ? magnitude = eq.local_mag : magnitude = eq.moment_mag
  epicenter = LatLon(eq.lat, eq.lon)
  
  # define \sum{d_i S_i}
  sum_di_si = config.d1*config.S1 + 
                config.d2*config.S2 + config.d3*config.S3
  # define b = aMw + hD + \sum{d_i S_i} +e
  b = config.a*magnitude + config.h + sum_di_si + config.e_
  # define c
  c = 0.006*10^(0.5*magnitude)
  # init output_data
  output_data = Array{Point_gmpe_out}(0)
  
  # main cycle by grid points
  for i=1:vs30_row_num
    # rrup the same as X in Si-Midorikawa (1999) formulae
    # eq.depth the same as D in in Si-Midorikawa (1999) formulae
    current_point = LatLon(grid[i].lat,grid[i].lon)
    r_rup = sqrt((distance(current_point,epicenter)/1000)^2 + eq.depth^2)
    
    # A in cm/s^2
    A = b - log10(r_rup + c)
    
    g = round((exp(f1 + f5 + f8) * 100),2)
    if g >= min_pga
      output_data = push!(output_data, Point_gmpe_out(grid[i].lon,grid[i].lat,g))
    end
    # debug
    #println(hcat(grid[i].vs30,r_rup,f1,f8,pga1100,f5,g[i]))
  end
  
  return output_data
end
