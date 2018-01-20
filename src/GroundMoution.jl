module GroundMoution
  # This source contains a module settings. Please find types and functions in nested source files (see include).

  # The distance() function is used, see https://github.com/JuliaGeo/Geodesy.jl for further read
  using 
    Geodesy

  export
    # types
    Point_vs30,
    Point_gmpe_out,
    Earthquake,
    Params_as2008,
    Params_simidorikawa1999,
    # functions
    read_vs30_file,
    convert_to_float_array,
    gmpe_as2008

  # Types
  include("types.jl")
  # AS2008 PGA modeling
  include("as2008.jl")
  # read/write functions
  include("auxiliary.jl")

end

