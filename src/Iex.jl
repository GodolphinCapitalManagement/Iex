# Iex
__precompile__()
module Iex

function __init__()
    if !haskey(ENV, "IEX_SANDBOX_API_KEY")
        @warn "No IEX SANDBOX API key found"
    end
end

# Global Connection object
mutable struct Connection
    url::String
    version::String
    token::String
end


"""
    init_connection(;url::String = "",version::String="",token::String="")

initializes IEX connection parameters
"""
function init_connection(;
    url::String = "",
    version::String = "",
    token::String = "",
)
    Connection(url, version, token)
end


"""
    set_connection_url!(conn::Connection, url::String)

Modifies url for connection object conn
"""
function set_connection_url!(conn::Connection, url::String)
    conn.url = url
end


"""
    set_connection_version!(conn::Connection, version::String)

Modifies version for connection object conn
"""
function set_connection_version!(conn::Connection, version::String)
    conn.version = version
end


"""
    set_connection_token!(conn::Connection, token::String)

Modifies url for connection object conn
"""
function set_connection_token!(conn::Connection, token::String)
    conn.token = token
end


export Connection,
    init_connection,
    set_connection_url!,
    set_connection_version!,
    set_connection_token!


# Connections
include("connection/Connect.jl")

# Utils
include("stock/Utils.jl")

# Accounts
include("account/Account.jl")

# Stocks
include("stock/Prices.jl")
include("stock/Profiles.jl")

# Fundamentals
include("stock/Fundamentals.jl")

# Research
include("stock/Research.jl")

# News
include("stock/News.jl")

# Reference
include("reference/Reference.jl")


export
    # account/Account.jl
    usage,
    metadata,

    # stock/Prices.jl
    history,
    batch,
    book,
    symbol_quote,
    price,
    ohlc,
    largest_trades,
    batched_closes,

    # stock/Profiles.jl
    company,
    insider_roster,
    insider_summary,
    insider_transactions,
    logo,
    peers,

    # stock/Fundamentals.jl
    balance_sheet,
    dividends,
    earnings,
    income,
    split,

    # stock/Research.jl
    stats,

    # stock/News.jl
    news,

    # reference/Reference.jl
    symbols,

    # stock/Utils.jl
    get_stocks


end
