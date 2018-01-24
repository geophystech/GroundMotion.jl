# GroundMotion.jl
The ground motion evaluation module

## Install and solve dependencies

```julia
Pkg.add("Geodesy")
```

**WORK IN PROGRESS**

## Basic principles

The names of GMPE functions specified type of returned values: `{pga/pgv/pgd}_{Name_of_gmpe}`. 

For example: `pga_as2008`, where `pga` is type of ground motion and `as2008` is AS2008 GMPE Model. The same logic for `PGV,PGD`.

Each GMPE function has at least 2 methods: for calculation on the VS30 grid and simulation (for plotting etc). The module has custom types for store output grid data (PGA,PGV,PGD).

For example: function `pga_as2008` with parameters
```julia
pga_as2008(eq::Earthquake,
           grid::Array{Point_vs30,N},
           config_as2008::Params_as2008,
           min_pga::Number)
```
will return  `Array{Point_pga_out,N}` with points where `g > min_pga` (`g` is Acceleration of gravity in percent rounded to `ggg.gg`)

and for
```julia
pga_as2008(eq::Earthquake,
           config::Params_as2008,
           VS30::Number=350,
           distance::Int64=1000)
```
Output will be `Array{Float64,1}` with `1:distance` values of `g` (also rounded to `ggg.gg`).

## Short example:
```julia
# init model parameters
include("GroundMoution.jl/examples/as2008.conf")
# load vs30 grid
grid = read_vs30_file("Downloads/web/testvs30.txt")
# set earthquake location
eq = Earthquake(143.04,51.92,13,6)
# run AS2008 PGA modeling on GRID
out_grid = pga_as2008(eq,grid,config_as2008,0.1)
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
After some `pga_*`,`pgv_*`,`pgd_*` function done, you will get `Array{Point_{pga,pgv,pgd}_out,N}`. Use `convert_to_float_array` to convert `Array{Point_{pga,pgv,pgd}_out,N}` to `Array{Float64,N}`:
```julia
typeof(A)
#--> Array{GroundMoution.Point_pga_out,1}
length(A)
#--> 17
B = convert_to_float_array(A)
typeof(B)
#--> Array{Float64,2}
```
Use `Base.writedlm` to write XYZ (`lon`,`lat`,`g/v/d`) data to text file:
```julia
writedlm("Downloads/xyz.txt", B) # where B is N×3 Array{Float64,2}
```

## Earthquake location data

Lets define `lat`,`lon`,`depth`,`Ml`,`Mw`:
```julia
eq = Earthquake(143.04,51.92,13,6,5.8)
# OR
eq = Earthquake(143.04,51.92,13,6)
```

Latitude and longitude assumes degrees for WGS84 ellipsoid. Depth in km. Mw usually not ready right after earthquake. Mw=0 in case of moment magnitude is not specified. All gmpe models uses Mw if it is or Ml otherwise.

## AS2008 GMPE Model

Abrahamson, Norman, and Walter Silva. "Summary of the Abrahamson & Silva NGA ground-motion relations." Earthquake spectra 24.1 (2008): 67-97.

### PGA:
```
pga_as2008(eq::Earthquake,grid::Array{Point_vs30,N},config_as2008::Params_as2008,min_pga::Number)
pga_as2008(eq::Earthquake,config::Params_as2008,VS30::Number=350,distance::Int64=1000)
```
See `examples/as2008.conf` for instance of AS2008 model parameters.

**The variables that always zero for current version:**

`a12*Frv`, `a13*Fnm`, `a15*Fas`, `Fhw*f4(Rjb,Rrup,Rx,W,S,Ztor,Mw)`, `f6(Ztor)`, `f10(Z1.0, Vs30)`.

Actually they are not presented at code.


## Si-Midorikawa 1999 GMPE Model

1. Si, Hongjun, and Saburoh Midorikawa. "New attenuation relations for peak ground acceleration and velocity considering effects of fault type and site condition." Proceedings of twelfth world conference on earthquake engineering. 2000.
2. Si H., Midorikawa S. New Attenuation Relationships for Peak Ground Acceleration and Velocity Considering Effects of Fault Type and Site Condition // Journal of Structural and Construction Engineering, A.I.J. 1999. V. 523. P. 63-70, (in Japanese with English abstract).

### PGA:
```
pga_simidorikawa1999(eq::Earthquake,grid::Array{Point_vs30,N},config::Params_simidorikawa1999,min_pga::Number)
pga_simidorikawa1999(eq::Earthquake,config::Params_simidorikawa1999,VS30::Number=350,distance::Int64=1000)
```

See `examples/si-midorikawa-1999.conf` for instance of Si-Midorikawa 1999 model parameters.

## LICENSE

   Copyright 2018 GEOPHYSTECH LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
