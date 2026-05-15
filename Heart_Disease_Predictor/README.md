# 🫀 Heart Disease Prediction — Random Forest Classifier

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python&logoColor=white)
![Scikit-learn](https://img.shields.io/badge/Scikit--learn-ML%20Framework-F7931E?logo=scikitlearn&logoColor=white)
![Kaggle](https://img.shields.io/badge/Kaggle-Playground%20S6E2-20BEFF?logo=kaggle&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Processing-150458?logo=pandas&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> A supervised classification project built for the **Kaggle Playground Series Season 6, Episode 2** competition. Five Random Forest configurations are evaluated against a validation set, with the best model retrained on the full dataset to generate competition predictions.

---

## 📌 Problem Statement

Cardiovascular disease is one of the leading causes of death globally. This project explores whether clinical features — such as chest pain type, maximum heart rate, and ST depression — can reliably predict the presence or absence of heart disease using a Random Forest classifier.

The dataset is sourced from the Kaggle Playground Series (S6E2), a synthetically generated competition dataset derived from the UCI Heart Disease dataset.

---

## 🗂️ Dataset

| Detail | Value |
|--------|-------|
| Competition | Kaggle Playground Series — Season 6, Episode 2 |
| Train file | `train.csv` |
| Test file | `test.csv` |
| Target column | `Heart Disease` (`Absence` → `0`, `Presence` → `1`) |
| Encoding | `LabelEncoder` from `sklearn.preprocessing` |

🔗 [Competition page](https://www.kaggle.com/competitions/playground-series-s6e2)

---

## 🧬 Features

13 clinical features plus the record identifier are used as predictors:

| Feature | Description |
|---------|-------------|
| `id` | Record identifier |
| `Age` | Patient age in years |
| `Sex` | Patient sex |
| `Chest pain type` | Type of chest pain reported |
| `BP` | Resting blood pressure |
| `Cholesterol` | Serum cholesterol (mg/dl) |
| `FBS over 120` | Fasting blood sugar > 120 mg/dl (1=True, 0=False) |
| `EKG results` | Resting electrocardiographic results |
| `Max HR` | Maximum heart rate achieved |
| `Exercise angina` | Exercise-induced angina (1=Yes, 0=No) |
| `ST depression` | ST depression induced by exercise relative to rest |
| `Slope of ST` | Slope of the peak exercise ST segment |
| `Number of vessels fluro` | Number of major vessels colored by fluoroscopy |
| `Thallium` | Thallium stress test result |

---

## 🛠️ Tech Stack

| Purpose | Library |
|---------|---------|
| Data processing | `pandas`, `numpy` |
| Train/validation split | `sklearn.model_selection.train_test_split` |
| Target encoding | `sklearn.preprocessing.LabelEncoder` |
| Classification | `sklearn.ensemble.RandomForestClassifier` |
| Evaluation | `sklearn.metrics.accuracy_score` |

---

## 📁 Project Structure

```
heart-disease-ml-random-forest/
├── heart_disease_rf.py        # Main script — model training, evaluation, submission
├── requirements.txt           # Python dependencies
│
├── notebooks/
│   └── heart_disease_rf.ipynb # Kaggle notebook version (recommended for running)
│
├── data-sample/
│   └── train_sample.csv       # Sample rows for reference (not full competition data)
│
└── reports/
    └── submission.csv         # Output predictions — id + Heart Disease
```

> **Note:** Full competition data (`train.csv`, `test.csv`) must be downloaded directly from the [Kaggle competition page](https://www.kaggle.com/competitions/playground-series-s6e2/data). It cannot be included in this repo.

---

## ⚙️ Setup & Installation

### Prerequisites
- Python 3.9+ or a Kaggle notebook environment
- Kaggle account (to access competition data)

### Local Installation

```bash
git clone https://github.com/Albert-Lade/Portfolio.git
cd Portfolio/heart-disease-ml-random-forest
pip install -r requirements.txt
```

**`requirements.txt`**
```
numpy
pandas
scikit-learn
```

> **Recommended:** Run this project directly in a [Kaggle notebook](https://www.kaggle.com/competitions/playground-series-s6e2/code) — the data paths are pre-configured for the Kaggle environment (`/kaggle/input/competitions/playground-series-s6e2/`).

---

## 🔬 How It Works

### Step 1 — Load & Encode

Data is loaded from the Kaggle input directory. The `Heart Disease` target column is label-encoded from string values to binary integers:

```python
le = LabelEncoder()
X_full['Heart Disease'] = le.fit_transform(X_full['Heart Disease'])
# Absence → 0, Presence → 1
```

### Step 2 — Feature Selection & Split

13 clinical features plus `id` are selected. Data is split 80/20 into training and validation sets:

```python
features = ['id', 'Age', 'Sex', 'Chest pain type', 'BP', 'Cholesterol',
            'FBS over 120', 'EKG results', 'Max HR', 'Exercise angina',
            'ST depression', 'Slope of ST', 'Number of vessels fluro', 'Thallium']

X_train, X_val, y_train, y_val = train_test_split(
    X, y, train_size=0.8, test_size=0.2, random_state=0
)
```

### Step 3 — Model Comparison

Five `RandomForestClassifier` configurations are evaluated using a `score_model()` function that fits on the training split and scores on the validation split:

```python
def score_model(model, X_t=X_train, X_v=X_val, y_t=y_train, y_v=y_val):
    model.fit(X_t, y_t)
    preds = model.predict(X_v)
    return accuracy_score(y_v, preds)
```

| Model | Configuration | Notes |
|-------|--------------|-------|
| Model 1 | `n_estimators=50` | Baseline — small forest |
| Model 2 | `n_estimators=100` | Standard configuration |
| Model 3 | `n_estimators=100, criterion='log_loss'` | Alternate split criterion |
| Model 4 | `n_estimators=200, min_samples_split=20` | ✅ **Best accuracy** |
| Model 5 | `n_estimators=100, max_depth=7` | Depth-constrained tree |

All models use `random_state=0` and `n_jobs=-1` (full CPU parallelism).

### Step 4 — Final Model & Submission

Model 4 is selected as the best performer and retrained on the **full dataset** (train + validation combined) before generating test predictions:

```python
model_4.fit(X, y)
preds_test = model_4.predict(X_test)

output = pd.DataFrame({
    'id': X_test['id'],
    'Heart Disease': preds_test
})
output.to_csv('submission.csv', index=False)
```

---

## 📊 Model Configuration — Winner

```python
RandomForestClassifier(
    n_estimators=200,      # 200 decision trees in the ensemble
    min_samples_split=20,  # Requires 20 samples to split a node — controls overfitting
    random_state=0,        # Reproducible results
    n_jobs=-1              # Uses all available CPU cores
)
```

The `min_samples_split=20` constraint prevents the trees from memorizing the training data by requiring a meaningful number of samples before any node split — an effective regularization strategy for this dataset size.

---

## 🔮 Future Improvements

- [ ] Add `GridSearchCV` or `RandomizedSearchCV` for systematic hyperparameter tuning
- [ ] Include feature importance plot to identify top clinical predictors
- [ ] Evaluate additional metrics beyond accuracy: ROC-AUC, precision, recall, F1
- [ ] Test additional classifiers: XGBoost, Logistic Regression, SVM for comparison baseline
- [ ] Add a confusion matrix visualization to understand error patterns
- [ ] Apply cross-validation (`StratifiedKFold`) instead of a single train/val split

---

## ⚠️ Disclaimer

This project is built for a **Kaggle competition and portfolio purposes only**. It is not intended for clinical use and should not be used to inform any medical decisions. Always consult a qualified healthcare professional for medical advice.

---

## 👤 Author

**Albert Lade** — Data Analyst & Engineer  
📍 Eugene, OR  
🔗 [GitHub](https://github.com/Albert-Lade) · [LinkedIn](https://www.linkedin.com/in/albert-lade)  
📁 [Full Portfolio](https://github.com/Albert-Lade/Portfolio)

---

*Part of the [Albert-Lade/Portfolio](https://github.com/Albert-Lade/Portfolio) monorepo.*
