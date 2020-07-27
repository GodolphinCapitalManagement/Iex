# Iex.jl Documentation

*A Julia wrapper for the IEX Cloud API.*

## Overview

This package is a Julia wrapper for the IEX Cloud API. IEX Cloud provides realtime and historical data for commodities, equities, digital currencies (i.e. cryptocurrencies), foreign exchange etc.

The pricing structure is flexible and scalable, depending on
usage measured in terms of messages/month. Each API call has
a pre-specified message weight which is debited from the current
available message quota for the month.

The free tier level provides 50,000 core messages/month,
unlimited Investors Exchange data, unlimited sandbox testing,
and limited access to core data. A new account can be
established [here](https://iexcloud.io/cloud-login#/register).

## Installation


```@meta
CurrentModule = Iex
DocTestSetup = quote
    using Iex
end
```

```@autodocs
Modules = [Iex, Iex.Connect]
```


```
# Iex.jl is not currently registered as an official package
# Please install the development version from GitHub:

Pkg.clone("git://GitHub.com/GodolphinCapitalManagement/Iex.jl")
```

If you encounter a clear bug, please file a minimal reproducible example on GitHub.

## Functions

### Time Series for AAPL

```
Iex.history(iex, "AAPL")
Iex.symbol_quote(iex, "AAPL")
```

## Usage

```
using DataFrames
using Plots

using Iex
using Iex.Connect

params = (
    token=ENV["IEX_SANDBOX_API_KEY"],
    url="https://sandbox.iexapis.com",
    version="stable",
)
iex = init_connection(;url=params.url, version=params.version, token=params.token);

gr(fmt=:png, size=(800,470))
# Get daily S&P 500 data
data = history(iex, "SPY");

# Plot the timeseries
plot(data.date, data.close, label="Close", title="SPY")
plot!(data.date, data.high, label="High")
plot!(data.date, data.low, label="Low")
savefig("spy.png")
```
