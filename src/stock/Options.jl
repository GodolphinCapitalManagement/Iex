# Option Pricing Formulas
using Distributions
using Roots
using Dates


"""
    bsopm_call(S, K, r, σ, t)
    Black-Scholes Pricing Model for Call Options

    returns call value, delta and vega as a named tuple
"""
function bsopm_call(S, K, r, σ, t)
    n = Normal()
    d₁ = (log(S/K) + (r + 0.5 * σ^2) * t) /(σ * √t)
    d₂ = d₁ - σ * √t
    value = S * cdf(n, d₁) - K * exp(-r*t) * cdf(n, d₂)

    δ = cdf(n, d₁)
    vega = S * √t * pdf(n, d₁)

    return (value=value, δ=δ, vega=vega)
end  # function bsomp_call



function bsopm_impvol(opt_val, S, K, r, t)

    f(x) = opt_val - bsopm_call(S, K, r, x, t).value
    r = try
        find_zero(f, (0.0, 5.0), Bisection())
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