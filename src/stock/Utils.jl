# Utilities for stocks-related endpoints

import HTTP: request, escapeuri
import JSON: parse

import Iex.Connect: IEXException

valid_range_values = [
    "max", "5y", "2y", "1y", "ytd", "6m", "3m", "1m", "1mm", "5d", "5dm",
    "date", "dynamic", "next"
]


"""
    get_stocks(conn::Connection, endpoint::String, path_params::Array{Symbol, 1};
        kwargs...)

Get stock prices in various formats
"""
function get_stocks(
    conn::Connection,
    endpoint::String,
    path_params::Array{Symbol, 1};
    kwargs...
)
    kwargs = Dict(kwargs)

    path_dict = Dict()
    query_dict = Dict()
    for (k, v) in kwargs
        if k in path_params
            merge!(path_dict, Dict(k => v))
        else
            merge!(query_dict, Dict(k => v))
        end
    end

    symbol = try
        escapeuri(path_dict[:symbol])
    catch error
        if isa(error, KeyError)
            println("Need a symbol for this endpoint")
        end
    end

    range = get(path_dict, :range, "1m")
    if !(range in valid_range_values)
        throw(ArgumentError("invalid range value"))
    end
    date = get(path_dict, :date, "")

    if isempty(date)
        http_string = "stock/$symbol/$endpoint/$range"
    else
        http_string =  "stock/$symbol/$endpoint/date/$date"
    end

    url = join([conn.url, conn.version, http_string], "/")
    if haskey(query_dict, :symbols)
        query_dict[:symbols] = escapeuri(query_dict[:symbols])
    end
    params = merge(Dict("token" => conn.token), query_dict)
    r = try
        request("GET", url; query = params)
    catch e
        throw(IEXException(e.status))
    end

    return parse(String(r.body))
end
