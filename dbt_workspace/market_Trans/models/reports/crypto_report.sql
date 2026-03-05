{{ config(materialized='view') }}

SELECT
    t.name,
    t.symbol,
    t.price_usd,
    t.market_cap_usd,
    t.percent_change_24h,
    t.price_trend,
    s.total_market_cap,
    s.gaining_coins,
    s.losing_coins,
    ROUND(t.market_cap_usd / s.total_market_cap * 100, 4) AS market_dominance_pct
FROM {{ ref('crypto_top10') }} t
CROSS JOIN {{ ref('crypto_market_sum') }} s