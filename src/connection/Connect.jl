# Connect
module Connect

import HTTP: request, escapeuri
import JSON: parse

using Iex

export get_stocks, status

"""
    Connection

Fields:
    url::String
    version::String
    token::String
"""


"""
    status(conn::Connection)

Get status for IEX connection
"""
function status(conn::Connection)
    url = conn.url * conn.version * "/status"
    r = request("GET", url;)
    return parse(String(r.body))
end


"""
    get_stocks(conn::Connection, endpoint::String; path_params=Dict(),
        query_params=Dict())

Get stock prices in various formats
"""
function get_stocks(
    conn::Connection,
    endpoint::String,
    path_params::Dict;
    query_params::Dict = Dict(),
)

    try
        path_params["symbol"]
    catch error
        if isa(error, KeyError)
            println("Need a symbol for this endpoint")
        end
    end
    symbol = escapeuri(path_params["symbol"])
    daterange = get(path_params, "range", "")
    asofdate = get(path_params, "date", "")
    date = isempty(asofdate) ? "" : "date/" * asofdate
    http_string = "/stock/$symbol/$endpoint/$daterange/$date"

    url = join([conn.url, conn.version, http_string], "/")
    if haskey(query_params, "symbols")
        query_params["symbols"] = escapeuri(query_params["symbols"])
    end
    params = merge(Dict("token" => conn.token), query_params)
    r = request("GET", url; query = params)
    if r.status != 200
        error("Expected status code 200 but got $r.status")
    end
    return parse(String(r.body))
end


end
