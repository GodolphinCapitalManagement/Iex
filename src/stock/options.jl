# Option Pricing Formulas


"""
    bsopm_call(S, K, r, σ, t)
Black-Scholes Pricing Model for Call Option
"""
function bsopm_call(S, K, r, σ, t)
    n = Normal()
    d₁ = (log(S/K) + (r + 0.5 * σ^2) * t) /(σ * √t)
    d₂ = d₁ - σ * √t
    return S * cdf(n, d₁) - K * exp(-r*t) * cdf(n, d₂)
end


"""
    bsopm_greeks(S, K, r, σ, t)
    Black-Scholes Pricing Model Vga for Call Option
"""
function bsopm_greeks(S, K, r, σ, t)
    n = Normal()
    d₁ = (log(S/K) + (r + 0.5 * σ^2) * t) /(σ * √t)

    δ = cdf(n, d₁)
    vega = S * cdf(n, d₁) * √t

    return (δ = δ, vega=vega)
end  # function bsomp_vega
