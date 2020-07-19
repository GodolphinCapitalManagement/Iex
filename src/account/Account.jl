# Account

import HTTP: request
import JSON: parse


const valid_types = [
    "messages", "rules", "rule-records", "alerts",
    "alert-records"
]

struct UsageTypeException <: Exception
    msg::AbstractString

    function UsageTypeException()
        msg = "quota_type must be one of " * join(valid_types, ", ")
        new(msg)
    end
end


"""
    usage(conn::Connection; quota_type="messages")

Get usage for account associated with IEX connection conn
"""
function usage(conn; quota_type::String="messages")
    if !(quota_type in valid_types)
        throw(UsageTypeException())
    end

    url = conn.url * conn.version * "/account/usage/" * quota_type
    r = request("GET", url; query = Dict("token" => conn.secret_token))
    return parse(String(r.body))
end


"""
    metadata(conn::Connection)

Get metadata for account associated wth IEX connection conn
"""
function metadata(conn)
    url = conn.url * conn.version * "/account/metadata"
    r = request("GET", url; query = Dict("token" => conn.secret_token))
    return parse(String(r.body))
end

