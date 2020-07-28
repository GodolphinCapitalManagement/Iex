using Iex
using Test

#  using tokens in API examples on iexcloud.io
@testset "Iex.jl" begin
    include("Profiles_test.jl")
    include("Prices_test.jl")
end
