# Utilities for stocks-related endpoints

import HTTP: request, escapeuri
import JSON: parse

import Iex.Connect: IEXException


"""
    get_stocks(conn::Connection, endpoint::String, path_params;
        query_params=Dict())

Get stock prices in various formats
"""
function get_stocks(
    conn::Connection,
    endpoint::String,
    path_params::Dict;
    query_params::Dict=Dict()
)

    symbol = try
        escapeuri(path_params["symbol"])
    catch error
        if isa(error, KeyError)
            println("Need a symbol for this endpoint")
        end
    end

    daterange = get(path_params, "range", "")
    asofdate = get(path_params, "date", "")
    date = isempty(asofdate) ? "" : "date/" * asofdate
    http_string = "/stock/$symbol/$endpoint/$daterange/$date"

    url = join([conn.url, conn.version, http_string], "/")
    if haskey(query_params, "symbols")
        query_params["symbols"] = escapeuri(query_params["symbols"])
    end
    params = merge(Dict("token" => conn.token), query_params)
    r = try
        request("GET", url; query = params)
    catch e
        throw(IEXException(e.status))
    end

    return parse(String(r.body))
end
