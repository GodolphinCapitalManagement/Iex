# Iex
__precompile__()
module Iex


# Connections
include("connection/Connect.jl")
export Connection, status, set_connection_url!, set_connection_version!,
    set_connection_token!

# Accounts
include("account/Account.jl")
export usage, metadata

# Utils
include("stock/Utils.jl")
export get_stocks

# Stocks
include("stock/Prices.jl")
export history, batch, book, symbol_quote, price,
    ohlc, largest_trades, batched_closes

# Profiles
include("stock/Profiles.jl")
export company, insider_roster, insider_summary, insider_transactions,
    logo, peers

    # Fundamentals
include("stock/Fundamentals.jl")
export balance_sheet, dividends, earnings, income, split

# Research
include("stock/Research.jl")
export stats

# News
include("stock/News.jl")
export news

# Reference
include("reference/Reference.jl")
export symbols

# Options
include("stock/Options.jl")
export bsopm_call, bsopm_impvol, calc_term, calc_hr, fortify_mv_df!
export compute_mv_delta, lme_mv_delta

const fields_to_merge = [:id, :ipodate, :enddate, :dadate, :mergerdate, :closingdate]
export fields_to_merge

end
