# GroundMoution.jl
The ground motion evaluation module

**WORK IN PROGRESS**

## How to get VS30 grid

1. Download GMT grd file from [USGS Vs30 Models and Data page](https://earthquake.usgs.gov/data/vs30/)
2. Unzip it. It takes around 2,7G disk space for one file: 
```
unzip global_vs30_grd.zip
...
ls -lh global_vs30.grd
-rw-r--r--  1 jamm  staff   2,7G  8 сен  2016 global_vs30.grd
```
3. Use `GMT2XYZ` [man page](https://www.soest.hawaii.edu/gmt/gmt/html/man/grd2xyz.html) from [GMT](https://www.soest.hawaii.edu/gmt/) to convert grd data to XYZ text file:
```
# example:
grd2xyz global_vs30.grd -R145.0/146.0/50.0/51.0 > test_sea.txt
# number of rows:
cat test_sea.txt |wc -l
   14641
```

## Read and Write data grids

Use `read_vs30_file` to read data from vs30 file:
```
grid = read_vs30_file("Downloads/web/somevs30.txt")
```
After some `gpmpe_*` function done, you will get `Array{Point_gmpe_out,N}`. Use `convert_to_float_array` to convert `Array{Point_gmpe_out,N}` to `Array{Float64,N}`:
```
typeof(A)
#--> Array{GroundMoution.Point_gmpe_out,1}
length(A)
#--> 17
B = convert_to_float_array(A)
typeof(B)
#--> Array{Float64,2}
```
Use `Base.writedlm` to write XYZ (lon,lat,g) data to text file:
```
writedlm("Downloads/xyz.txt", B) # where B is N×3 Array{Float64,2}
```

## Earthquake location data

Lets define lat(wgs84),lon(wgs84),depth(km),Ml,Mw:
```
eq = Earthquake(143.04,51.92,13,6,5.8)
# OR
eq = Earthquake(143.04,51.92,13,6)
```

Mw usually not ready right after earthquake. Mw=0 in case of moment magnitude is not specified. All gmpe models uses Mw if it is or Ml otherwise.

## AS2008 GMPE Model

Abrahamson, Norman, and Walter Silva. "Summary of the Abrahamson & Silva NGA ground-motion relations." Earthquake spectra 24.1 (2008): 67-97.

**The variables that always zero for current version:**

`a12*Frv`, `a13*Fnm`, `a15*Fas`, `Fhw*f4(Rjb,Rrup,Rx,W,S,Ztor,Mw)`, `f6(Ztor)`, `f10(Z1.0, Vs30)`.

Actually they are not presented at code.

Short example:
```julia
# init model parameters
include("GroundMoution.jl/examples/as2008.conf")
# load vs30 grid
grid = read_vs30_file("Downloads/web/testvs30.txt")
# set earthquake location
eq = Earthquake(143.04,51.92,13,6)
# run AS2008 modeling
gmpe_as2008(eq,grid,config_as2008,0.1)
```
