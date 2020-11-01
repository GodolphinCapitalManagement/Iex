# Stocks/News
import Iex.Connect: status

"""
    news(conn::Connection, symbol::String; last::Int=10

Provides intraday news from over 3,000 global news sources including major
publications, regional media, and social.. This endpoint returns up to the last
50 articles. Use the [historical news](https://iexcloud.io/docs/api/#historical-news)
endpoint to fetch news as far back as January 2019

Path Parameters:

|Option|Description|
|:-----|:----------|
|symbol|A stock symbol|
|last  |Number between 1 and 50. Default is 10|
"""
function news(conn::Connection, symbol::String; last::Int=10)
    path_params = [:symbol, :last]
    last =  max(1, min(50, last))
    return get_stocks(conn, "news", path_params; symbol = symbol, last = last)
end
