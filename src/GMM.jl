module GMM
  # This source contains a module settings. Please find types and functions in nested source files (see include).

  # The distance() function is used, see https://github.com/JuliaGeo/Geodesy.jl for further read
  using Geodesy

  # read/write functions
  include("auxiliary.jl")
  # Types
  include("types.jl")
  # AS2008 PGA modeling
  include("as2008.jl")

end

