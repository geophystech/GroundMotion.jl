# GroundMotion.jl
The ground motion evaluation module (earthquake seismology)

### Build Status

[![Linux/MacOS](https://travis-ci.org/geophystech/GroundMotion.jl.svg?branch=master)](https://travis-ci.org/geophystech/GroundMotion.jl) [![Windows](https://ci.appveyor.com/api/projects/status/0xyromepmwwt0nob?svg=true)](https://ci.appveyor.com/project/geophystech/groundmotion-jl)
[![Coverage Status](https://coveralls.io/repos/github/geophystech/GroundMotion.jl/badge.svg?branch=master)](https://coveralls.io/github/geophystech/GroundMotion.jl?branch=master)

### Install

```julia
Pkg.add("GroundMotion.jl")
```

**WORK IN PROGRESS!**

## Basic principles

The names of GMPE functions specified type of returned values: `{pga/pgv/pgd/psa}_{Name_of_gmpe_function}`. 

For example: `pga_as2008`, where `pga` is return type of ground motion and `as2008` is AS2008 GMPE Model. The same logic for `pgv,pgd,psa`.

Each GMPE function has at least 2 methods: for calculation based on input VS30-grid or without any grid.

### GRID case

GMPE function for each grid's point calculates `{pga/pgv/pgd/psa}` value using latitude, longitude and VS30 [meters per second]. The output data has return in custom type where latitude and longitude are copy from input grid and `{pga/pgv/pgd/psa}` is calculated by function. 

For example: function `pga_as2008` with parameters
```julia
pga_as2008(eq::Earthquake,
           config_as2008::Params_as2008,
           grid::Array{Point_vs30},
           min_pga::Number)
```
return 1-d `Array{Point_pga_out}` with points based on input grid with `pga > min_pga` (`pga` is Acceleration of gravity in percent (%g) rounded to `ggg.gg`)


### Without grid

In case of without any grid GMPE functions return simple 1-d `Array{Float64}` with `{pga/pgv/pgd/psa}` data. Each `{pga/pgv/pgd/psa}` value in output array is from epicenter to `distance` with `1` [km] step perpendicularly to the epicenter.

Example:
```julia
pga_as2008(eq::Earthquake,
           config::Params_as2008,
           VS30::Number=350,
           distance::Int64=1000)
```
output be `Array{Float64}` with `1:distance` values of `pga` (also rounded to `ggg.gg`).

## Short example:
```julia
using GroundMotion
# init model parameters
include("GroundMoution.jl/examples/as2008.conf")
# load vs30 grid
grid = read_vs30_file("Downloads/web/testvs30.txt")
# set earthquake location
eq = Earthquake(143.04,51.92,13,6)
# run AS2008 PGA modeling on GRID
out_grid = pga_as2008(eq,config_as2008,grid)
# run AS2008 PGA FOR PLOTTING with VS30=30 [m/s^2], distance=1000 [km] by default.
simulation = pga_as2008(eq,config_as2008)
```

## How to get VS30 grid

1. Download GMT grd file from [USGS Vs30 Models and Data page](https://earthquake.usgs.gov/data/vs30/)
2. Unzip it. It takes around 2,7G disk space for one file: 
```bash
unzip global_vs30_grd.zip
...
ls -lh global_vs30.grd
-rw-r--r--  1 jamm  staff   2,7G  8 сен  2016 global_vs30.grd
```
3. Use `GMT2XYZ` [man page](https://www.soest.hawaii.edu/gmt/gmt/html/man/grd2xyz.html) from [GMT](https://www.soest.hawaii.edu/gmt/) to convert grd data to XYZ text file:
```bash
# example:
grd2xyz global_vs30.grd -R145.0/146.0/50.0/51.0 > test_sea.txt
# number of rows:
cat test_sea.txt |wc -l
   14641
```

## Read and Write data grids

Use `read_vs30_file` to read data from vs30 file:
```julia
grid = read_vs30_file("Downloads/web/somevs30.txt")
```
After some `pga_*`,`pgv_*`,`pgd_*`,`psa_*` function on grid done, you will get `Array{Point_{pga,pgv,pgd,psa}_out}`. Use `convert_to_float_array` to convert `Array{Point_{pga,pgv,pgd,psa}_out}` to `Nx3` `Array{Float64}`:
```julia
typeof(A)
#--> Array{GroundMoution.Point_pga_out,1}
length(A)
#--> 17
B = convert_to_float_array(A)
typeof(B)
#--> Array{Float64,2}
```
Use `Base.writedlm` to write XYZ (`lon`,`lat`,`pga/pgv/pgd/psa`) data to text file:
```julia
writedlm("Downloads/xyz.txt", B) # where B is N×3 Array{Float64}
```

## Earthquake location data

Lets define `lat`,`lon`,`depth`,`Ml`,`Mw`:
```julia
eq = Earthquake(143.04,51.92,13,6,5.8)
# OR
eq = Earthquake(143.04,51.92,13,6)
```

Latitude and longitude assumes degrees for WGS84 ellipsoid. Depth in km. `Mw` usually not ready right after earthquake. `Mw=0` in case of moment magnitude is not specified. All gmpe models uses `Mw` if it is or `Ml` otherwise.

## Abrahamson and Silva 2008 GMPE Model
 
### Reference

Abrahamson, Norman, and Walter Silva. "Summary of the Abrahamson & Silva NGA ground-motion relations." Earthquake spectra 24.1 (2008): 67-97.

### PGA:
```julia
## ON GRID
pga_as2008(eq::Earthquake,
           config_as2008::Params_as2008,
           grid::Array{Point_vs30,N},
           min_pga::Number)
## Without grid
pga_as2008(eq::Earthquake,
           config::Params_as2008,
           VS30::Number=350,
           distance::Int64=1000)
```
See `examples/as2008.conf` for instance of AS2008 model parameters.

**The variables that always zero for current version:**

`a12*Frv`, `a13*Fnm`, `a15*Fas`, `Fhw*f4(Rjb,Rrup,Rx,W,S,Ztor,Mw)`, `f6(Ztor)`, `f10(Z1.0, Vs30)`.

Actually they are not presented at code.


## Si and Midorikawa 1999 GMPE Model

### References 

1. Si, Hongjun, and Saburoh Midorikawa. "New attenuation relations for peak ground acceleration and velocity considering effects of fault type and site condition." Proceedings of twelfth world conference on earthquake engineering. 2000.
2. Si H., Midorikawa S. New Attenuation Relationships for Peak Ground Acceleration and Velocity Considering Effects of Fault Type and Site Condition // Journal of Structural and Construction Engineering, A.I.J. 1999. V. 523. P. 63-70, (in Japanese with English abstract).

### PGA:
```julia
## ON GRID
pga_simidorikawa1999(eq::Earthquake,
                     config::Params_simidorikawa1999,
                     grid::Array{Point_vs30,N},
                     min_pga::Number)
## Without grid
pga_simidorikawa1999(eq::Earthquake,
                     config::Params_simidorikawa1999,
                     VS30::Number=350,
                     distance::Int64=1000)
```

See `examples/si-midorikawa-1999.conf` for instance of Si-Midorikawa 1999 model parameters.

## Morikawa and Fujiwara 2013 GMPE Model

### Reference

Morikawa N., Fujiwara H. A New Ground Motion Prediction Equation for Japan Applicable up to M9 Mega-Earthquake // Journal of Disaster Research. 2013. Vol. 5 (8). P. 878–888.

### PGA


### PGV


### PSA

## LICENSE

   Copyright (c) 2018 GEOPHYSTECH LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
