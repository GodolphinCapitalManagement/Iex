# Stocks/Prices


import Iex.Connect: IEXException

import Dates: Date
import DataFrames: DataFrame, Not


std_cols = "date,label,open,high,low,close,volume,uOpen,uHigh,uLow,uClose,uVolume"


"""
    history(
        conn::Connection, symbol::String;
        range::String = "1m", date::String = "",
        filter = std_cols;
        chartCloseOnly::Bool = false
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
    range::String = "1m",
    date::String = "",
    filter = std_cols,
    chartCloseOnly::Bool = false
)::DataFrame

    path_params = [:symbol, :range, :date]
    d = get_stocks(
        conn, "chart", path_params;
        symbol = symbol,
        range = range,
        date = date,
        filter = filter,
        chartCloseOnly = chartCloseOnly
    )
    colnames = split("symbol," * filter, ",")
    if length(d) > 0
        df = vcat(map(x -> DataFrame(x), d)...)
        df[!, :date] = Date.(df[!, :date])
        df[!, :symbol] .= symbol
        return df[!, colnames]
    else
        coltypes = [
            String,
            Date,
            String,
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
        range="1m"
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
|        | the individual endpoint names. Limited to 10 endpoints.
|        | should be one of chart,quote,news
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
    range = "1m",
    filter = std_cols
)
    path_params = [:symbol, :range, :date]

    if symbol == "market"
        if isempty(symbols)
            throw(ArgumentError("batch requires at least 1 symbol"))
        end
    end

    return get_stocks(
        conn, "batch", path_params;
        symbol = symbol,
        symbols = symbols,
        types = types,
        range = range,
        filter = filter
    )
end


"""

    batched_closes(conn::Connection, symbol::String, symbols::Array{String,1};
        range="1m")

get closes for multiple symbols
"""
function batched_closes(conn::Connection, symbols::Array{String,1}; range="1m")

    hist = batch(conn, "market", "chart"; symbols=join(symbols, ", "), 
        range=range, filter="date,close")
    df = []
    for symbol in symbols
        tmp_df = vcat([DataFrame(x) for x in hist[symbol]["chart"]]...)
        tmp_df[!, :symbol] .= symbol
        push!(df, tmp_df)
    end
    vcat(df...)
end


"""
    book(conn::Connection, symbol::String)

Response includes data from deep and quote. Refer to each endpoint for details.
"""
function book(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "book", path_params; symbol = symbol)
end


"""
    symbol_quote(conn::Connection, symbol::String; field::String="latestPrice")
"""
function symbol_quote(conn::Connection, symbol::String; field::String="latestPrice")
    path_params = [:symbol, :field]
    return get_stocks(conn, "quote", path_params; symbol = symbol, field = field)
end


"""
    price(conn::Connection, symbol::String)

Response includes data from deep and quote. Refer to each endpoint for details.
"""
function price(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "price", path_params; symbol = symbol)
end


"""
    ohlc(conn::Connection, symbol::String)

Response includes data from deep and quote. Refer to each endpoint for details.
"""
function ohlc(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "ohlc", path_params; symbol = symbol)
end


"""
    largest_trades(conn::Connection, symbol::String)

Returns 15 minute delayed, last sale eligible trades.
"""
function largest_trades(conn::Connection, symbol::String)
    path_params = [:symbol]
    return get_stocks(conn, "largest-trades", path_params; symbol = symbol)
end
