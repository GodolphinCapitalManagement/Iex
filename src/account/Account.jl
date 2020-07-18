# Account

import HTTP: request
import JSON: parse

struct UsageTypeException <: Exception
    msg::AbstractString
end


VALID_TYPES = ("messages", "rules", "rule-records", "alerts", "alert-records")

"""
    usage(conn::Connection; quote_type="message)

Get usage for IEX connection conn
"""
function usage(conn; quote_type::String="messages")
    if !(quote_type in VALID_TYPES)
        valid_types = join(VALID_TYPES, ", ")
        err_msg = "quote_type '$quote_type' not one of [$valid_types]"
        throw(UsageTypeException(err_msg))
    end

    url = conn.url * conn.version * "/account/usage/" * quote_type
    r = request("GET", url;query = Dict("token" => conn.secret_token))
    return parse(String(r.body))
end
