export distaz!

# =============================================================
# Utility functions
sa_prune!(S::Union{Array{String,1},Array{SubString{String},1}}) = (deleteat!(S, findall(isempty, S)); return S)
get_phase_start(Pha::Array{String,2}) = Float64(findmin([Meta.parse(i) for i in Pha[:,4]]))
get_phase_end(Pha::Array{String,2}) = Float64(findmax([Meta.parse(i) for i in Pha[:,4]]))

function get_phase_time(pha::String, Pha::Array{String,2})
    j = findall(Pha[:,3] .== pha)
    if length(j) == 0
        error(string("Phase ", pha, " not found in phase list!"))
    else
        i = j[1]
        if length(j) > 1
            warn(string("Phase ", pha, " appears multiple times in phase list! Only using first occurrence in phase list."))
        end
        return Float64(Meta.parse(Pha[j[1], 4]))
    end
end

function next_phase(pha::String, Pha::Array{String,2})
  s = Pha[:,3]
  t = map(Float64, [Meta.parse(i) for i in Pha[:,4]])
  j = findall(s.==pha)[1]
  i = t .- t[j] .> 0
  tt = t[i]
  ss = s[i]
  k = sortperm(tt .- t[j])[1]
  return(ss[k], tt[k])
end

function next_converted(pha::String, Pha::Array{String,2})
  s = Pha[:,3]
  t = map(Float64, [Meta.parse(i) for i in Pha[:,4]])
  j = findall(s.==pha)[1]

  p = replace(lowercase(s[j]),"diff" => "")[end]
  if p == 'p'
    c = 's'
  else
    c = 'p'
  end
  p_bool = [replace(lowercase(a),"diff" => "")[end]==c for a in s]
  t_bool = t.-t[j].>0
  i = t_bool.*p_bool

  tt = t[i]
  ss = s[i]
  k = sortperm(tt.-t[j])[1]
  return(ss[k],tt[k])
end
