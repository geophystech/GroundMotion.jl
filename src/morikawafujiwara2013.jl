## LICENSE
##   Copyright (c) 2018 GEOPHYSTECH LLC
##
##   Licensed under the Apache License, Version 2.0 (the "License");
##   you may not use this file except in compliance with the License.
##   You may obtain a copy of the License at
##
##       http://www.apache.org/licenses/LICENSE-2.0
##
##   Unless required by applicable law or agreed to in writing, software
##   distributed under the License is distributed on an "AS IS" BASIS,
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##   See the License for the specific language governing permissions and
##   limitations under the License.
##
## initial release by Andrey Stepnov, email: a.stepnov@geophsytech.ru

## Morikawa Fujiwara2013 (2013) PGA modeling ON GRID, Dl = constant
function pga_mf2013(eq::Earthquake,config::Params_mf2013,grid::Array{Point_vs30};min_pga::Number=0,Dl::Number=250,Xvf::Number=0)
  vs30_row_num = length(grid[:,1])
  # define magnitude and epicenter
  eq.moment_mag == 0 ? magnitude = eq.local_mag : magnitude = eq.moment_mag
  magnitude = min(magnitude,config.Mw0)
  epicenter = LatLon(eq.lat, eq.lon)
  # define g_global
  g_global = 9.81
  # define a*Mw'
  aMw = config.a*magnitude
  # define Gd out of loop by grid points
  Gd = config.pd*log10(max(config.Dlmin,Dl)/config.D0)
  # init output_data
  output_data = Array{Point_pga_out}(0)
  # main cycle by grid points
  for i=1:vs30_row_num
    # rrup the same as X in Si-Midorikawa (1999) formulae
    # eq.depth the same as D in in Si-Midorikawa (1999) formulae
    current_point = LatLon(grid[i].lat,grid[i].lon)
    r_rup = sqrt((distance(current_point,epicenter)/1000)^2 + eq.depth^2)
    # \logA where A in cm/s^2
    log_A = aMw + config.b*r_rup + config.c - log10(r_rup + config.d*10^(config.e*magnitude))
    # Amplification by Deep Sedimentary Layers
    log_Agd = log_A + Gd
    # vs30 amplification
    Gs = config.ps*log10(min(config.Vsmax,grid[i].vs30)/config.V0)
    log_Ags = log_Agd + Gs
    # ASID
    if config.ASID == true
i     AI = config.gamma*Xvf*(eq.depth - 30)
      log_AI = log_Ags + AI
      A = 10^(log_AI) # pga in cm/c^2
      g = round(((A/100)/g_global * 100),2) ## %g rounded to ggg.gg
    else
      A = 10^(log_Ags)
      g = round(((A/100)/g_global * 100),2)
    end
    if g >= min_pga
      output_data = push!(output_data, Point_pga_out(grid[i].lon,grid[i].lat,g))
    end
    # debug
    # println(hcat(grid[i].vs30,r_rup,log_ARA,A,g))
  end
  return output_data
end

