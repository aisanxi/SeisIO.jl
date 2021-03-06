function del_flagged!(S::SeisData, dflag::BitArray{1}, reason::String)
  d = findall(dflag)
  L = length(d)
  if L > 0
    @warn(string("Deleting (", reason, ")"), S.id[d])
    deleteat!(S, d)
  end
  return nothing
end

function autotuk!(x::Array{Float64,1}, v::Array{Int64,1}, u::Int)
  g = findall(diff(v) .> 1)
  L = length(g)
  y = Array{Float64,1}(undef,0)
  if L > 0
    pushfirst!(g, 0)
    push!(g, length(x))
    for i = 1:length(g)-1
      j = g[i]+1
      k = g[i+1]
      N = k-j+1
      resize!(y, N)
      unsafe_copyto!(y, 1, x, j, N)
      μ = mean(y)
      # x[j:k] = ((y.-μ).*tukey(N, u/N)).+μ # necessary if mean is not 0
      broadcast!(-, y, y, μ)
      T = tukey(N, N > u ? u/N : 0.5)
      broadcast!(*, y, y, tukey(N, u/N))
      broadcast!(+, y, y, μ)
      unsafe_copyto!(x, j, y, 1, N)
      # else
      #   x[j:k] .*= tukey(N, 0.5)
      #   @warn(string("segment too small: x[", j, ":", k, "] was Hanning windowed."))
      # end
    end
  end
  return x
end
