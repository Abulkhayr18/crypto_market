{{ config(materialized='table') }}

SELECT
    name,
    symbol,
    price_usd,
    market_cap_usd,
    percent_change_24h,
    price_trend
FROM {{ ref('stg_crypto') }}
ORDER BY market_cap_usd DESC
LIMIT 10