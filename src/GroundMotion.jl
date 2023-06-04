module GroundMotion

using
    DelimitedFiles,
    Geodesy

export Point_vs30, Point_pga_out, Point_ssi_out, Point_felt_report, Earthquake,
    Params_as2008, Params_simidorikawa1999, Params_mf2013, Params_gmpe_corr,
    read_vs30_file, read_intensity_file, read_pga_file,
    convert_to_point_vs30, convert_from_pga_to_ssi, convert_from_ssi_to_pga,
    read_vs30_dl_file, convert_to_float_array, gmpe_as2008,
    gmpe_simidorikawa1999, gmpe_mf2013, gmpe_corr

include("types.jl")
include("as2008.jl")
include("simidorikawa1999.jl")
include("morikawafujiwara2013.jl")
include("auxiliary.jl")
include("gmpe_corr.jl")
end

