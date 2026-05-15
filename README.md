# 📂 Albert Lade — Data Portfolio

![Python](https://img.shields.io/badge/Python-Data%20Engineering%20%26%20ML-blue?logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Validation%20%26%20Analysis-4479A1?logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboards%20%26%20DAX-F2C811?logo=powerbi&logoColor=black)
![Scikit-learn](https://img.shields.io/badge/Scikit--learn-Machine%20Learning-F7931E?logo=scikitlearn&logoColor=white)
![Kaggle](https://img.shields.io/badge/Kaggle-Competition%20Projects-20BEFF?logo=kaggle&logoColor=white)

> Transforming raw data into decisions — through pipelines, dashboards, machine learning, and automation.

---

## 👤 About Me

I'm a data analyst and engineer based in Eugene, OR. My journey into data started when a friend introduced me to Python — and from that moment I never looked back. I specialize in building end-to-end data solutions: from ingestion pipelines and automated reporting to executive-facing dashboards and predictive models. I thrive at the intersection of engineering and analytics, turning messy, real-world data into reliable, actionable insights.

📍 Eugene, OR &nbsp;·&nbsp; 🔗 [LinkedIn](https://www.linkedin.com/in/albert-lade) &nbsp;·&nbsp; 💻 [GitHub](https://github.com/Albert-Lade)

---

## 🗂️ Projects

| # | Project | Domain | Core Tools | Key Result |
|---|---------|--------|-----------|------------|
| 1 | [ETL Pipeline with Fuzzy Matching](#1--etl-pipeline-with-fuzzy-matching) | Data Engineering | Python, RapidFuzz, Pandas, SQL | ~80% duplicate reduction |
| 2 | [Power BI Sales Performance Dashboard](#2--power-bi-sales-performance-dashboard) | Business Intelligence | Power BI, DAX, SQL Server | Replaced 5+ manual weekly reports |
| 3 | [Heart Disease Prediction — Random Forest](#3--heart-disease-prediction--random-forest) | Machine Learning | Scikit-learn, Pandas, NumPy | Best model: 200 trees, min_samples_split=20 |
| 4 | [Commission Reporting Automation](#4--commission-reporting-automation) | Financial Automation | Python, Pandas, xlsxwriter | 8 hrs → 30 min per pay cycle |
| 5 | [SQL Data Validation Framework](#5--sql-data-validation-framework) | Data Quality | SQL, PostgreSQL, Python | ~70% reduction in data incidents |

---

## 1 · ETL Pipeline with Fuzzy Matching

**Notebook:** [`ETL Pipeline_Fuzzymatching.ipynb`](etl-fuzzy-matching-pipeline/ETL%20Pipeline_Fuzzymatching.ipynb)  
**Folder:** [`etl-fuzzy-matching-pipeline/`](etl-fuzzy-matching-pipeline/)

A modular Python ETL pipeline that ingests data from multiple sources, standardizes and cleans records, and applies fuzzy string matching (RapidFuzz) to deduplicate entries with no exact matching key. Configurable similarity thresholds, blocking strategies, and full audit logging make it production-ready and reusable across domains.

**Highlights**
- `token_sort_ratio` + `partial_ratio` scoring handles name transpositions and abbreviations
- Blocking strategy reduces O(n²) comparison complexity on large datasets
- Borderline matches flagged to an audit log for human review before final load
- Pipeline config driven by `config.yaml` — no code changes needed to switch data domains

**Impact:** Reduced duplicate records by ~80% · Eliminated hours of manual weekly reconciliation

🔗 [View full README](etl-fuzzy-matching-pipeline/README.md)

---

## 2 · Power BI Sales Performance Dashboard

**File:** `10-Solution-Sales Analysis.pbix` *(not shareable — embedded SQL Server credentials)*  
**Folder:** [`powerbi-operational-dashboards/`](powerbi-operational-dashboards/)

An interactive Power BI dashboard connected live to SQL Server, replacing manual Excel reporting with real-time salesperson performance tracking. Built on a star schema data model with DAX measures for Sales vs. Target analysis, time intelligence, and period-over-period comparison. Secured with Row-Level Security by department.

**Highlights**
- `Target` measure uses `HASONEVALUE` to prevent incorrect aggregation across filter contexts
- Time intelligence via `SAMEPERIODLASTYEAR` and `DATESINPERIOD`
- Row-Level Security (RLS) scopes data visibility by department and role
- Published to Power BI Service with automated daily refresh from SQL Server

**Key DAX Measure**
```dax
Target =
IF(
    HASONEVALUE('Salesperson (Performance)'[Salesperson]),
    SUM(Targets[TargetAmount])
)
```

**Impact:** 5+ weekly Excel reports replaced · Time-to-insight reduced from 5–7 days to real-time

🔗 [View full README](powerbi-operational-dashboards/README.md)

---

## 3 · Heart Disease Prediction — Random Forest

**Notebook:** [`Heart_Disease.ipynb`](heart-disease-ml-random-forest/Heart_Disease.ipynb)  
**Folder:** [`heart-disease-ml-random-forest/`](heart-disease-ml-random-forest/)  
**Competition:** [Kaggle Playground Series — Season 6, Episode 2](https://www.kaggle.com/competitions/playground-series-s6e2)

A supervised classification project that predicts heart disease presence or absence from 13 clinical features. Five Random Forest configurations are evaluated against a validation split, with the best model retrained on the full dataset to generate competition predictions.

**Highlights**
- `LabelEncoder` used to encode target: `Absence → 0`, `Presence → 1`
- 80/20 train/validation split with `random_state=0` for reproducibility
- 5 models compared — winner: `n_estimators=200, min_samples_split=20`
- `min_samples_split=20` prevents overfitting by requiring meaningful sample depth before node splits
- Output: `submission.csv` with `id` + `Heart Disease` predictions

**Models Evaluated**

| Model | Configuration |
|-------|--------------|
| Model 1 | `n_estimators=50` |
| Model 2 | `n_estimators=100` |
| Model 3 | `n_estimators=100, criterion='log_loss'` |
| **Model 4** ✅ | **`n_estimators=200, min_samples_split=20`** |
| Model 5 | `n_estimators=100, max_depth=7` |

> ⚠️ *Academic/portfolio project — not intended for clinical use.*

🔗 [View full README](heart-disease-ml-random-forest/README.md)

---

## 4 · Commission Reporting Automation

**Notebook:** [`Comissions_report.ipynb`](commission-reporting-automation/Comissions_report.ipynb)  
**Folder:** [`commission-reporting-automation/`](commission-reporting-automation/)

A Python automation script that ingests three Salesforce CSV exports (Payment, Subscription, Commission), reconciles and cleans the data, calculates referral partner commissions at a 30% rate, handles CAD → USD currency conversion, and outputs a formatted Excel report — all in a single run.

**Highlights**
- Regex parser resolves a Salesforce export bug where `Product Name` is wrapped in raw HTML anchor tags
- Filters to commissionable products: `PlanSwift Professional` and `PlanSwift Plugins`
- CAD → USD conversion applied automatically via configurable exchange rate
- `xlsxwriter` generates a styled, audit-ready Excel report with two tables: full detail + Referral Partner summary
- Column rename dictionary (`col_name_change`) makes schema updates easy to maintain

**Impact:** Processing time reduced from ~8 hours to under 30 minutes per cycle · Calculation errors eliminated

🔗 [View full README](commission-reporting-automation/README.md)

---

## 5 · SQL Data Validation Framework

**Folder:** [`sql-data-validation-framework/`](sql-data-validation-framework/)

A metadata-driven suite of reusable SQL validation checks that run automatically after every pipeline load. Covers five dimensions of data quality — Completeness, Uniqueness, Validity, Consistency, and Timeliness — with results logged to a `validation_results` table and failures routed to alerts via a Python orchestrator.

**Highlights**
- Validation rules stored in a metadata table — no hardcoded logic, no script edits to add a new check
- Python `orchestrator.py` runs all checks post-load and routes failures to the appropriate team
- `data_quality_summary` SQL view powers a live monitoring dashboard
- Framework reused across 4+ data pipelines with no modifications

**Impact:** ~70% reduction in data incidents reaching production · Eliminated "I don't trust this number" from stakeholder conversations

🔗 [View full README](sql-data-validation-framework/README.md)

---

## 🧰 Skills & Tools

| Category | Tools |
|----------|-------|
| **Languages** | Python, SQL |
| **Libraries** | Pandas, NumPy, Scikit-learn, RapidFuzz, xlsxwriter, re |
| **BI & Visualization** | Power BI, DAX, Power Query |
| **Databases** | PostgreSQL, SQL Server |
| **ML & Modeling** | Random Forest, LabelEncoder, train_test_split, accuracy_score |
| **Platforms** | Kaggle, Power BI Service, GitHub |
| **Other** | ETL Design, Data Quality, Financial Automation, Star Schema Modeling |

---

## 📬 Connect

I'm always open to data roles, collaborations, or just talking shop.

- 🔗 [LinkedIn](https://www.linkedin.com/in/albert-lade)
- 💻 [GitHub](https://github.com/Albert-Lade)
- 📍 Eugene, OR
