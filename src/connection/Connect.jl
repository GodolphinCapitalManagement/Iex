# Connect

import HTTP: request
import JSON: parse


struct Connection
    secret_token::String
    public_token::String
    url::String
    version::String
end


"""
    Connection(params::NamedTuple)

Populates IEX connection parameters used in constructing
GET and POST requests for API.
"""
function connection(params::NamedTuple)
    secret_token = params.secret_token
    public_token = params.public_token
    url = params.url
    version = params.version
    Connection(secret_token, public_token, url, version)
end


"""
    status(conn::Connection)

Get status for IEX connection conn
"""
function status(conn::Connection)
    url = conn.url * conn.version * "/status"
    r = request("GET", url;)
    return parse(String(r.body))
end
