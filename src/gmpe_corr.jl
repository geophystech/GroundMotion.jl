"""
Compute new GMPE PGA/intensity grid using weighted averaging method

**IN**
- `config` configuration of weighted averaging procedure
- `grid` GMPE field modeling by any of `gmpe_*` method
- `intensity_measures` Intensity measures by felt reports or stations
- `intensity_in_pga` is the intensity measures in PGA %g.gg units? Otherwise intensity in SSI is assumes.
- `pga_out` if set to `true` function will return corrected GMPE filed in %g.gg units

**OUT**
Corrected GMPE field in `Array{Point_pga_out}` or `Array{Point_ssi_out}`
"""
function gmpe_corr(
    config::Params_gmpe_corr,
    grid::Array{Point_pga_out},
    intensity_measures::Array{Point_felt_report};
    intensity_in_pga::Bool=true,
    pga_out::Bool=true
)
    if intensity_in_pga # ! Convert to ssi felt reports !
        intensity_measures = convert_from_pga_to_ssi(
            intensity_measures,
            alpha=config.alpha,
            beta=config.beta
        )
    end
    # convert intensity from PGA to SSI for the GMPE field
    grid = convert_from_pga_to_ssi(grid, alpha=config.alpha, beta=config.beta)

    # ! Find closest points to intensity measures on grid !
    # Tuple for 
    # [1] felt report index
    # [2] closest point on grid
    # [3] GMPE value at that point
    # [4] distances from grid points to felt report point
    closes_points_index = Array{
        Tuple{Int,LatLon,Float64,Array{Float64}}
    }(undef, 0)
    for (index, i) in enumerate(intensity_measures)
        current_point = LatLon(i.lat, i.lon)
        distances_from_point = Array{Float64}(undef, 0)
        for j in grid
            grid_point = LatLon(j.lat, j.lon)
            distance_to_point = euclidean_distance(
                current_point, grid_point
            ) / 1000
            push!(distances_from_point, round(distance_to_point, digits=2))
        end
        #push!(closes_points_index,(index,argmin(distances_from_point)))
        min_distance_index = argmin(distances_from_point)
        # @info("index in point $index is $min_distance_index") # debug
        closest_point = LatLon(
            grid[min_distance_index].lat, grid[min_distance_index].lon
        )
        closest_intensity = grid[min_distance_index].ssi
        push!(
            closes_points_index, (
                index, closest_point, closest_intensity, distances_from_point
            )
        )
    end

    # ! Compute correlation variable !
    len_grid = length(grid)
    SIGMA_denominator = fill(0, len_grid)
    SIGMA_numerator = fill(0, len_grid)

    for (index_i, i) in enumerate(intensity_measures)
        # @info("MIN VALUE $(minimum(closes_points_index[index_i][4]))") # debug
        # Initialize correlation with default value
        SIGMA_corr = fill(config.sigma_max, len_grid)
        # Set correlation by condition for distances from current felt report point
        for (index_j, j) in enumerate(closes_points_index[index_i][4]) # [3] stand for distances array
            if j <= config.h_max
                SIGMA_corr[index_j] = config.sigma_gmpe * (
                    1 - exp(-j / config.h_0)
                )
            end
        end
        if i.is_station
            # @info("station detected") # debug
            SIGMA_corr = SIGMA_corr .+ config.sigma_obs_station
        else
            # @info("felt report detected") # debug
            SIGMA_corr = SIGMA_corr .+ config.sigma_obs_felt_report
        end
        # Calculate the term on the right in the denominator
        SIGMA_denominator = SIGMA_denominator .+ (1 ./ SIGMA_corr)
        # Calculate the sum in the denominator
        numerator_sum = i.intensity - closes_points_index[index_i][3] .+ [
            x.ssi for x in grid
        ]
        SIGMA_numerator = SIGMA_numerator .+ numerator_sum ./ SIGMA_corr
    end

    # Final action
    I_CORR = (
        [x.ssi for x in grid] ./ config.sigma_gmpe .+ SIGMA_numerator
    ) ./ (1 / config.sigma_gmpe .+ SIGMA_denominator)

    # Form output
    A = Array{Point_ssi_out}(undef, 0)
    for (index, i) in enumerate(grid)
        push!(A, Point_ssi_out(i.lat, i.lon, round(I_CORR[index], digits=2)))
    end
    if pga_out
        return convert_from_ssi_to_pga(A)
    else
        return A
    end
end
