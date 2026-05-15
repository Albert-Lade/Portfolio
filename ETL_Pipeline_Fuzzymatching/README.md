# 🔄 ETL Pipeline with Fuzzy Matching & Data Cleaning

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Processing-150458?logo=pandas&logoColor=white)
![RapidFuzz](https://img.shields.io/badge/RapidFuzz-Fuzzy%20Matching-orange)
![SQL](https://img.shields.io/badge/SQL-Data%20Loading-4479A1?logo=postgresql&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> A modular, production-ready ETL pipeline that ingests multi-source data, standardizes and deduplicates records using fuzzy string matching, and loads clean output to a target database — with full audit logging.

---

## 📌 Problem Statement

Operational databases frequently contain duplicate, inconsistent, or misspelled records — particularly customer names, addresses, and product identifiers — leading to inaccurate reporting and flawed downstream analysis. Manual reconciliation is time-consuming, error-prone, and impossible to scale.

This pipeline solves that by automating the detection and resolution of near-duplicate records across datasets with no exact matching key.

---

## ✨ Features

- **Multi-source ingestion** — reads from CSV, Excel, and SQL databases
- **Field normalization** — regex-based cleaning, whitespace trimming, case standardization
- **Fuzzy deduplication** — token-based scoring via RapidFuzz to catch name transpositions, abbreviations, and misspellings
- **Blocking strategy** — reduces O(n²) comparison complexity for large datasets
- **Configurable thresholds** — tune precision vs. recall per use case via YAML config
- **Audit log output** — borderline matches flagged for human review before final load
- **Modular design** — reusable across different data domains without code changes

---

## 🛠️ Tech Stack

| Layer | Tool / Library |
|-------|---------------|
| Language | Python 3.9+ |
| Data Processing | Pandas, NumPy |
| Fuzzy Matching | RapidFuzz |
| Database I/O | SQLAlchemy, psycopg2 |
| Config Management | PyYAML |
| Logging | Python `logging` module |
| Testing | pytest |

---

## 📁 Project Structure

```
etl-fuzzy-matching-pipeline/
├── run_pipeline.py          # Main entry point
├── config.yaml              # Pipeline configuration (thresholds, paths, DB connection)
├── requirements.txt         # Python dependencies
│
├── src/
│   ├── ingest.py            # Data ingestion from CSV, Excel, SQL
│   ├── normalize.py         # Field cleaning and standardization logic
│   ├── match.py             # Fuzzy matching and deduplication engine
│   ├── load.py              # Target database loader
│   └── audit.py             # Audit log writer
│
├── data-sample/
│   └── sample_customers.csv # Anonymized sample input data
│
├── tests/
│   ├── test_normalize.py
│   └── test_match.py
│
└── reports/
    └── audit_log_sample.csv # Example borderline match audit output
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Python 3.9+
- PostgreSQL or SQL Server (for database source/target, optional)
- pip

### Install Dependencies

```bash
git clone https://github.com/Albert-Lade/Portfolio.git
cd Portfolio/etl-fuzzy-matching-pipeline
pip install -r requirements.txt
```

### Configure the Pipeline

Edit `config.yaml` to set your source paths, database credentials, and matching thresholds:

```yaml
source:
  type: csv                          # csv | excel | sql
  path: data-sample/sample_customers.csv

target:
  type: sql
  connection_string: postgresql://user:pass@localhost/mydb
  table: customers_clean

matching:
  score_threshold: 85                # Minimum score to consider a match (0–100)
  audit_threshold: 75                # Scores between this and score_threshold go to audit log
  blocking_key: postal_code          # Field used to limit comparison scope

output:
  audit_log_path: reports/audit_log.csv
```

---

## 🚀 Usage

```bash
# Run with default config
python run_pipeline.py --config config.yaml

# Dry run — preview matches without writing to target
python run_pipeline.py --config config.yaml --dry-run

# Run against production environment config
python run_pipeline.py --config config.yaml --env prod
```

---

## 🔬 How It Works

The pipeline executes in five stages:

```
1. EXTRACT      →   Ingest raw data from CSV / Excel / SQL source
2. NORMALIZE    →   Lowercase, strip whitespace, expand abbreviations, regex clean
3. BLOCK        →   Group records by a shared key (e.g. postal code) to limit comparisons
4. MATCH        →   Score pairs using token_sort_ratio + partial_ratio (RapidFuzz)
5. LOAD         →   Write deduplicated records to target; flag borderline matches to audit log
```

### Fuzzy Scoring Strategy

| Score Range | Action |
|-------------|--------|
| ≥ 85 | Auto-merge as duplicate |
| 75 – 84 | Flag in audit log for human review |
| < 75 | Treat as distinct records |

Both `token_sort_ratio` (handles word order differences) and `partial_ratio` (handles substrings and abbreviations) are applied, and the higher score is used for the final decision.

---

## 📊 Results & Impact

| Metric | Outcome |
|--------|---------|
| Duplicate records eliminated | ~80% reduction in target database |
| Manual reconciliation time | Reduced from several hours/week to near-zero |
| Pipeline reusability | Applied across multiple departments and data domains |
| Audit coverage | 100% of borderline matches logged for review |

---

## 🗂️ Sample Audit Log Output

```csv
record_id_a,record_id_b,name_a,name_b,score,action
1042,2187,John Smith,Smith John,88,AUTO_MERGED
3301,3455,Acme Corp,Acme Corporation,79,FLAGGED_FOR_REVIEW
0891,1204,Jane Doe,Jan Doe,71,DISTINCT
```

---

## 🔮 Future Improvements

- [ ] Add support for API-based data sources
- [ ] Extend blocking to multi-key strategies (e.g. postal code + first letter of name)
- [ ] Build a lightweight Streamlit UI to review audit log matches interactively
- [ ] Add unit test coverage to > 90%

---

## 👤 Author

**Albert Lade** — Data Analyst & Engineer  
📍 Eugene, OR  
🔗 [GitHub](https://github.com/Albert-Lade) · [LinkedIn](https://www.linkedin.com/in/albert-lade)  
📁 [Full Portfolio](https://github.com/Albert-Lade/Portfolio)

---

*Part of the [Albert-Lade/Portfolio](https://github.com/Albert-Lade/Portfolio) monorepo.*
