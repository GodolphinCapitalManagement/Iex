# Stocks/Prices

import Dates: Date
import DataFrames: DataFrame

import Iex.Connect: get_stocks, status


"""
    chart(conn::Connection, symbol::String; daterange="1m")

Gets Returns adjusted and unadjusted historical data
for up to 15 years. Useful for building charts.

This endpoint is carried over from the IEX 1.0 API,
and we know it has become difficult to use. We are
working on new endpoints to simplify time series queries.
"""
function history(conn::Connection, symbol::String; daterange = "1m")
    path_params = Dict("symbol" => symbol, "range" => daterange)
    d = get_stocks(conn, "chart", path_params)
    df = vcat(map(x -> DataFrame(x), d)...)
    df[!, :date] = Date.(df[!, :date])
    cols = [
        :date,
        :open,
        :high,
        :low,
        :close,
        :volume,
        :uOpen,
        :uHigh,
        :uLow,
        :uClose,
        :uVolume,
    ]
    return df[!, cols]
end


"""
    batch(conn::Connection, symbol::String, types::String; symbols="",
        daterange="1m")

Batch various API endpoints for a symbol or list of symbols

Path Parameters

|Option | Description
|:----- | :----------
|symbol | Use 'market' to get_stocks multiple symbols (i.e. .../market/batch?...)

Query String Parameters

|Option  | Details
|:-------|:--------
|types   | Required
|        | Comma delimited list of endpoints to call. The names should match
|         | the individual endpoint names. Limited to 10 endpoints.
|symbols | Optional
|        | Comma delimited list of symbols limited to 100. This parameter is
|        | used only if market option is used.
|        | ***(NOTE: If you do not include a symbols parameter the default
|        | behavior is to return the data for ALL relevant symbols. Please be
|        | cautious when using this behavior as it can drive up message usage
|        | quickly.)***
|range   | Optional
|        | Used to specify a chart range if chart is used in types parameter.
|*       | Optional
|        | Parameters that are sent to individual endpoints can be specified
|        | in batch calls and will be applied to each supporting endpoint.
|        | For example, last can be used for the news endpoint to specify the number
|        | of articles
"""
function batch(
    conn::Connection,
    symbol::String,
    types::String;
    symbols::String = "",
    daterange = "1m",
)

    path_params = Dict("symbol" => symbol)
    query_params = Dict("range" => daterange, "types" => types)
    if symbol == "market"
        if isempty(symbols)
            throw(UndefVarError("batch requires at least 1 symbol"))
        else
            query_params = merge(Dict("symbols" => symbols), query_params)
        end
    end

    return get_stocks(conn, "batch", path_params; query_params = query_params)
end


"""
    book(conn::Connection, symbol::String)

Response includes data from deep and quote. Refer to each endpoint for details.
"""
function book(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "book", path_params)
end
