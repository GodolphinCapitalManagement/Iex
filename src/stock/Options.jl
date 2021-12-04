# Option Pricing Formulas
using Distributions
using Roots


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