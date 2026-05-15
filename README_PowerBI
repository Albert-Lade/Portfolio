# 📊 Power BI Sales Performance Dashboard

![Power BI](https://img.shields.io/badge/Power%20BI-Desktop%20%26%20Service-F2C811?logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-Measures%20%26%20KPIs-0078D4)
![SQL Server](https://img.shields.io/badge/Data%20Source-SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white)
![Power Query](https://img.shields.io/badge/Power%20Query-ETL%20%26%20Transform-green)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> An interactive Power BI dashboard connected live to SQL Server, replacing manual weekly Excel reporting with real-time salesperson performance tracking — Sales vs. Target, trend analysis, and department-level drill-through — secured with Row-Level Security.

---

## 📌 Problem Statement

Business teams lacked real-time visibility into sales performance. Reports were compiled manually in Excel on a weekly basis from SQL Server exports, resulting in stale data, inconsistency across teams, and delayed decision-making. Leadership had no way to self-serve answers — every question required an analyst.

This dashboard replaced that entire workflow with a live, interactive report requiring zero manual effort to refresh.

---

## 📸 Dashboard Preview

![Sales vs Target Table](reports/sales-vs-target-table.png)

> *Salesperson performance table showing individual Sales and Target figures, powered by the `Target` DAX measure and `Salesperson (Performance)` table.*

*(Additional screenshots in the `/reports` folder)*

---

## ✨ Features

- **Live SQL Server connection** — data refreshes automatically daily via Power BI Service
- **Sales vs. Target tracking** — per-salesperson breakdown with `HASONEVALUE` context control
- **Time intelligence** — period-over-period comparisons using `SAMEPERIODLASTYEAR` and `DATESINPERIOD`
- **Row-Level Security (RLS)** — each department sees only its own data
- **Drill-through pages** — click any salesperson or department to see granular detail
- **Mobile-responsive layout** — optimized for field team access on smaller screens
- **Star schema data model** — clean separation of fact and dimension tables for performance

---

## 🛠️ Tech Stack

| Layer | Tool |
|-------|------|
| Visualization & Reporting | Power BI Desktop, Power BI Service |
| Data Modeling | Star Schema (Fact + Dimension tables) |
| Measures & KPIs | DAX |
| Data Transformation | Power Query (M) |
| Data Source | SQL Server |
| Security | Row-Level Security (RLS) |

---

## 📁 Project Structure

```
powerbi-operational-dashboards/
├── README.md
│
└── reports/
    ├── sales-vs-target-table.png      # Salesperson Sales vs Target table visual
    ├── executive-summary.png          # Executive KPI summary page
    ├── trend-analysis.png             # Period-over-period trend charts
    ├── department-comparison.png      # Cross-department comparison view
    └── goal-vs-actual.png             # Goal vs Actual tracker page
```

> **Note:** Power BI `.pbix` files cannot be shared publicly due to embedded SQL Server credentials and proprietary data. This repo documents the project through screenshots, DAX measures, and data model documentation.

---

## 🗂️ Data Model

The report is built on a **star schema** with a central fact table connected to dimension tables:

```
                    ┌─────────────────────────┐
                    │  Salesperson (Performance)│  ← Dimension
                    │  [Salesperson]            │
                    └────────────┬────────────-┘
                                 │
        ┌────────────────────────▼──────────────────────────┐
        │                   Fact: Sales                      │
        │  [SalesAmount] [Date] [SalespersonKey] [Region]    │
        └────────────┬──────────────────────────────────────┘
                     │
              ┌──────▼──────┐
              │   Targets    │  ← Dimension
              │[TargetAmount]│
              └─────────────┘
```

---

## 📐 DAX Measures

### Target
Calculates the target amount only when a single salesperson is in context — prevents incorrect aggregation in cross-filtered visuals.

```dax
Target =
IF(
    HASONEVALUE('Salesperson (Performance)'[Salesperson]),
    SUM(Targets[TargetAmount])
)
```

### Sales (Year-over-Year Comparison)
```dax
Sales PY =
CALCULATE(
    [Sales],
    SAMEPERIODLASTYEAR('Date'[Date])
)
```

### Rolling 3-Month Sales
```dax
Sales Rolling 3M =
CALCULATE(
    [Sales],
    DATESINPERIOD('Date'[Date], LASTDATE('Date'[Date]), -3, MONTH)
)
```

### Goal Achievement %
```dax
Goal Achievement % =
DIVIDE([Sales], [Target], 0)
```

---

## 📋 Report Pages

| Page | Description |
|------|-------------|
| **Executive Summary** | Top-level KPI cards — total Sales, Target, Achievement %, and period delta |
| **Sales vs. Target** | Salesperson table with individual Sales and Target columns (shown in screenshot) |
| **Trend Analysis** | Line charts with rolling averages and year-over-year overlays |
| **Department Comparison** | Bar charts comparing performance across departments |
| **Drill-through Detail** | Right-click any salesperson to drill into transaction-level detail |

---

## 🔒 Row-Level Security (RLS)

RLS roles are defined in Power BI Desktop and enforced in Power BI Service. Each department manager sees only their team's data. Admins and executives see the full dataset.

| Role | Data Scope |
|------|-----------|
| `Department_Manager` | Filtered to their department only |
| `Executive` | All departments |
| `Admin` | Full unfiltered dataset |

---

## 🔗 Data Source — SQL Server

The report connects directly to SQL Server via DirectQuery / Import mode. The key tables used are:

| Table | Description |
|-------|-------------|
| `Salesperson (Performance)` | Salesperson dimension with names and hierarchy |
| `Targets` | Target amounts by salesperson and period (`TargetAmount`) |
| `Sales` | Fact table with transaction-level sales data |
| `Date` | Date dimension for time intelligence functions |

---

## ☁️ Power BI Service Deployment

The report is published to Power BI Service with:
- **Scheduled refresh:** Daily automatic data refresh from SQL Server
- **Workspace sharing:** Report shared to relevant stakeholders via workspace access
- **Mobile layout:** Configured for responsive display on Power BI Mobile app

---

## 📈 Results & Impact

| Metric | Outcome |
|--------|---------|
| Manual Excel reports replaced | 5+ weekly reports consolidated into one dashboard |
| Time-to-insight | Reduced from 5–7 days to real-time |
| Self-serve adoption | Leadership can answer their own questions without analyst involvement |
| Data consistency | Single source of truth — no more conflicting Excel versions |
| Access control | RLS ensures each team sees only relevant data |

---

## 🔮 Future Improvements

- [ ] Add forecasting visuals using Power BI's built-in AI forecast ribbon
- [ ] Connect to Azure SQL for cloud-native refresh without gateway dependency
- [ ] Build a Decomposition Tree visual for root-cause analysis on underperforming territories
- [ ] Add anomaly detection on the trend page using Power BI's smart narrative feature

---

## 👤 Author

**Albert Lade** — Data Analyst & Engineer  
📍 Eugene, OR  
🔗 [GitHub](https://github.com/Albert-Lade) · [LinkedIn](https://www.linkedin.com/in/albert-lade)  
📁 [Full Portfolio](https://github.com/Albert-Lade/Portfolio)

---

*Part of the [Albert-Lade/Portfolio](https://github.com/Albert-Lade/Portfolio) monorepo.*
