# Connect
module Connect

import HTTP: request
import JSON: parse

using Iex

export status, IEXException

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
    r = try
        request("GET", url;)
    catch e
        throw(IEXException[e.status])
    end
    return parse(String(r.body))
end


"""
    struct IEXException <: Exception

IEX Cloud uses [HTTP response codes](https://www.restapitutorial.com/httpstatuscodes.html)
to indicate the success or failure of an API request.

Found at [API Version](https://iexcloud.io/docs/api/#error-codes)
"""
struct IEXException <: Exception
    msg::AbstractString

    function IEXException(code::Int16)
        msg = join(get(IEXErrorCodes, code, "Unknown Error Code"), " or ")
        new(msg)
    end
end

const IEXErrorCodes = Dict{Int, Array{String,1}}(
    400 => [
        "Invalid values were supplied for the API request",
        "No symbol provided",
        "Batch request types parameter requires a valid value"
    ],
    401 => [
        "Hashed token authorization is restricted",
        "Hashed token authorization is required",
        "The requested data is marked restricted and the account does not have access.",
        "An API key is required to access the requested endpoint.",
        "The secret key is required to access to requested endpoint.",
        "The referer in the request header is not allowed due to API token domain restrictions."
    ],
    402 => [
        "You have exceeded your allotted message quota and pay-as-you-go is not enabled.",
        "The requested endpoint is not available to free accounts.",
        "The requested data is not available to your current tier."
    ],
    403 => [
        "Hashed token authorization is invalid.",
        "The provided API token has been disabled",
        "The provided API token is not valid.",
        "A test token was used for a production endpoint.",
        "A production token was used for a sandbox endpoint.",
        "Your pay-as-you-go circuit breaker has been engaged and further requests are not allowed.",
        "Your account is currently inactive."
    ],
    404 => [
        "Unknown symbol provided",
        "Resource not found"
    ],
    413 => ["Maximum number of types values provided in a batch request."],
    429 => ["Too many requests hit the API too quickly. An exponential backoff of your requests is recommended."],
    451 => ["The requested data requires additional permission to access."],
    500 => ["Something went wrong on an IEX Cloud server."]
)

end
