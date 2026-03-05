{{ config(materialized='table') }}

SELECT
    COUNT(*)                                              AS total_coins,
    ROUND(SUM(market_cap_usd), 2)                        AS total_market_cap,
    ROUND(AVG(price_usd), 4)                             AS avg_price,
    ROUND(MAX(price_usd), 4)                             AS highest_price,
    ROUND(MIN(price_usd), 4)                             AS lowest_price,
    COUNT(CASE WHEN price_trend = 'gaining' THEN 1 END)  AS gaining_coins,
    COUNT(CASE WHEN price_trend = 'losing'  THEN 1 END)  AS losing_coins,
    COUNT(CASE WHEN price_trend = 'stable'  THEN 1 END)  AS stable_coins
FROM {{ ref('stg_crypto') }}