# crypt_market
End-to-end crypto market data pipeline using Python, Databricks and dbt
# Crypto Market Data Pipeline

An end-to-end data engineering project that extracts live cryptocurrency data from the CoinMarketCap API, loads it into Databricks, and transforms it using dbt with full data quality testing.

---

## Architecture

```
CoinMarketCap API
       ↓
   Python ETL
  (pipeline.py)
       ↓
  CSV Export
       ↓
Databricks (SQL Warehouse)
  workspace.crypto_market.listings
       ↓
     dbt
  (market_Trans)
       ↓
  ┌────────────────────────────────┐
  │  Staging (ephemeral)           │
  │  └── stg_crypto                │
  ├────────────────────────────────┤
  │  Marts (tables)                │
  │  ├── crypto_top10              │
  │  ├── crypto_bottom10           │
  │  ├── crypto_gainers            │
  │  ├── crypto_losers             │
  │  └── crypto_market_summary     │
  ├────────────────────────────────┤
  │  Reports (views)               │
  │  └── crypto_report             │
  └────────────────────────────────┘
```

---

## Tech Stack

| Tool | Purpose |
|---|---|
| **Python** | Data extraction and transformation |
| **CoinMarketCap API** | Live cryptocurrency data source |
| **Pandas** | Data manipulation and CSV export |
| **Databricks (Free Edition)** | Cloud data warehouse |
| **dbt Core** | Data transformation and testing |
| **dotenv** | Environment variable management |
| **Git** | Version control |

---

## Project Structure

```
port/
├── crypto_market/
│   ├── pipeline.ipynb        # Main ETL notebook
│   ├── ETL.py                # ETL script
│   ├── crypto_data.csv       # Extracted data (generated)
│   └── .env                  # Environment variables (not committed)
│
└── dbt_workspace/
    └── market_Trans/
        ├── models/
        │   ├── staging/
        │   │   ├── stg_crypto.sql       # Ephemeral staging model
        │   │   └── schema.yml           # Column tests
        │   ├── marts/
        │   │   ├── crypto_top10.sql     # Top 10 by market cap
        │   │   ├── crypto_bottom10.sql  # Worst 10 performers
        │   │   ├── crypto_gainers.sql   # All gaining coins
        │   │   ├── crypto_losers.sql    # All losing coins
        │   │   ├── crypto_market_summary.sql  # Aggregated stats
        │   │   └── schema.yml           # Model tests
        │   └── reports/
        │       ├── crypto_report.sql    # Final combined report
        │       └── schema.yml
        ├── tests/
        │   └── assert_price_above_zero.sql  # Custom test
        └── dbt_project.yml
```

---

## Setup & Installation

### Prerequisites
- Python 3.11+
- Databricks account (Free Edition or above)
- CoinMarketCap API key ([Get one free here](https://coinmarketcap.com/api/))

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/crypto-market-pipeline.git
cd crypto-market-pipeline
```

### 2. Create and activate virtual environment
```bash
python -m venv .venv
# Windows
.venv\Scripts\activate
# Mac/Linux
source .venv/bin/activate
```

### 3. Install dependencies
```bash
pip install requests pandas python-dotenv dbt-databricks
```

### 4. Configure environment variables
Create a `.env` file in the `crypto_market` folder:
```
CMC_API_KEY=your_coinmarketcap_api_key
DATABRICKS_HOST=your_databricks_host
DATABRICKS_HTTP_PATH=your_http_path
DATABRICKS_TOKEN=your_access_token
```

### 5. Configure dbt profile
Create/update `~/.dbt/profiles.yml`:
```yaml
market_Trans:
  target: dev
  outputs:
    dev:
      type: databricks
      host: "{{ env_var('DATABRICKS_HOST') }}"
      http_path: "{{ env_var('DATABRICKS_HTTP_PATH') }}"
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      catalog: workspace
      schema: crypto_market
      threads: 1
```

---

## Running the Pipeline

### Step 1: Extract and Load
Run `pipeline.ipynb` in VS Code or Jupyter. This will:
- Pull 5000 cryptocurrencies from CoinMarketCap API
- Clean and transform the data
- Export to `crypto_data.csv`

Then upload `crypto_data.csv` to Databricks via **Data Ingestion → Upload files** into `workspace.crypto_market.listings`.

### Step 2: Run dbt transformations
```bash
cd dbt_workspace/market_Trans
dbt debug        # verify connection
dbt build        # run all models and tests
```

---

## Data Quality Tests

| Test | Model | Type | Description |
|---|---|---|---|
| `unique` | stg_crypto.id | Schema test | No duplicate coin IDs |
| `not_null` | stg_crypto.price_usd | Schema test | No missing prices |
| `not_null` | stg_crypto.market_cap_usd | Schema test | No missing market caps |
| `accepted_values` | stg_crypto.price_trend | Schema test | Only gaining/losing/stable |
| `assert_price_above_zero` | stg_crypto | Custom test | Flags zero price coins |

---

## dbt Models

### Staging
| Model | Materialization | Description |
|---|---|---|
| `stg_crypto` | Ephemeral | Cleans raw listings, adds price_trend |

### Marts
| Model | Materialization | Description |
|---|---|---|
| `crypto_top10` | Table | Top 10 coins by market capitalisation |
| `crypto_bottom10` | Table | 10 worst performing coins by 24h change |
| `crypto_gainers` | Table | All coins with positive 24h change |
| `crypto_losers` | Table | All coins with negative 24h change |
| `crypto_market_summary` | Table | Aggregated market statistics |

### Reports
| Model | Materialization | Description |
|---|---|---|
| `crypto_report` | View | Top 10 coins with market dominance % |

---

## Known Limitations

- **Databricks Free Edition** does not support automated scheduling — the pipeline is run manually. A future iteration will use **Apache Airflow** to schedule daily runs automatically.
- Data is loaded via CSV upload due to connection timeout limitations on the free tier. A future iteration will use **Spark DataFrame direct write** for a fully automated load.
- Some coins legitimately have a $0.00 price (very low value/inactive coins) — this is flagged as a warning in the custom test rather than an error.

---

## Future Improvements

- [ ] Add Apache Airflow for pipeline scheduling
- [ ] Implement Spark direct write to replace CSV upload
- [ ] Add historical data storage for trend analysis
- [ ] Connect to Power BI or Databricks dashboard for visualisation
- [ ] Containerise with Docker
- [ ] Deploy on Azure with Databricks premium tier

---

## Author

**Abdussamad**
- Built as part of a data engineering portfolio
- Tools: Python · dbt · Databricks · SQL

---

## License

This project is for portfolio and educational purposes.
