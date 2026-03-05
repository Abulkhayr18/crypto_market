WITH source AS (
    SELECT * FROM workspace.crypto_market.listings
),

cleaned AS (
    SELECT
        id,
        name,
        symbol,
        ROUND(price, 4)              AS price_usd,
        ROUND(market_cap, 2)         AS market_cap_usd,
        ROUND(volume_24h, 2)         AS volume_24h_usd,
        ROUND(percent_change_24h, 2) AS percent_change_24h,
        last_updated,
        CASE
            WHEN percent_change_24h > 0 THEN 'gaining'
            WHEN percent_change_24h < 0 THEN 'losing'
            ELSE 'stable'
        END AS price_trend
    FROM source
    WHERE price IS NOT NULL
    AND market_cap IS NOT NULL
    AND price > 0
)

SELECT * FROM cleaned