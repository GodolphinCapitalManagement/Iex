using Iex
using Test


@testset "Iex.jl" begin
    ENV["IEX_SANDBOX_KEY"] = "Tpk_6bb49ecaaecf4cbc97c5e83e8771c353"
    include("Profiles_test.jl")
    include("Prices_test.jl")
end
