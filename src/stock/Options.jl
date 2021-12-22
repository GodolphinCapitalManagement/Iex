# Option Pricing Formulas
using DataFrames
using Distributions
using Roots
using Dates
using RobustModels
using MixedModels
using GLM
using ShiftedArrays

using BLPData

"""
    bsopm_call(S, K, r, σ, t; q=0.0, u=0.0)
    Black-Scholes Pricing Model for Call Options

    returns call value, delta and vega as a named tuple
"""
function bsopm_call(S, K, r, σ, t; q=0.0, u=0.0)
    n = Normal()
    d₁ = (log(S/K) + ((r-q-u) + 0.5 * σ^2) * t) /(σ * √t)
    d₂ = d₁ - σ * √t
    value = S * exp(-(q+u)*t) * cdf(n, d₁) - K * exp(-r*t) * cdf(n, d₂)

    δ = exp(-(q+u)*t) * cdf(n, d₁)
    vega = S * exp(-(q+u)*t) * √t * pdf(n, d₁)

    return (value=value, δ=δ, vega=vega)
end  # function bsomp_call



function bsopm_impvol(opt_val, S, K, r, t; q=0.0, u=0.0)

    f(x) = opt_val - bsopm_call(S, K, r, x, t, q=q, u=u).value
    r = try
        find_zero(f, (0.0, 500.0)) # , Bisection())
    catch e 
        println(e)
        return 0.0
    end 
    return r
end  # function bsopm_impvol


"""
    calc_term(valuedate::Date, id::String, ipodate::Date,
        enddate::Date; 
        dadate::Union{Missing,Date}=missing,
        mergerdate::Union{Missing,Date}=missing, 
        closingdate::Union{Missing,Date}=missing,
        da_to_merger_days::Int64=120,
        merger_to_effective_days::Int64=30, 
        ann_factor::Int64=252)

calculates exercise date, maturity date and option 
term in years.
"""
function calc_term(valuedate::Date, id::String, ipodate::Date;
    enddate::Union{Missing,Date}=missing,
    dadate::Union{Missing,Date}=missing,
    mergerdate::Union{Missing,Date}=missing, 
    closingdate::Union{Missing,Date}=missing,
    da_to_merger_days::Int64=120,
    merger_to_effective_days::Int64=30, 
    ann_factor::Int64=252)

    spac_term = (ismissing(enddate) ? closingdate : enddate) - ipodate
    
    if ismissing(dadate) && ismissing(mergerdate)
        maturity_date = ipodate + Month(60)
        first_exercise_date = ipodate + Day(spac_term)
    elseif ismissing(mergerdate)
        maturity_date = dadate + Day(da_to_merger_days) + Month(60)
        first_exercise_date = dadate + Day(da_to_merger_days) + 
            Day(merger_to_effective_days)
    else
        maturity_date = mergerdate + Month(60)
        first_exercise_date =  max(ipodate + Month(12), 
            mergerdate + Day(merger_to_effective_days))
    end

    t = max(1, (maturity_date - valuedate).value)/365.25
    Nstep = max(30, convert(Int, round(t * ann_factor)))

    e = max(0, (first_exercise_date - valuedate).value)/365.25
    Estep = convert(Int, round(e * ann_factor))

    return (id=id, date=valuedate, t=t, Nstep=Nstep, Estep=Estep)
end


"""
    calc_hr(S, K, r, σ, t, a, b, c)

calculates warrant HR based on HW market model
"""
function calc_hr(S, K, r, σ, t, a, b, c)
    value, δ, vega =  bsopm_call(S, K, r, σ, t) 
    δₘᵥ = clamp(δ + (vega / (S * sqrt(t))) * (a + b * δ + c * δ^2), 0, 1)

    return (S=S, value=value, δ=δ, vega=vega, δₘᵥ=δₘᵥ)
end  # function calc_hr


"""
    fortify_mv_df(dyn_df::DataFrame; K::Float64=11.5, r::Float64=0.0008)

generates price data and computes min-variance deltas for a stock/warrant pair.
"""
function fortify_mv_df!(dyn_df::DataFrame; K::Float64=11.5, r::Float64=0.0008)

    # create phase variables

    # transform(z_u, [:date, :dadate, :closingdate] => ByRow( (x, y, z) -> 
    #     !(ismissing(y) || ismissing(z)) ? ifelse(x >= y && x < z, 2,  3) : 1) => :phase)

    dyn_df[!, :ls] = lag(dyn_df.s)
    dyn_df[!, :ds] = dyn_df.s .- dyn_df.ls 
        
    dyn_df[!, :lw] = lag(dyn_df.w)
    dyn_df[!, :dw] = dyn_df.w .- dyn_df.lw

    z = DataFrame(map(row -> calc_term(row.date, row.id, row.ipodate, enddate=row.enddate, 
            dadate=row.dadate, mergerdate=row.mergerdate, closingdate=row.closingdate), 
            eachrow(dyn_df)))

    leftjoin!(dyn_df, z, on=[:id, :date])
    select!(dyn_df, Not([:id, :ipodate, :dadate, :closingdate, :enddate, :mergerdate, :Nstep, :Estep]))

    # fortify data with bsopm delta and vega
    transform!(dyn_df, [:w, :s, :t] => ByRow( (x, y, z) -> bsopm_impvol(x, y, K, r, z)) => :σ)
    transform!(dyn_df, [:s, :σ, :t] => ByRow( (a, b, c) -> !isnothing(b) ? 
        bsopm_call(a, K, r, b, c) : (value=missing, δ=missing, vega=missing)) => [:value, :δ, :vega])

    return dyn_df
end  # function fortify_mv_df!


"""
    compute_mv_delta(dyn_df::DataFrame;
        window::Union{Missing,Int64}=missing, robust::Bool=true)

computes min-variance deltas for a stock/warrant pair.
"""
function compute_mv_delta(dyn_df::DataFrame;
        window::Union{Missing,Int64}=missing, robust::Bool=true)

    if ismissing(window)
        window = nrow(dyn_df)
    end

    sub_df = last(dyn_df, window)
    Y = sub_df.dw .- sub_df.δ .* sub_df.ds
    μ = (sub_df.vega ./ sqrt.(sub_df.t)) .* (sub_df.ds./sub_df.s)
    x₁ = μ
    x₂ = μ .* sub_df.δ
    x₃ = μ .* sub_df.δ.^2

    if robust 
        hw_reg = rlm(@formula(Y ~ -1 + x₁ + x₂ + x₃), 
            DataFrame(Y=Y, x₁=x₁, x₂=x₂, x₃=x₃),
            MEstimator{HuberLoss}(); method=:chol, 
            initial_scale=15.0)
    else
        hw_reg = lm(@formula(Y ~ -1 + x₁ + x₂ + x₃), 
            DataFrame(Y=Y, x₁=x₁, x₂=x₂, x₃=x₃))
    end

    a, b, c = coef(hw_reg)
    sub_df[!, :δₘᵥ] = max.(0.0, sub_df.δ .+ (sub_df.vega ./ 
        (sub_df.s .* sqrt.(sub_df.t))) .* (a .+ b .* sub_df.δ + c .* sub_df.δ.^2))

    return (sub_df=sub_df, hw_reg=hw_reg, params=(a, b, c))

end  # function compute_mv_delta


"""
    lme_mv_delta(dyn_df::DataFrame;
        start_date::Union{Missing,Date}=missing,
        end_date::Union{Missing,Date}=missing)

computes min-variance deltas for a stock/warrant pair.
"""
function lme_mv_delta(dyn_df::DataFrame;
        start_date::Union{Missing,Date}=missing,
        end_date::Union{Missing,Date}=missing)

    if !ismissing(end_date)
        sub_df = subset(dyn_df, :date => x -> x .<= end_date, skipmissing=true)
    elseif !ismissing(start_date)
        sub_df = subset(dyn_df, :date => x -> x .>= start_date, skipmissing=true)
    elseif !(ismissing(start_date) && ismissing(end_date))
        sub_df = subset(dyn_df, :date => x -> x .>= start_date && x .<= end_date, 
            skipmissing=true)
    else
        sub_df = dyn_df
    end

    Y = sub_df.dw .- sub_df.δ .* sub_df.ds
    μ = (sub_df.vega ./ sqrt.(sub_df.t)) .* (sub_df.ds./sub_df.s)
    x₁ = μ
    x₂ = μ .* sub_df.δ
    x₃ = μ .* sub_df.δ.^2

    estim_df = DataFrame(Y=Y, x₁=x₁, x₂=x₂, x₃=x₃, symbol=sub_df.symbol)

    fm = @formula(Y ~ 0 + x₁ + x₂ + x₃ + (0 + x₁ + x₂ + x₃|symbol))
    fm1 = fit(MixedModel, fm, estim_df)

    a, b, c = fixef(fm1)
    fixef_df = DataFrame(symbol="AVG", x₁=a, x₂=b, x₃=c)
    ranef_df = DataFrame(only(raneftables(fm1)))
    param_df = reduce(vcat, [fixef_df, ranef_df])
    param_df[!, :obsdate] .= maximum(dyn_df.date)

    dyn_df[!, :δₘᵥ] = max.(0.0, dyn_df.δ .+ (dyn_df.vega ./ 
        (dyn_df.s .* sqrt.(dyn_df.t))) .* (a .+ b .* dyn_df.δ + c .* dyn_df.δ.^2))

    return (estim=estim_df, fm1=fm1, param_df=param_df)
end