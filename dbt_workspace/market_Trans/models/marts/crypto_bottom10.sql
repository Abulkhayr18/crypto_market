{{ config(materialized='table') }}

SELECT
    name,
    symbol,
    price_usd,
    market_cap_usd,
    percent_change_24h,
    price_trend
FROM {{ ref('stg_crypto') }}
WHERE market_cap_usd > 1000000
ORDER BY percent_change_24h ASC
LIMIT 10