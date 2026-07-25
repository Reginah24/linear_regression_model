# Agaseke Savings Predictor

## Mission & Problem
AGASEKE helps African youth build disciplined savings habits through goal-based planning
and accountable withdrawal control. Many young Africans face low financial literacy and
weak emergency safety nets; this project predicts expected monthly savings from income,
expenses, and demographics to help identify users needing extra support.

## Dataset
- Source: [Personal Finance ML Dataset on Kaggle](https://www.kaggle.com/datasets/miadul/personal-finance-ml-dataset)
- Size: 32,424 rows, 20 columns
- Type: Synthetic personal finance data covering demographics, income, expenses, loans, and region
- Target: `savings_usd`

## Notebook
[summative/linear_regression/multivariate.ipynb](summative/linear_regression/multivariate.ipynb)

Covers: data cleaning with reasoning, leakage check, feature engineering, correlation heatmap,
distribution plots, one-hot encoding, standardization, comparison of 4 regression models,
loss curve, actual-vs-predicted scatter plot, saved model, and a sample prediction.

## Models Compared

| Model | MSE | R² |
|---|---:|---:|
| SGD Regressor (gradient descent) | 23,904,782,381.62 | 0.3522 |
| Gradient Boosting Regressor | 24,042,728,499.15 | 0.3485 |
| Random Forest Regressor | 24,854,143,512.06 | 0.3265 |
| Decision Tree Regressor | 47,264,804,867.24 | -0.2808 |

**Best model: SGD Regressor** — lowest loss, highest R², stable convergence, and a good fit
given that savings has a mostly linear relationship with income and expenses.

## Saved Artifacts
- Model: `summative/linear_regression/best_savings_model.pkl` (also duplicated in `summative/API/`)
- Scaler: `summative/linear_regression/scaler_v2.pkl` (also duplicated in `summative/API/`)

## API
[summative/API/prediction.py](summative/API/prediction.py)

**Live Swagger UI:** https://linear-regression-model-ambx.onrender.com/docs

### Endpoints
- `GET /` — service status
- `POST /predict` — returns a predicted savings value for one set of inputs
- `POST /retrain` — accepts a CSV upload and retrains the saved model with `partial_fit`

### Input Validation (Pydantic)
- `age`: integer, 18–100
- `monthly_income_usd`: float, 0–50000
- `monthly_expenses_usd`: float, 0–50000
- `debt_to_income_ratio`: float, 0–100
- `gender`, `education_level`, `employment_status`, `has_loan`, `region`: string, restricted to expected categories

### CORS
No wildcard origin is used. Allowed origins are limited to local testing and the deployed URL,
since the Flutter mobile app itself doesn't go through browser CORS — only Swagger UI testing does.

- Allowed origins: `http://127.0.0.1:8000`, `http://localhost:8000`, `https://linear-regression-model-ambx.onrender.com`
- Allowed methods: `GET`, `POST`
- Allowed headers: `Content-Type`

## Flutter App
[summative/FlutterApp/lib/main.dart](summative/FlutterApp/lib/main.dart)

A single-page app with 9 input fields (matching the API schema), a Predict button, and a
result/error display area. Sends a POST request to the deployed API and shows the response.

### Running the App
```bash
cd summative/FlutterApp
flutter pub get
flutter run
```
Requires an emulator or connected device. [Install Flutter](https://docs.flutter.dev/get-started/install) if needed.

## Running the API Locally
```bash
uv sync
cd summative/API
uv run uvicorn prediction:app --host 0.0.0.0 --port 8000 --reload
```
Then visit `http://127.0.0.1:8000/docs`.

## Video Demo
[Watch the demo video](https://youtu.be/hg9T_qG7_Cw)
