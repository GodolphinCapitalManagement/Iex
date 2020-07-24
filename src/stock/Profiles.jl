# Stocks/Profiles
import Iex.Connect: status

include("Utils.jl")

"""
    profile(conn::Connection, symbol::String)

Get company profile
"""
function company(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "company", path_params)
end


"""
    insider_roster(conn::Connection, symbol::String)

Returns the top 10 insiders, with the most recent information.
"""
function insider_roster(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "insider-roster", path_params)
end


"""
    insider_summary(conn::Connection, symbol::String)

Returns aggregated insiders summary data for the last 6 months.
"""
function insider_summary(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "insider-summary", path_params)
end


"""
    insider_transactions(conn::Connection, symbol::String)

Returns insider transactions.
"""
function insider_transactions(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "insider_transactions", path_params)
end


"""
    logo(conn::Connection, symbol::String)

Get company logo
"""
function logo(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "logo", path_params)
end


"""
    peers(conn::Connection, symbol::String)

Get company peer group
"""
function peers(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "peers", path_params)
end


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
    news(conn::Connection, symbol::String; last::Int=10

Provides intraday news from over 3,000 global news sources including major
publications, regional media, and social.. This endpoint returns up to the last
50 articles. Use the [historical news](https://iexcloud.io/docs/api/#historical-news)
endpoint to fetch news as far back as January 2019

Path Parameters:
|Option|Description
|:-----|:----------
|symbol|A stock symbol
|last  |Number between 1 and 50. Default is 10
"""
function news(conn::Connection, symbol::String; last::Int=10)
    path_params = Dict("symbol" => symbol, "last" => max(1, min(50, last)))
    return get_stocks(conn, "news", path_params)
end
