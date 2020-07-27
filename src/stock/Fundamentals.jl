
# Stocks/Fundamentals
import Iex.Connect: status

include("Utils.jl")

"""
    balance_sheet(conn::Connection, symbol::String; period::String="quarter",
        last::Int=1)

Pulls balance sheet data. Available quarterly
or annually with the default being the last available quarter.
"""
function balance_sheet(
    conn::Connection,
    symbol::String;
    period::String = "quarter",
    last::Int = 1,
)
    path_params = Dict("symbol" => symbol)
    query_params = Dict("period" => period, "last" => last)
    return get_stocks(
        conn,
        "balance-sheet",
        path_params;
        query_params = query_params,
    )
end


"""
    cashflow(conn::Connection, symbol::String; period::String="quarter",
        last::Int=get_iex1)

Pulls cash flow data. Available quarterly
    or annually, with the default being the last available quarter.
"""
function cashflow(
    conn::Connection,
    symbol::String;
    period::String = "quarter",
    last::Int = 1,
)
    path_params = Dict("symbol" => symbol)
    query_params = Dict("period" => period, "last" => last)
    return get_stocks(
        conn,
        "cash-flow",
        path_params;
        query_params = query_params,
    )
end



"""
    dividends(conn::Connection, symbol::String; daterange::String="1m")

Provides basic dividend data for US equities, ETFs,
and Mutual Funds for the last 5 years. For 13+ years
of history and comprehensive data, use the
[Advanced Dividends](https://iexcloud.io/docs/api/#dividends)
endpoint.
"""
function dividends(conn::Connection, symbol::String; daterange::String = "1m")
    path_params = Dict("symbol" => symbol, "range" => daterange)
    return get_stocks(conn, "dividends", path_params)
end


"""
    earnings(conn::Connection, symbol::String; period::String="quarter",
        field::String="actualEPS", last::Int=1)

Earnings data for a given company including the actual EPS,
consensus, and fiscal period. Earnings are available quarterly
(last 4 quarters) and annually (last 4 years).
"""
function earnings(
    conn::Connection,
    symbol::String;
    period::String = "quarter",
    field::String = "actualEPS",
    last::Int = 1,
)
    path_params = Dict("symbol" => symbol, "last" => last, "field" => field)
    query_params = Dict("last" => last, "period" => period)
    return get_stocks(
        conn,
        "earnings",
        path_params;
        query_params = query_params,
    )
end


"""
    income(conn::Connection, symbol::String; period::String="quarter",
        last::Int=1)

Earnings data for a given company including the actual EPS,
consensus, and fiscal period. Earnings are available quarterly
(last 4 quarters) and annually (last 4 years).
"""
function income(
    conn::Connection,
    symbol::String;
    period::String = "quarter",
    last::Int = 1,
)
    path_params = Dict("symbol" => symbol)
    query_params = Dict("period" => period, "last" => last)
    return get_stocks(
        conn,
        "financials",
        path_params;
        query_params = query_params,
    )
end


"""
    splits(conn::Connection, symbol::String; daterange="1m")

Return split information about symbol. Response attributes are:

| Key          | Type   | Description                                                                                                                                                                                                                                               |
|--------------|--------|--------------------------------------------------|
| exDate       | string | refers to the split ex-date                                                                                                                                                                                                                               |
| declaredDate | string | refers to the split declaration date                                                                                                                                                                                                                      |
| ratio        | number | refers to the split ratio.  The split ratio is an 
|              |        | inverse of the  number of shares that a holder of 
|              |        | the stock would have after the split  divided by the
|              |        | number of shares that the holder had before.    
|              |        | For example:  Split ratio of .5 = 2 for 1 split.
| toFactor     | string | To factor of the split. Used to calculate the split 
|              |        | ratio fromfactor/tofactor = ratio (eg ½ = 0.5)                                                                                                                                                        |
| fromFactor   | string | From factor of the split. Used to calculate the split 
|              |        | ratio fromfactor/tofactor = ratio (eg ½ = 0.5)                                                                                                                                                      |
| description  | string | Description of the split event.                                                                                                                                                                                                                           |

"""
function splits(conn::Connection, symbol::String; daterange="next")
    path_params = Dict("symbol" => symbol, "range" => daterange)
    return get_stocks(conn, "splits", path_params)
end