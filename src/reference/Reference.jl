import HTTP: request
import JSON: parse

"""
    symbols(conn::Connection; format::String="JSON")

This call returns an array of symbols the Investors Exchange supports for
trading. This list is updated daily as of 7:45 a.m. ET. Symbols may be added or
removed by the Investors Exchange after the list was produced
"""
function symbols(conn::Connection; format::String = "JSON")
    url = conn.url * conn.version * "/ref-data/symbols/"
    r = request("GET", url;
        query = Dict("token" => conn.token, "format" => format)
    )
    return parse(String(r.body))
end
