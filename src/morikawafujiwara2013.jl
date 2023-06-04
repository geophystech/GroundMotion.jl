"""
**ON GRID**

- On grid without Dl data:
```
gmpe_mf2013(
    eq::Earthquake,
    config::Params_mf2013,
    grid::Array{Point_vs30};
    min_val::Number=0,
    Dl::Number=250,
    Xvf::Number=0
)
```

- On grid with Dl data

```
gmpe_mf2013(
    eq::Earthquake,
    config::Params_mf2013,
    grid::Array{Point_vs30_dl};
    min_val::Number=0,
    Xvf::Number=0
)
```

where `min_val=0`, `Xvf=0` [km] by default. `Dl=250` [km] by default in case of
grid pass without `Dl` data.
  
Output will be 1-d `Array{Point_<ground_motion_type>_out}` with points based on
input grid with `ground_motion > min_val` (`pga`,`psa` is Acceleration of
gravity in percent (%g) rounded to ggg.gg, `pgv` in cm/s^2)

**Without grid**
```  
gmpe_as2008(
    eq::Earthquake,
    config::Params_mf2013;
    VS30::Number=350,
    distance::Int64=1000,
    Dl::Number=250,
    Xvf::Number=0
)
```

where `VS30=30` [m/s^2], `distance=1000` [km], `Xvf=0` [km], `Dl=250` [km] by
default.
  
Output will be 1-d `Array{Float64}` with `1:distance` values of `pga`,`psa`
(that is Acceleration of gravity in percent (%g) rounded to ggg.gg) OR pgv
[cm/s].

**EXAMPLES:**

```  
gmpe_mf2013(
    eq,
    config_mf2013,
    grid
) # for PGA,PGV,PSA on GRID

gmpe_mf2013(
    eq,
    config_mf2013
) # for PGA,PGV,PSA without input grid
```

**Model parameters**

Please, see `examples/morikawa-fujiwara-2013.conf`
"""
function gmpe_mf2013(
    eq::Earthquake,
    config::Params_mf2013,
    grid::Array{Point_vs30};
    min_val::Number=0,
    Dl::Number=250,
    Xvf::Number=0
) # Morikawa Fujiwara (2013) PGA,PGV,PSA modeling ON GRID, Dl = constant

    vs30_row_num = length(grid[:, 1])

    eq.moment_mag == 0 ? magnitude = eq.local_mag : magnitude = eq.moment_mag
    magnitude = min(magnitude, config.Mw0)
    epicenter = LatLon(eq.lat, eq.lon)

    g_global = 9.81
    aMw = config.a * magnitude
    Gd = config.pd * log10(max(config.Dlmin, Dl) / config.D0)

    # init output_data
    if config.ground_motion_type == "PGA"
        output_data = Array{Point_pga_out}(undef, 0)
        out_type = Point_pga_out
    elseif config.ground_motion_type == "PGV"
        output_data = Array{Point_pgv_out}(undef, 0)
        out_type = Point_pgv_out
    elseif config.ground_motion_type == "PSA"
        output_data = Array{Point_psa_out}(undef, 0)
        out_type = Point_psa_out
    end

    for i = 1:vs30_row_num
        # rrup the same as X in Morikawa Fujiwara 2013 formulae
        # eq.depth the same as D in Morikawa Fujiwara 2013 formulae
        current_point = LatLon(grid[i].lat, grid[i].lon)
        r_rup = (
            euclidean_distance(current_point, epicenter) / 1000
        )^2 + eq.depth^2 |> sqrt

        log_A = (
            aMw + config.b * r_rup + config.c
        ) - log10(r_rup + config.d * 10^(config.e * magnitude)) # \logA where A in cm/s^2 (pga,psa) or cm/s (pgv)

        log_Agd = log_A + Gd # Amplification by Deep Sedimentary Layers

        Gs = config.ps * log10(min(config.Vsmax, grid[i].vs30) / config.V0) # vs30 amplification
        log_Ags = log_Agd + Gs

        if config.ASID == true
            AI = config.gamma * Xvf * (eq.depth - 30)
            log_AI = log_Ags + AI
            A = 10^(log_AI) # pga and psa in cm/c^2, pgv in cm/s
        else
            A = 10^(log_Ags)
        end

        # output depend on type of motion
        if (
            config.ground_motion_type == "PGA"
        ) || (
            config.ground_motion_type == "PSA"
        )
            motion = round(((A / 100) / g_global * 100), digits=2) ## convert cm/c^2 to %g
        elseif config.ground_motion_type == "PGV"
            motion = A
        end

        if motion >= min_val
            output_data = push!(
                output_data, out_type(grid[i].lon, grid[i].lat, motion)
            )
        end
    end
    return output_data
end

function gmpe_mf2013(
    eq::Earthquake,
    config::Params_mf2013,
    grid::Array{Point_vs30_dl};
    min_val::Number=0,
    Xvf::Number=0
) # Morikawa Fujiwara (2013) PGA,PGV,PSA modeling ON GRID, Dl provided in GRID

    vs30_row_num = length(grid[:, 1])

    eq.moment_mag == 0 ? magnitude = eq.local_mag : magnitude = eq.moment_mag
    magnitude = min(magnitude, config.Mw0)
    epicenter = LatLon(eq.lat, eq.lon)

    g_global = 9.81
    aMw = config.a * magnitude

    # init output_data
    if config.ground_motion_type == "PGA"
        output_data = Array{Point_pga_out}(undef, 0)
        out_type = Point_pga_out
    elseif config.ground_motion_type == "PGV"
        output_data = Array{Point_pgv_out}(undef, 0)
        out_type = Point_pgv_out
    elseif config.ground_motion_type == "PSA"
        output_data = Array{Point_psa_out}(undef, 0)
        out_type = Point_psa_out
    end

    for i = 1:vs30_row_num
        # rrup the same as X in Morikawa Fujiwara 2013 formulae
        # eq.depth the same as D in Morikawa Fujiwara 2013 formulae
        current_point = LatLon(grid[i].lat, grid[i].lon)
        r_rup = (
            euclidean_distance(current_point, epicenter) / 1000
        )^2 + eq.depth^2 |> sqrt

        log_A = (
            aMw + config.b * r_rup + config.c
        ) - log10(r_rup + config.d * 10^(config.e * magnitude)) # \logA where A in cm/s^2 (pga,psa) or cm/s (pgv)

        Gd = config.pd * log10(max(config.Dlmin, grid[i].dl) / config.D0) # Amplification by Deep Sedimentary Layers
        log_Agd = log_A + Gd

        # vs30 amplification
        Gs = config.ps * log10(min(config.Vsmax, grid[i].vs30) / config.V0)
        log_Ags = log_Agd + Gs

        if config.ASID == true
            AI = config.gamma * Xvf * (eq.depth - 30)
            log_AI = log_Ags + AI
            A = 10^(log_AI) # pga and psa in cm/c^2, pgv in cm/s
        else
            A = 10^(log_Ags)
        end

        # output depend on type of motion
        if (
            config.ground_motion_type == "PGA"
        ) || (
            config.ground_motion_type == "PSA"
        )
            motion = round(((A / 100) / g_global * 100), digits=2) ## convert cm/c^2 to %g
        elseif config.ground_motion_type == "PGV"
            motion = A
        end

        if motion >= min_val
            output_data = push!(
                output_data, out_type(grid[i].lon, grid[i].lat, motion)
            )
        end
    end
    return output_data
end

function gmpe_mf2013(
    eq::Earthquake,
    config::Params_mf2013;
    VS30::Number=350,
    distance::Number=1000,
    Dl::Number=250,
    Xvf::Number=0
) # Morikawa Fujiwara (2013) PGA modeling ON GRID, Dl = constant


    eq.moment_mag == 0 ? magnitude = eq.local_mag : magnitude = eq.moment_mag
    magnitude = min(magnitude, config.Mw0)
    g_global = 9.81
    aMw = config.a * magnitude
    Gd = config.pd * log10(max(config.Dlmin, Dl) / config.D0)

    # init output array
    output_data = Array{Float64}(undef, 0)


    for i = 1:distance
        # rrup the same as X in Morikawa Fujiwara 2013 formulae
        # eq.depth the same as D in Morikawa Fujiwara 2013 formulae
        r_rup = sqrt((i)^2 + eq.depth^2)

        log_A = (
            aMw + config.b * r_rup + config.c
        ) - log10(r_rup + config.d * 10^(config.e * magnitude)) # \logA where A in cm/s^2 (pga,psa) or cm/s (pgv)

        log_Agd = log_A + Gd # Amplification by Deep Sedimentary Layers

        Gs = config.ps * log10(min(config.Vsmax, VS30) / config.V0) # vs30 amplification
        log_Ags = log_Agd + Gs

        if config.ASID == true
            AI = config.gamma * Xvf * (eq.depth - 30)
            log_AI = log_Ags + AI
            A = 10^(log_AI) # pga and psa in cm/c^2, pgv in cm/s
        else
            A = 10^(log_Ags)
        end

        # output depend on type of motion
        if (
            config.ground_motion_type == "PGA"
        ) || (
            config.ground_motion_type == "PSA"
        )
            motion = round(((A / 100) / g_global * 100), digits=2) ## convert cm/c^2 to %g
        elseif config.ground_motion_type == "PGV"
            motion = A
        end
        output_data = push!(output_data, motion)
    end
    return output_data
end
