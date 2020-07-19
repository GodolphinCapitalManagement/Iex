# Stocks

import HTTP: request
import JSON: parse

import Dates: Date
import DataFrames: DataFrame

"""
    fetch(conn::Connection, ticker::String, endpoint::String)

Get stock prices in various formats
"""
function query(conn, ticker::String, endpoint::String,
    daterange::String, asofdate::String)

    url = join(
        [conn.url, conn.version, "/stock/", ticker, endpoint, daterange, asofdate],
        "/"
    )
    r = request("GET", url; query = Dict("token" => conn.public_token))
    return parse(String(r.body))
end


function chart(conn, ticker::String; daterange="", asofdate="")
    d = query(conn, ticker, "chart", daterange, asofdate)
    df = vcat(map((x) -> DataFrame(x), d)...)
    df[!, "date"] = Date.(df[!, "date"])
    return df
end


