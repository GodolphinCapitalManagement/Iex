
using Iex

TEST_SLEEP_TIME = 15.0

price_functions_test = [:history,:price,:book,:symbol_quote]

params = (
    token="Tsk_37cebd73a857428f9e27b4cd3aa1bc4a",
    url="https://sandbox.iexapis.com/",
    version="stable",
)
iex = Connection(;url=params.url, version=params.version,
    token=params.token);


@testset "StockPrices" begin
    for f in price_functions_test
        @eval begin
            testname = string($f)
            @testset "Testing $testname" begin
                data = $f(iex, "AAPL")
                if testname == "history"
                    @test typeof(data) == DataFrame
                    @test size(data) == (21, 13)
                elseif testname == "price"
                    @test typeof(data) == Float64
                    @test length(data) == 1
                elseif testname == "book"
                    @test typeof(data) === Dict{String,Any}
                    @test length(data) === 5
                elseif testname == "symbol_quote"
                    @test typeof(data) === Dict{String,Any}
                    @test length(data) === 55
                end

            end
        end
        sleep(TEST_SLEEP_TIME + 2*rand()) #as to not overload the API
    end

    @testset "Testing get_stocks" begin
        path_params = [:symbol]
        data = Iex.get_stocks(iex, "chart", path_params; symbol = "AAPL")
        @test typeof(data) == Array{Any,1}
        @test length(data) == 21
    end
end
