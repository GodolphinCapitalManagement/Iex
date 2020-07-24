using Iex
using Test

@testset "Iex.jl" begin
    include("Profiles_test.jl")
    include("Prices_test.jl")
end
