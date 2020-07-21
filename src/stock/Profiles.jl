# Stocks/Profiles
import Iex.Connect: get_stocks, status


"""
    profile(conn::Connection, symbol::String)

Get company profile
"""
function company(conn::Connection, symbol::String)
    return get_stocks(conn, symbol, "company")
end


"""
    insider_roster(conn::Connection, symbol::String)

Returns the top 10 insiders, with the most recent information.
"""
function insider_roster(conn::Connection, symbol::String)
    return get_stocks(conn, symbol, "insider-roster")
end


"""
    insider_summary(conn::Connection, symbol::String)

Returns aggregated insiders summary data for the last 6 months.
"""
function insider_summary(conn::Connection, symbol::String)
    return get_stocks(conn, symbol, "insider-summary")
end


"""
    insider_transactions(conn::Connection, symbol::String)

Returns insider transactions.
"""
function insider_transactions(conn::Connection, symbol::String)
    return get_stocks(conn, symbol, "insider_transactions")
end


"""
    logo(conn::Connection, symbol::String)

Get company logo
"""
function logo(conn::Connection, symbol::String)
    return get_stocks(conn, symbol, "logo")
end


"""
    peers(conn::Connection, symbol::String)

Get company peer group
"""
function peers(conn::Connection, symbol::String)
    return get_stocks(conn, symbol, "peers")
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

    query_params = Dict("period" => period, "last" => last)
    return get_stocks(
        conn,
        symbol,
        "balance-sheet",
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

    query_params = Dict("period" => period, "last" => last)
    return get_stocks(conn, symbol, "cash-flow", query_params = query_params)
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
    path_params = Dict("range" => daterange)
    return get_stocks(conn, symbol, "dividends", path_params = path_params)
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

    path_params = Dict("last" => last, "field" => field)
    query_params = Dict("last" => last, "period" => period)
    return get_stocks(
        conn,
        symbol,
        "earnings",
        path_params = path_params,
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

    query_params = Dict("period" => period, "last" => last)
    return get_stocks(conn, symbol, "financials", query_params = query_params)
end
