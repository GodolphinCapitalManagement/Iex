# Stocks/Prices


import Iex.Connect: IEXException

import Dates: Date
import DataFrames: DataFrame, Not


const valid_range_values = [
    "max", "5y", "2y", "1y", "ytd", "6m", "3m", "1m", "1mm", "5d", "5dm",
    "date", "dynamic"
]


"""
    history(conn::Connection, symbol::String; daterange="1m",
        chartcloseonly::Bool = false,
        columns = "date,open,high,low,close,volume,uOpen,uHigh,uLow,uClose,uVolume"
    )

Gets adjusted and unadjusted historical data
for up to 15 years. Useful for building charts.

This endpoint is carried over from the IEX 1.0 API,
and we know it has become difficult to use. We are
working on new endpoints to simplify time series queries.
"""
function history(
    conn::Connection,
    symbol::String;
    daterange = "1m",
    chartcloseonly::Bool = false,
    columns = "date,open,high,low,close,volume,uOpen,uHigh,uLow,uClose,uVolume"
)::DataFrame
    if !(daterange in valid_range_values)
        throw(ArgumentError("invalid range value"))
    end
    path_params = Dict("symbol" => symbol, "range" => daterange)
    query_params = Dict("chartCloseOnly" => chartcloseonly,
        "filter" => columns
    )
    d = get_stocks(conn, "chart", path_params; query_params = query_params)
    colnames = split("symbol," * columns, ",")
    if length(d) > 0
        df = vcat(map(x -> DataFrame(x), d)...)
        df[!, :date] = Date.(df[!, :date])
        df[!, :symbol] .= symbol
        return df[!, colnames]
    else
        coltypes = [
            String,
            Date,
            Float64,
            Float64,
            Float64,
            Float64,
            Int64,
            Float64,
            Float64,
            Float64,
            Float64,
            Int64,
        ]
        return DataFrame(coltypes, colnames, 0)
    end
end


"""
    batch(conn::Connection, symbol::String, types::String; symbols="",
        daterange="1m",
        columns = "date,open,high,low,close,volume,uOpen,uHigh,uLow,uClose,uVolume"
)

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
|        | For example, last can be used for the news endpoint to specify the
|        | number of articles
"""
function batch(
    conn::Connection,
    symbol::String,
    types::String;
    symbols::String = "",
    daterange = "1m",
    columns = "date,open,high,low,close,volume,uOpen,uHigh,uLow,uClose,uVolume"
)

    path_params = Dict("symbol" => symbol)

    if !(daterange in valid_range_values)
        throw(ArgumentError("invalid range value"))
    end
    query_params = Dict("range" => daterange, "types" => types,
        "filter" => columns
    )

    if symbol == "market"
        if isempty(symbols)
            throw(ArgumentError("batch requires at least 1 symbol"))
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


"""
    symbol_quote(conn::Connection, symbol::String; field::String="latestPrice")
"""
function symbol_quote(conn::Connection, symbol::String; field::String="latestPrice")
    path_params = Dict("symbol" => symbol, "field" => field)
    return get_stocks(conn, "quote", path_params)
end


"""
    price(conn::Connection, symbol::String)

Response includes data from deep and quote. Refer to each endpoint for details.
"""
function price(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "price", path_params)
end


"""
    ohlc(conn::Connection, symbol::String)

Response includes data from deep and quote. Refer to each endpoint for details.
"""
function ohlc(conn::Connection, symbol::String)
    path_params = Dict("symbol" => symbol)
    return get_stocks(conn, "ohlc", path_params)
end
