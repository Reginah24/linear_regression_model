from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import pandas as pd
import os

app = FastAPI(title="Agaseke Savings Prediction API")

# Load model and scaler
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
model = joblib.load(os.path.join(BASE_DIR, "best_savings_model.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "scaler_v2.pkl"))

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # placeholder for now, we'll tighten this next
    allow_credentials=True,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
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

@app.get("/")
def root():
    return {"message": "Agaseke Savings Prediction API is running"}

@app.post("/predict")
def predict(input_data: PredictionInput):
    try:
        raw_df = pd.DataFrame([input_data.dict()])

        raw_df = pd.get_dummies(raw_df, columns=['gender', 'education_level',
                                                    'employment_status', 'has_loan', 'region'])

        expected_cols = ['age', 'monthly_income_usd', 'monthly_expenses_usd', 'debt_to_income_ratio',
                          'gender_Male', 'gender_Other', 'education_level_High School',
                          'education_level_Master', 'education_level_Other', 'education_level_PhD',
                          'employment_status_Self-employed', 'employment_status_Student',
                          'employment_status_Unemployed', 'has_loan_Yes', 'region_Asia',
                          'region_Europe', 'region_North America', 'region_Other']

        for col in expected_cols:
            if col not in raw_df.columns:
                raw_df[col] = 0

        raw_df = raw_df[expected_cols]

        numeric_features = ['age', 'monthly_income_usd', 'monthly_expenses_usd', 'debt_to_income_ratio']
        raw_df[numeric_features] = scaler.transform(raw_df[numeric_features])

        prediction = model.predict(raw_df)[0]

        return {"predicted_savings_usd": round(float(prediction), 2)}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))