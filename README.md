# Agaseke Savings Predictor

---

## Submission Requirements

### How to Submit
This repository contains all required files for the **Summative - First Model Deployment** assignment.

**You have two submission options:**
1. **Attempt 1:** Upload the ZIP file of this GitHub repo to Canvas
2. **Attempt 2:** Submit a link to this GitHub repository

### Required Files & Structure
All files are organized under this directory structure:

```
linear_regression_model/
├── pyproject.toml              ✅ Valid Python project configuration
├── uv.lock                     ✅ Dependency lock file (if using uv)
├── README.md                   ✅ This file
└── summative/
    ├── linear_regression/
    │   └── multivariate.ipynb  ✅ Jupyter notebook with analysis & model training
    ├── API/
    │   └── prediction.py       ✅ FastAPI backend for predictions
    └── FlutterApp/             ✅ Flutter mobile application
```

### Package Management
This project uses **`uv`** for package management and virtual environment management.

**Setup Instructions:**
```bash
# Install dependencies from pyproject.toml
uv sync

# Activate the virtual environment
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

---

## Mission
Agaseke is a regression-based mobile application that estimates a user's expected monthly savings from demographic and financial inputs. The use case is not generic and is not a house-price example. It focuses on personal finance and savings planning for young users who want a simple estimate of how income, spending, and loan pressure affect savings behavior.

## Dataset
- Source: [Personal Finance ML Dataset on Kaggle](https://www.kaggle.com/datasets/miadul/personal-finance-ml-dataset)
- Size: 32,424 rows and 20 columns
- Type: Synthetic but structured personal-finance data with demographic, income, expense, loan, and region features
- Target variable: `savings_usd`

The dataset is rich enough for regression analysis because it has both numeric and categorical variables, enough volume for train/test splitting, and enough variety to support encoding, scaling, model comparison, and feature selection.

## What The Notebook Covers
The notebook is in [summative/linear_regression/multivariate (1).ipynb](summative/linear_regression/multivariate%20(1).ipynb).

It includes:
- correlation heatmaps for feature analysis
- distribution plots for target and key variables
- scatter plots showing relationships between income and savings
- categorical encoding and feature scaling
- comparison of four regression approaches
- loss curves for SGD training
- a one-row prediction example from the test set

## Models Compared
The project compares stochastic linear regression against three other regression implementations using scikit-learn:

| Model | MSE | R2 |
| --- | ---: | ---: |
| SGD Regressor (linear regression via gradient descent) | 23,904,782,381.62 | 0.3522 |
| Gradient Boosting Regressor | 24,042,728,499.15 | 0.3485 |
| Random Forest Regressor | 24,854,143,512.06 | 0.3265 |
| Decision Tree Regressor | 47,264,804,867.24 | -0.2808 |

### Best Model
The best-performing model is the SGD Regressor. It achieved the lowest loss and the highest R2 score, so it was saved as the deployment model.

Why this model was selected:
- it performed best on the held-out test set
- the loss curve converged and stayed stable
- the feature set has a mostly linear relationship with savings, so a linear model is a good fit for the problem context

## Saved Artifacts
- Best model: [summative/API/best_savings_model.pkl](summative/API/best_savings_model.pkl)
- Scaler: [summative/API/scaler_v2.pkl](summative/API/scaler_v2.pkl)

## API
FastAPI is used for the backend in [summative/API/prediction.py](summative/API/prediction.py).

### Live Swagger UI
https://linear-regression-model-ambx.onrender.com/docs

### Endpoints
- `GET /` returns a basic service status message
- `POST /predict` accepts one prediction request and returns the predicted savings value
- `POST /retrain` accepts a CSV upload and retrains the saved model on new data

### Input Validation
Pydantic is used to enforce datatypes and realistic ranges:
- `age`: integer, 18 to 100
- `monthly_income_usd`: float, 0 to 50000
- `monthly_expenses_usd`: float, 0 to 50000
- `debt_to_income_ratio`: float, 0 to 100
- categorical fields: restricted to predefined choices

### CORS Configuration
The API does not use a wildcard origin. It allows only the local development origins and the deployed Render origin used for testing.

Allowed origins:
- `http://127.0.0.1:8000`
- `http://localhost:8000`
- `https://linear-regression-model-ambx.onrender.com`

Allowed methods:
- `GET`
- `POST`

Allowed headers:
- `Content-Type`

Credentials are enabled because the CORS policy is meant to support controlled browser-based access during development and deployment, not open public access from any origin.

## Flutter App
The mobile app is in [summative/FlutterApp/lib/main.dart](summative/FlutterApp/lib/main.dart).

It is a single-page prediction screen with:
- 9 input fields matching the API schema
- a `Predict` button
- an output card for the predicted value or validation/error messages

The Flutter app sends a POST request to the deployed API and displays the result returned by `/predict`.

## Deployment Notes
- The API is hosted on Render
- The Flutter app points to the public API URL
- The retraining endpoint can be triggered by uploading a CSV file with the required columns

## Project Structure
```text
linear_regression_model/
├── pyproject.toml
├── uv.lock
├── README.md
└── summative/
	├── linear_regression/
	│   ├── multivariate (1).ipynb
	│   ├── best_savings_model.pkl
	│   └── scaler_v2.pkl
	├── API/
	│   ├── prediction.py
	│   ├── best_savings_model.pkl
	│   ├── scaler_v2.pkl
	│   └── requirements.txt
	└── FlutterApp/
		└── lib/
			└── main.dart
```

## Run Locally With uv
1. Sync dependencies from the root project.
2. Start the API from the `summative/API` folder.
3. Run the Flutter app from `summative/FlutterApp`.

Example commands:

```bash
uv sync
cd summative/API
uv run uvicorn prediction:app --host 0.0.0.0 --port 8000 --reload
```

For Flutter:

```bash
cd summative/FlutterApp
flutter pub get
flutter run
```

## Video Demo
[Watch the demo video](https://youtu.be/hg9T_qG7_Cw)



## Submission Links
- GitHub repository: this project
- Swagger UI: https://linear-regression-model-ambx.onrender.com/docs

## Notes
The repository includes a valid `pyproject.toml` and `uv.lock` for reproducible Python dependency management.

---

## Submission Checklist

Use this checklist to verify all requirements are met:

| Criterion | Status | Notes |
|-----------|--------|-------|
| ✅ Valid `pyproject.toml` at repo root | COMPLETE | Defines all Python dependencies |
| ✅ `uv.lock` file present | COMPLETE | Ensures reproducible builds |
| ✅ README.md documentation | COMPLETE | Describes project, setup, and submission |
| ✅ Jupyter notebook in `summative/linear_regression/` | COMPLETE | Contains analysis & model training |
| ✅ API prediction.py in `summative/API/` | COMPLETE | FastAPI backend with `/predict` endpoint |
| ✅ Flutter app in `summative/FlutterApp/` | COMPLETE | Mobile UI for predictions |
| ✅ Uses `uv` for dependency management | COMPLETE | `uv sync` and `uv run` supported |
| ✅ GitHub repository link ready | COMPLETE | Repository accessible for submission |

**Ready for submission!** You can now:
1. Create a ZIP archive of this repository and upload to Canvas (Attempt 1), OR
2. Submit the GitHub repository link (Attempt 2)
