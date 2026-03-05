{{ config(severity='warn') }}
SELECT *
FROM {{ ref('stg_crypto') }}
WHERE price_usd <= 0