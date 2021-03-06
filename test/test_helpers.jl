import Random: rand, randstring
import DelimitedFiles: readdlm
const μs = 1.0e-6
const datafields = [:name, :id, :fs, :gain, :loc, :misc, :notes, :resp, :src, :units, :t, :x]
const hdrfields = [:id, :ot, :loc, :mag, :int, :mt, :np, :pax, :src, :notes, :misc]
const unicode_chars = String.(readdlm("SampleFiles/julia-unicode.csv", '\n')[:,1])
const n_unicode = length(unicode_chars)
const breaking_dict = Dict{String,Any}(
                        "0" => rand(Char),
                        "1" => randstring(rand(51:100)),
                        "16" => rand(UInt8),
                        "17" => rand(UInt16),
                        "18" => rand(UInt32),
                        "19" => rand(UInt64),
                        "20" => rand(UInt128),
                        "32" => rand(Int8),
                        "33" => rand(Int16),
                        "34" => rand(Int32),
                        "35" => rand(Int64),
                        "36" => rand(Int128),
                        "48" => rand(Float16),
                        "49" => rand(Float32),
                        "50" => rand(Float64),
                        "80" => rand(Complex{UInt8}),
                        "81" => rand(Complex{UInt16}),
                        "82" => rand(Complex{UInt32}),
                        "83" => rand(Complex{UInt64}),
                        "84" => rand(Complex{UInt128}),
                        "96" => rand(Complex{Int8}),
                        "97" => rand(Complex{Int16}),
                        "98" => rand(Complex{Int32}),
                        "99" => rand(Complex{Int64}),
                        "100" => rand(Complex{Int128}),
                        "112" => rand(Complex{Float16}),
                        "113" => rand(Complex{Float32}),
                        "114" => rand(Complex{Float64}),
                        "128" => collect(rand(Char, rand(4:24))),
                        "129" => [randstring(rand(4:24)) for i=1:rand(4:24)],
                        "144" => collect(rand(UInt8, rand(4:24))),
                        "145" => collect(rand(UInt16, rand(4:24))),
                        "146" => collect(rand(UInt32, rand(4:24))),
                        "147" => collect(rand(UInt64, rand(4:24))),
                        "148" => collect(rand(UInt128, rand(4:24))),
                        "160" => collect(rand(Int8, rand(4:24))),
                        "161" => collect(rand(Int16, rand(4:24))),
                        "162" => collect(rand(Int32, rand(4:24))),
                        "163" => collect(rand(Int64, rand(4:24))),
                        "164" => collect(rand(Int128, rand(4:24))),
                        "176" => collect(rand(Float16, rand(4:24))),
                        "177" => collect(rand(Float32, rand(4:24))),
                        "178" => collect(rand(Float64, rand(4:24))),
                        "208" => collect(rand(Complex{UInt8}, rand(4:24))),
                        "209" => collect(rand(Complex{UInt16}, rand(4:24))),
                        "210" => collect(rand(Complex{UInt32}, rand(4:24))),
                        "211" => collect(rand(Complex{UInt64}, rand(4:24))),
                        "212" => collect(rand(Complex{UInt128}, rand(4:24))),
                        "224" => collect(rand(Complex{Int8}, rand(4:24))),
                        "225" => collect(rand(Complex{Int16}, rand(4:24))),
                        "226" => collect(rand(Complex{Int32}, rand(4:24))),
                        "227" => collect(rand(Complex{Int64}, rand(4:24))),
                        "228" => collect(rand(Complex{Int128}, rand(4:24))),
                        "240" => collect(rand(Complex{Float16}, rand(4:24))),
                        "241" => collect(rand(Complex{Float32}, rand(4:24))),
                        "242" => collect(rand(Complex{Float64}, rand(4:24)))
                        )

test_fields_preserved(S1::SeisData, S2::SeisData, x::Int, y::Int) =
  @test(minimum([getfield(S1,f)[x]==getfield(S2,f)[y] for f in datafields]))
test_fields_preserved(S1::SeisChannel, S2::SeisData, y::Int) =
  @test(minimum([getfield(S1,f)==getfield(S2,f)[y] for f in datafields]))

function sizetest(S::SeisData, nt::Int)
  @test ≈(S.n, nt)
  @test ≈(maximum([length(getfield(S,i)) for i in datafields]), nt)
  @test ≈(minimum([length(getfield(S,i)) for i in datafields]), nt)
  return nothing
end

function mktestseis()
  L0 = 30
  L1 = 10
  os = 5
  tt = time()
  t1 = round(Int64, tt/μs)
  t2 = round(Int64, (L0+os)/μs) + t1

  S = SeisData(5)
  S.name = ["Channel 1", "Channel 2", "Channel 3", "Channel 4", "Channel 5"]
  S.id = ["XX.TMP01.00.BHZ","XX.TMP01.00.BHN","XX.TMP01.00.BHE","CC.LON..BHZ","UW.SEP..EHZ"]
  S.fs = collect(Main.Base.Iterators.repeated(100.0, S.n))
  S.fs[4] = 20.0
  for i = 1:S.n
    os1 = round(Int64, 1/(S.fs[i]*μs))
    S.x[i] = randn(Int(L0*S.fs[i]))
    S.t[i] = [1 t1+os1; length(S.x[i]) 0]
  end

  T = SeisData(4)
  T.name = ["Channel 6", "Channel 7", "Channel 8", "Channel 9"]
  T.id = ["XX.TMP02.00.EHZ","XX.TMP03.00.EHN","CC.LON..BHZ","UW.SEP..EHZ"]
  T.fs = collect(Main.Base.Iterators.repeated(100.0, T.n))
  T.fs[3] = 20.0
  for i = 1:T.n
    T.x[i] = randn(Int(L1*T.fs[i]))
    T.t[i] = [1 t2; length(T.x[i]) 0]
  end
  return (S,T)
end

function remove_low_gain!(S::SeisData)
    # Remove low-gain seismic data channels
    i_low = findall([occursin(r".EL?", S.id[i]) for i=1:S.n])
    if !isempty(i_low)
        for k = length(i_low):-1:1
            @warn(join(["Low-gain, low-fs channel removed: ", S.id[i_low[k]]]))
            S -= S.id[i_low[k]]
        end
    end
    return nothing
end

# Test that data are time synched correctly within a SeisData structure
function sync_test!(S::SeisData)
    local L = [length(S.x[i])/S.fs[i] for i = 1:S.n]
    local t = [S.t[i][1,2] for i = 1:S.n]
    @test maximum(L) - minimum(L) ≤ maximum(2.0./S.fs)
    @test maximum(t) - minimum(t) ≤ maximum(2.0./S.fs)
    return nothing
end

function breaking_seis()
  S = SeisData(randSeisData(), randSeisEvent(), randSeisData(2, c=1.0, s=0.0)[2])

  # Test a channel with every possible dict type
  S.misc[1] = breaking_dict

  # Test a channel with no notes
  S.notes[1] = []

  # Need a channel with a very long name to test in show.jl
  S.name[1] = "The quick brown fox jumped over the lazy dog"

  #= Here we test true, full Unicode support;
    only 0xff can be a separator in S.notes[2] =#
  S.notes[2] = Array{String,1}(undef,6)
  S.notes[2][1] = String(Char.(0x00:0xfe))
  for i = 2:1:6
    uj = randperm(rand(1:n_unicode))
    S.notes[2][i] = join(unicode_chars[uj])
  end

  # Test short data, loc arrays
  S.loc[3] = rand(Float64,3)
  S.x[4] = rand(Float64,4)
  S.t[4] = vcat(S.t[4][1:1,:], [4 0])
  return S
end
