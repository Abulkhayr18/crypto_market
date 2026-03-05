{{ config(materialized='table') }}

SELECT
    name,
    symbol,
    price_usd,
    market_cap_usd,
    percent_change_24h
FROM {{ ref('stg_crypto') }}
WHERE price_trend = 'losing'
ORDER BY percent_change_24h ASC