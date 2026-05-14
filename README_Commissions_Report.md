# 💰 Commission Reporting Automation

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Processing-150458?logo=pandas&logoColor=white)
![xlsxwriter](https://img.shields.io/badge/xlsxwriter-Excel%20Output-217346?logo=microsoft-excel&logoColor=white)
![Salesforce](https://img.shields.io/badge/Data%20Source-Salesforce-00A1E0?logo=salesforce&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> A Python script that ingests three Salesforce CSV exports, calculates referral partner commissions at a 30% rate, handles CAD → USD currency conversion, and produces a formatted, audit-ready Excel report — automatically.

---

## 📌 Problem Statement

Commission calculations for referral partners were performed manually each pay period — requiring analysts to reconcile three separate Salesforce reports, apply currency conversions, calculate payouts, and format everything in Excel by hand. The process was time-consuming, error-prone, and difficult to audit.

A further complication: Salesforce's export of the Subscription report embeds product names inside raw HTML anchor tags (`<a href="...">Product Name</a>`), making the `Product Name` field unusable without preprocessing.

This script eliminates all of that — ingesting, cleaning, merging, calculating, and formatting the final report in a single run.

---

## ✨ What It Does

1. **Ingests** three Salesforce CSV exports — `Payment.csv`, `Subscription.csv`, and `Commission.csv`
2. **Parses** HTML-embedded product names from `Subscription.csv` using regex
3. **Filters** the commission report to accounts with a `Referral Partner` assigned
4. **Merges** all three reports on `Account Name`
5. **Filters** to commissionable products: `PlanSwift Professional` and `PlanSwift Plugins`
6. **Converts** `Extended Amount` from CAD to USD where applicable (rate: `0.723526177`)
7. **Calculates** commission due at a flat **30% rate** per account
8. **Formats** `PlanSwift Customer ID` — prefixes `C`, removes float artifact (`.0`)
9. **Generates** a styled Excel report with two tables and report metadata

---

## 🛠️ Tech Stack

| Purpose | Library |
|---------|---------|
| Data processing & merging | `pandas` |
| Numeric operations & currency conversion | `numpy` |
| HTML product name extraction | `re` (standard library) |
| Excel report generation & formatting | `xlsxwriter` (via `pd.ExcelWriter`) |

---

## 📁 Project Structure

```
commission-reporting-automation/
├── commission_report.py          # Main script — run this each pay period
├── requirements.txt              # Python dependencies
│
├── data-sample/
│   ├── Payment_sample.csv        # Anonymized sample of Payment export
│   ├── Subscription_sample.csv   # Anonymized sample of Subscription export
│   └── Commission_sample.csv     # Anonymized sample of Commission export
│
└── reports/
    └── Referral_Partner_Commissions_Report.xlsx   # Example output
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Python 3.9+
- pip

### Install Dependencies

```bash
git clone https://github.com/Albert-Lade/Portfolio.git
cd Portfolio/commission-reporting-automation
pip install -r requirements.txt
```

**`requirements.txt`**
```
pandas
numpy
xlsxwriter
```

---

## 🔧 Configuration

Before running each pay period, update these hardcoded values at the top of `commission_report.py`:

| Variable | Location in Script | What to Update |
|----------|--------------------|----------------|
| `pay_df` path | Line 5 | Path to the new `Payment.csv` export |
| `sub_df` path | Line 8 | Path to the new `Subscription.csv` export |
| `com_df` path | Line 17 | Path to the new `Commission.csv` export |
| `ex` | Currency conversion block | Current CAD/USD exchange rate |
| `per_str` | Report metadata block | New pay period string (e.g. `"July 26 - August 25"`) |
| `commish_str` | Report metadata block | Commission rate if it ever changes (currently `"0.30"`) |

---

## 🚀 Usage

Export the three reports from Salesforce, update the file paths and period string in the script, then run:

```bash
python commission_report.py
```

The output file `Referral_Partner_Commissions_Report.xlsx` will be created in the working directory.

---

## 🔬 How It Works

### Step 1 — Salesforce HTML Fix
Salesforce inconsistently exports the `Product Name` field in `Subscription.csv` wrapped in an HTML anchor tag. The `extract_text()` function strips the tag and returns the clean product name:

```python
def extract_text(text):
    match = re.search(r'>(.*?)</a>', text)
    if match:
        return match.group(1)
    else:
        return None

sub_df['Product'] = sub_df['Product Name'].apply(extract_text)
```

### Step 2 — Filter & Merge
The Commission report is filtered to rows with a `Referral Partner` assigned, then all three DataFrames are merged on `Account Name`:

```python
com_df = com_df.dropna(subset='Referral Partner')
merged_df = com_df.merge(sub_df, on='Account Name').merge(pay_df, on='Account Name')
```

### Step 3 — Product Filter & Currency Conversion
Only `PlanSwift Professional` and `PlanSwift Plugins` rows are retained. CAD amounts are converted to USD:

```python
ex = 0.723526177
merged_df['Extended Amount'] = np.where(
    (merged_df['Extended Amount Currency'] == 'CAD'),
    merged_df['Extended Amount'] * ex,
    merged_df['Extended Amount']
)
```

### Step 4 — Commission Calculation
Amounts are summed per account, then a 30% commission column is applied:

```python
final_df['Commission Due (30%)'] = (final_df['Extended Amount'] * 0.3).round(2)
```

### Step 5 — Excel Report via `multiple_dfs()`
The `multiple_dfs()` function writes two tables to a single `'Commissions'` sheet using `xlsxwriter`:

- **Table 1** — `final_df`: full detail view, one row per account
- **Table 2** — `rf_grouped`: total `Commission Due (30%)` summed by `Referral Partner`

```python
dfs = [final_df, rf_grouped]
multiple_dfs(dfs, 'Commissions', 'Referral_Partner_Commissions_Report.xlsx', 1)
```

---

## 📊 Output Report Structure

**File:** `Referral_Partner_Commissions_Report.xlsx` → Sheet: `Commissions`

| Cell | Contents |
|------|----------|
| A1 | `Referral Partner Commission Report` (title) |
| A2 / B2 | `Period` / pay period string |
| A3 / B3 | `CAD/USD RATE` / rate value |
| A4 / B4 | `Commission Rate` / `0.30` |
| Row 5 | Column headers (bold, green `#D7E4BC`, bordered) |
| Row 6+ | `final_df` detail rows |
| Below detail | `rf_grouped` summary by Referral Partner |

**Final Column Order:**

| # | Column | Format |
|---|--------|--------|
| A | Created Date | — |
| B | Account Name | — |
| C | PlanSwift Customer ID | Prefixed with `C` |
| D | Referral Partner | — |
| E | Amount Currency | — |
| F | Amount | — |
| G | Close Date | `$#,###.##` |
| H | Stage | — |
| I | Commissionable Amount USD | — |
| J | Commission Due (30%) | `$#,###.##` |
| K | Payment Number | — |
| L | Payment Date | — |
| M | Payment Amount | `$#,###.##` |

---

## 📈 Results & Impact

| Metric | Outcome |
|--------|---------|
| Processing time per cycle | Reduced from ~8 hours to under 30 minutes |
| Calculation errors | Eliminated — commission math is consistent every run |
| Salesforce export bug | Automatically resolved via regex on every run |
| Currency handling | CAD → USD conversion applied automatically |
| Report format | Consistent, audit-ready Excel output every cycle |

---

## 🔮 Future Improvements

- [ ] Move file paths, exchange rate, and period string to a `config.yaml` for cleaner updates each cycle
- [ ] Add CLI arguments (`--period`, `--rate`, `--config`) to remove the need to edit the script
- [ ] Pull live CAD/USD exchange rate from an API instead of hardcoding
- [ ] Add input validation to catch missing or malformed CSV columns before processing fails
- [ ] Auto-distribute the report via email on completion

---

## 👤 Author

**Albert Lade** — Data Analyst & Engineer  
📍 Eugene, OR  
🔗 [GitHub](https://github.com/Albert-Lade) · [LinkedIn](https://www.linkedin.com/in/albert-lade)  
📁 [Full Portfolio](https://github.com/Albert-Lade/Portfolio)

---

*Part of the [Albert-Lade/Portfolio](https://github.com/Albert-Lade/Portfolio) monorepo.*
