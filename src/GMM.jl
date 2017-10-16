Module GMM

	# The distance() function is used, see https://github.com/JuliaGeo/Geodesy.jl for further read
	using Geodesy

	# define types
	## VS30 data point
	mutable struct vs30_point
		lat::Float64
		lon::Float64
		VS30::Float64
	end
	## earthquake location data
	mutable struct earthquake
		lat::Float64
		lon::Float64
		depth::Float64
		local_mag::Float64
		moment_mag::Float64
	end
	## AS2008 GMPE paramaters
	mutable struct as2008_params
		a1::Float64
  	a2::Float64
  	a3::Float64
  	a4::Float64
  	a5::Float64
  	a8::Float64
  	a10::Float64
  	a18::Float64
  	b::Float64
  	c::Float64
  	c1::Float64
  	c4::Float64
  	n::Float64
  	vlin::Float64
		v1::Float64
		vs30_1100::Float64
		t6::Float64
	end
	## AS2008 GMPE data point
	mutable struct as2008_point
		lat::Float64
		lon::Float64
		vs30::Float64
		r_rup::Float64
		f1::Float64
		f5::Float64
		f8::Float64
		pga1100::Float64
		g::Float64 # Acceleration of gravity in fractions
	end



end #module
