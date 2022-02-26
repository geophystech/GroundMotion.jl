## LICENSE
##   Copyright (c) 2018-2022 GEOPHYSTECH LLC
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

## initial release by Andrey Stepnov a.stepnov@geophsytech.ru


"""
Compute new GMPE PGA/intensity grid using weighted averaging method

**IN**
- `eq` Earthquake location and magnitude
- `config` configuration of weighted averaging procedure
- `grid` GMPE field modeling by any of `gmpe_*` method
- `intensity_measures` Intensity measures by felt reports or stations
- `intensity_in_pga` is the intensity measures in PGA %g.gg units?
- `pga_out` if set to `true` function will return corrected GMPE filed in %g.gg units

**OUT**
Corrected GMPE field in `Array{Point_pga_out}` or `Array{Point_ssi_out}`
"""

function gmpe_corr(eq::Earthquake,config::Params_gmpe_corr,grid::Array{Point_pga_out}, intensity_measures::Array{Point_felt_report};intensity_in_pga::Bool=true, pga_out::Bool=true)
  # convert to intensity
  grid = convert_from_pga_to_ssi(grid)
  return grid
end
