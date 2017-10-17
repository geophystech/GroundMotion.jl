# gmm.jl
The ground motion evaluation module

**WORK IN PROGRESS**

## How to get VS30 grid

1. Download GMT grd file from [USGS Vs30 Models and Data page](https://earthquake.usgs.gov/data/vs30/)
2. Unzip `unzip global_vs30_grd.zip`. It take around 2,7G disk space for one file: `2,7G  8 сен  2016 global_vs30.grd`.
3. Using `GMT2XYZ` [man page](https://www.soest.hawaii.edu/gmt/gmt/html/man/grd2xyz.html) from [GMT](https://www.soest.hawaii.edu/gmt/) to convert grd data to XYZ test file:
```
# example:
grd2xyz global_vs30.grd -R145.0/146.0/50.0/51.0 > test_sea.txt
# number of rows:
cat test_sea.txt |wc -l
   14641
```


