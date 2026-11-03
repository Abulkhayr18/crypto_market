Crypto Market Data PipelineAn end-to-end cloud analytics engineering pipeline that extracts live cryptocurrency market data from the CoinMarketCap API, ingests and persists structured records into a Databricks SQL Warehouse (Delta Lake), and transforms raw payloads into production-grade analytics data marts using dbt Core with automated data quality assertions.System ArchitectureThe pipeline follows a Medallion Architecture (Bronze $\rightarrow$ Silver $\rightarrow$ Gold) pattern to ensure strict separation of concerns, data lineage, and high data quality across transformation layers:                  ┌───────────────────────────────────────────┐
                  │            CoinMarketCap API              │
                  └─────────────────────┬─────────────────────┘
                                        │
                                 [Python ETL Engine]
                                        │
                                        ▼
                  ┌───────────────────────────────────────────┐
                  │    Bronze Layer: Raw Landing & Staging    │
                  │     (workspace.crypto_market.listings)    │
                  └─────────────────────┬─────────────────────┘
                                        │
                                   [dbt Core]
                                        │
     ┌──────────────────────────────────┼──────────────────────────────────┐
     ▼                                  ▼                                  ▼
┌─────────────────────────┐  ┌─────────────────────────────┐  ┌──────────────────────────┐
│  Silver Layer: Staging  │  │   Gold Layer: Data Marts    │  │  Gold Layer: Reporting   │
│  (Ephemeral Models)     │  │   (Physical Tables)         │  │  (Analytical Views)      │
├─────────────────────────┤  ├─────────────────────────────┤  ├──────────────────────────┤
│ • stg_crypto            │  │ • crypto_top10              │  │ • crypto_report          │
│                         │  │ • crypto_bottom10           │  │                          │
│                         │  │ • crypto_gainers            │  │                          │
│                         │  │ • crypto_losers             │  │                          │
│                         │  │ • crypto_market_summary     │  │                          │
└─────────────────────────┘  └─────────────────────────────┘  └──────────────────────────┘

Tech Stack & Engineering ConceptsCategoryTools / TechnologiesImplementation PurposeLanguage & ScriptingPython 3.11+, Pandas, RequestsIngestion script, REST API payload extraction, and data formattingData SourceCoinMarketCap Professional APILive market listings, market caps, pricing, and 24h volume telemetryData PlatformDatabricks SQL Warehouse / Delta LakeCloud Lakehouse engine, ACID transactions, and scalable data storageAnalytics Engineeringdbt Core (dbt-databricks)Modular SQL transformations, DAG execution, schema validation, and lineageData Quality & Auditdbt Schema Tests, Custom SQL AssertionsAutomated verification of zero-null constraints, unique keys, and price positivityEnvironment Controlpython-dotenv, GitSecure API key management, environment separation, and version controlProject Repository Structurecrypto_market_pipeline/
├── crypto_market/
│   ├── pipeline.ipynb        # Jupyter Notebook for interactive ETL execution
│   ├── ETL.py                # Standalone Python extraction & loading script
│   ├── crypto_data.csv       # Extracted snapshot data (git-ignored)
│   └── .env                  # Environment variables & API credentials (git-ignored)
│
└── dbt_workspace/
    └── market_Trans/
        ├── models/
        │   ├── staging/
        │   │   ├── stg_crypto.sql       # Ephemeral staging model (type casting & sanitization)
        │   │   └── schema.yml           # Column assertions and schema tests
        │   ├── marts/
        │   │   ├── crypto_top10.sql     # Top 10 tokens by market capitalization
        │   │   ├── crypto_bottom10.sql  # 10 worst performing tokens (24h change)
        │   │   ├── crypto_gainers.sql   # Active tokens with positive 24h delta
        │   │   ├── crypto_losers.sql    # Active tokens with negative 24h delta
        │   │   ├── crypto_market_summary.sql  # Global aggregated market statistics
        │   │   └── schema.yml           # Mart validation tests
        │   └── reports/
        │       ├── crypto_report.sql    # Gold view combining metrics for business dashboards
        │       └── schema.yml           # Report schema metadata
        ├── tests/
        │   └── assert_price_above_zero.sql  # Custom singular SQL data quality test
        ├── dbt_project.yml              # dbt project config & model materialization rules
        └── packages.yml                 # External dbt package dependencies

Data Quality & Assertion Testing FrameworkTo guarantee enterprise-level data reliability, the pipeline executes rigorous automated testing at both the schema level and custom singular test level prior to exposing data to gold marts:Test NameModel TargetTest TypeAssertion Descriptionuniquestg_crypto.idSchema TestValidates zero duplicate asset identifiers across ingestion payloads.not_nullstg_crypto.price_usdSchema TestEnforces strict presence of asset pricing data.not_nullstg_crypto.market_cap_usdSchema TestEnsures market cap metrics are non-null for capitalization ranking.accepted_valuesstg_crypto.price_trendSchema TestRestricts value domain to ['Gaining', 'Losing', 'Stable'].assert_price_above_zerostg_cryptoCustom Singular TestFails pipeline build if any record reflects a negative or zero USD price value ($P \le 0$).

Analytics Marts Output Summary

stg_crypto (Staging): Ephemeral cleaning layer standardizing timestamps, numeric types, and price trend indicators.

crypto_top10 / crypto_bottom10 (Marts): Physical tables isolating extreme market performers by 24h delta and market capitalization.

crypto_market_summary (Marts): Aggregated metrics tracking total market capitalization, global 24h volume, and asset distribution.

crypto_report (Reports View): Final consumption view calculating market dominance percentages ($Dominance = \frac{Cap_{Asset}}{Cap_{Total}} \times 100$) for reporting dashboards.
