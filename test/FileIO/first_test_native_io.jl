# save to disk/read from disk
savfile1 = "test.seis"
savfile2 = "test.hdr"
savfile3 = "test.evt"

# Changing this test to guarantee at least one campaign-style measurement
S = randseisdata() + randseisdata(2, c=1.0, s=0.0)[2]
printstyled("    SeisData...\n", color=:light_green)
wseis(savfile1, S)
R = rseis(savfile1)
@test(R[1]==S)

printstyled("    SeisHdr...\n", color=:light_green)
H = randseishdr()
wseis(savfile2, H)
H2 = rseis(savfile2)[1]
@test(H==H2)

printstyled("    SeisEvent...\n", color=:light_green)
EV = SeisEvent(hdr=H, data=S)
wseis(savfile3, EV)

printstyled("    ...a more complicated write involving each type...\n", color=:light_green)
Ch = randseischannel()
wseis(savfile3, EV, S, H, Ch)

E2 = rseis(savfile3)
@test(E2[1]==EV)
@test(E2[2]==S)
@test(E2[3]==H)
@test(E2[4][1]==Ch)

rm(savfile1)
rm(savfile2)
rm(savfile3)

# test each allowed value type in :misc dictionaries
printstyled("    ...accurate r/w of Types allowed as :misc vals...\n", color=:light_green)
D = Dict{String,Any}()
D["0"] = 'c'
D["1"] = randstring(rand(51:100))
D["16"] = rand(UInt8)
D["17"] = rand(UInt16)
D["18"] = rand(UInt32)
D["19"] = rand(UInt64)
D["20"] = rand(UInt128)
D["32"] = rand(Int8)
D["33"] = rand(Int16)
D["34"] = rand(Int32)
D["35"] = rand(Int64)
D["36"] = rand(Int128)
D["48"] = rand(Float16)
D["49"] = rand(Float32)
D["50"] = rand(Float64)
D["80"] = rand(Complex{UInt8})
D["81"] = rand(Complex{UInt16})
D["82"] = rand(Complex{UInt32})
D["83"] = rand(Complex{UInt64})
D["84"] = rand(Complex{UInt128})
D["96"] = rand(Complex{Int8})
D["97"] = rand(Complex{Int16})
D["98"] = rand(Complex{Int32})
D["99"] = rand(Complex{Int64})
D["100"] = rand(Complex{Int128})
D["112"] = rand(Complex{Float16})
D["113"] = rand(Complex{Float32})
D["114"] = rand(Complex{Float64})
D["128"] = collect(rand(Char, rand(4:24)))
D["129"] = collect(Main.Base.Iterators.repeated(randstring(rand(4:24)), rand(4:24)))
D["144"] = collect(rand(UInt8, rand(4:24)))
D["145"] = collect(rand(UInt16, rand(4:24)))
D["146"] = collect(rand(UInt32, rand(4:24)))
D["147"] = collect(rand(UInt64, rand(4:24)))
D["148"] = collect(rand(UInt128, rand(4:24)))
D["160"] = collect(rand(Int8, rand(4:24)))
D["161"] = collect(rand(Int16, rand(4:24)))
D["162"] = collect(rand(Int32, rand(4:24)))
D["163"] = collect(rand(Int64, rand(4:24)))
D["164"] = collect(rand(Int128, rand(4:24)))
D["176"] = collect(rand(Float16, rand(4:24)))
D["177"] = collect(rand(Float32, rand(4:24)))
D["178"] = collect(rand(Float64, rand(4:24)))
D["208"] = collect(rand(Complex{UInt8}, rand(4:24)))
D["209"] = collect(rand(Complex{UInt16}, rand(4:24)))
D["210"] = collect(rand(Complex{UInt32}, rand(4:24)))
D["211"] = collect(rand(Complex{UInt64}, rand(4:24)))
D["212"] = collect(rand(Complex{UInt128}, rand(4:24)))
D["224"] = collect(rand(Complex{Int8}, rand(4:24)))
D["225"] = collect(rand(Complex{Int16}, rand(4:24)))
D["226"] = collect(rand(Complex{Int32}, rand(4:24)))
D["227"] = collect(rand(Complex{Int64}, rand(4:24)))
D["228"] = collect(rand(Complex{Int128}, rand(4:24)))
D["240"] = collect(rand(Complex{Float16}, rand(4:24)))
D["241"] = collect(rand(Complex{Float32}, rand(4:24)))
D["242"] = collect(rand(Complex{Float64}, rand(4:24)))

io = open("crapfile.bin","w")
SeisIO.write_misc(io, D)
close(io)

io = open("crapfile.bin","r")
DD = SeisIO.read_misc(io)
close(io)

[@test(D[k]==DD[k]) for k in sort(collect(keys(D)))]

rm("crapfile.bin")

printstyled("Supported file format IO\n", color=:light_green, bold=true)