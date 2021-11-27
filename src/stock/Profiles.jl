# Stocks/Profiles

"""
    profile(conn::Connection, symbol::String)

Get company profile
"""
function company(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "company", path_params; symbol = symbol)
end


"""
    insider_roster(conn::Connection, symbol::String)

Returns the top 10 insiders, with the most recent information.
"""
function insider_roster(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "insider-roster", path_params; symbol = symbol)
end


"""
    insider_summary(conn::Connection, symbol::String)

Returns aggregated insiders summary data for the last 6 months.
"""
function insider_summary(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "insider-summary", path_params; symbol = symbol)
end


"""
    insider_transactions(conn::Connection, symbol::String)

Returns insider transactions.
"""
function insider_transactions(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "insider_transactions", path_params; symbol = symbol)
end


"""
    logo(conn::Connection, symbol::String)

Get company logo
"""
function logo(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "logo", path_params; symbol = symbol)
end


"""
    peers(conn::Connection, symbol::String)

Get company peer group
"""
function peers(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "peers", path_params; symbol = symbol)
end
