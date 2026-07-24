from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import pandas as pd
import os
import io

app = FastAPI(title="Agaseke Savings Prediction API")

# Load model and scaler
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
model = joblib.load(os.path.join(BASE_DIR, "best_savings_model.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "scaler_v2.pkl"))

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:8000",
        "http://localhost:8000",
        "https://linear-regression-model-ambx.onrender.com"
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)

class PredictionInput(BaseModel):
    age: int = Field(..., ge=18, le=100, description="Age in years")
    gender: str = Field(..., description="Female, Male, or Other")
    education_level: str = Field(..., description="High School, Bachelor, Master, PhD, or Other")
    employment_status: str = Field(..., description="Employed, Self-employed, Student, or Unemployed")
    monthly_income_usd: float = Field(..., ge=0, le=50000, description="Monthly income in USD")
    monthly_expenses_usd: float = Field(..., ge=0, le=50000, description="Monthly expenses in USD")
    has_loan: str = Field(..., description="Yes or No")
    debt_to_income_ratio: float = Field(..., ge=0, le=100, description="Debt to income ratio")
    region: str = Field(..., description="Africa, Asia, Europe, North America, or Other")

EXPECTED_COLS = ['age', 'monthly_income_usd', 'monthly_expenses_usd', 'debt_to_income_ratio',
                  'gender_Male', 'gender_Other', 'education_level_High School',
                  'education_level_Master', 'education_level_Other', 'education_level_PhD',
                  'employment_status_Self-employed', 'employment_status_Student',
                  'employment_status_Unemployed', 'has_loan_Yes', 'region_Asia',
                  'region_Europe', 'region_North America', 'region_Other']

NUMERIC_FEATURES = ['age', 'monthly_income_usd', 'monthly_expenses_usd', 'debt_to_income_ratio']


@app.get("/")
def root():
    return {"message": "Agaseke Savings Prediction API is running"}


@app.post("/predict")
def predict(input_data: PredictionInput):
    try:
        raw_df = pd.DataFrame([input_data.dict()])

        raw_df = pd.get_dummies(raw_df, columns=['gender', 'education_level',
                                                    'employment_status', 'has_loan', 'region'])

        for col in EXPECTED_COLS:
            if col not in raw_df.columns:
                raw_df[col] = 0

        raw_df = raw_df[EXPECTED_COLS]
        raw_df[NUMERIC_FEATURES] = scaler.transform(raw_df[NUMERIC_FEATURES])

        prediction = model.predict(raw_df)[0]

        return {"predicted_savings_usd": round(float(prediction), 2)}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/retrain")
async def retrain(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        new_data = pd.read_csv(io.BytesIO(contents))

        required_cols = ['age', 'gender', 'education_level', 'employment_status',
                          'monthly_income_usd', 'monthly_expenses_usd', 'has_loan',
                          'debt_to_income_ratio', 'region', 'savings_usd']
        missing = [col for col in required_cols if col not in new_data.columns]
        if missing:
            raise HTTPException(status_code=400, detail=f"Missing columns: {missing}")

        new_data = new_data[required_cols]

        new_data_encoded = pd.get_dummies(new_data, columns=['gender', 'education_level',
                                                                'employment_status', 'has_loan', 'region'])

        for col in EXPECTED_COLS:
            if col not in new_data_encoded.columns:
                new_data_encoded[col] = 0

        X_new = new_data_encoded[EXPECTED_COLS].copy()
        y_new = new_data_encoded['savings_usd']

        X_new[NUMERIC_FEATURES] = scaler.transform(X_new[NUMERIC_FEATURES])

        model.partial_fit(X_new, y_new)

        joblib.dump(model, os.path.join(BASE_DIR, "best_savings_model.pkl"))

        return {"message": f"Model retrained successfully with {len(new_data)} new records."}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)