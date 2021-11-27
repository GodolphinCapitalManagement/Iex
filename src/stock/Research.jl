# Stocks/Fundamentals

"""
    stats(conn::Connection, symbol::String, stat::String)

Pulls key statistics.
"""
function stats(conn::Connection, symbol::String; stat::String="")

    http_string = "stock/$symbol/stats/$stat"
    url = join([conn.url, conn.version, http_string], "/")
    params = Dict("token" => conn.token)

    r = try
        request("GET", url; query = params)
    catch e
        throw(IEXException(e.status))
    end

    return parse(String(r.body))
end