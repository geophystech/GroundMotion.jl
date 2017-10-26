## read VS30 file
function read_vs30_file(filename::String)
  A = readdlm(filename)
  vs30_row_num = length(A[:,1])
  B = Array{Point_vs30}(0)
  for i=1:vs30_row_num
    B = push!(B,Point_vs30(A[i,1],A[i,2],A[i,3]))
  end
  return B
end

## convert Array{Point_gmpe_out}(N,1) array to Array{Float64}(N,4)
"""
convert_to_float_array(B::Array{T,N})
  where T is Point_gmpe_out, Point_vs30

  Convert 1-d array of custom type to Array{Float64}(N,X)
"""
function convert_to_float_array(B::Array{Point_gmpe_out})
  A = Array{Float64}(length(B),4)
  for i=1:length(B)
   A[i,1] = B[i].lon
   A[i,2] = B[i].lat
   A[i,3] = B[i].r_rup
   A[i,4] = B[i].g
  end
  return A
end
convert_to_float_array(B::Array{Point_vs30}) = 
begin
  A = Array{Float64}(length(B),3)
  for i=1:length(B)
   A[i,1] = B[i].lon
   A[i,2] = B[i].lat
   A[i,3] = B[i].vs30
  end
return A
end

