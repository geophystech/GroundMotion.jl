module GMM

  # The distance() function is used, see https://github.com/JuliaGeo/Geodesy.jl for further read
  using Geodesy

  #****************
  #*    TYPES     *
  #****************


  #****************
  #*  FUNCTIONS   *
  #****************
  ## read VS30 file
  function read_vs30_file(filename::String)
    @time A = readdlm(filename)
    vs30_row_num = length(A[:,1])
    @time B = Array{Point_vs30}(0)
    @time for i=1:vs30_row_num
      B = push!(B,Point_vs30(A[i,1],A[i,2],A[i,3]))
    end
    return B
  end

  include("types.jl")
  include("as2008.jl")

end #module

