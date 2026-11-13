from typing import Literal

import joblib
import pandas as pd
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

MODEL_FILE = "best_model.pkl"
DATA_FILE = "training_data.csv"

app = FastAPI(title="Restaurant Visitor Prediction API")

# CORS: only these two browser origins may call the API from a web page:
# our own Render site (Swagger UI) and the local Flutter web debug address.
# All other websites are blocked, so strangers' sites cannot use our API.
# Only GET and POST are allowed, because those are the only methods we use.
# Only the Content-Type header is allowed, because requests send JSON or a file.
# Credentials (cookies, logins) are turned off, because the API has no logins.
# The Flutter mobile app is not a browser, so CORS does not affect it.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://restaurant-visitors-api.onrender.com",
        "http://localhost:3000",
    ],
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
    allow_credentials=False,
)

class VisitorInput(BaseModel):
    air_genre_name: Literal[
        "Asian", "Bar/Cocktail", "Cafe/Sweets", "Creative cuisine", "Dining bar",
        "International cuisine", "Italian/French", "Izakaya", "Japanese food",
        "Karaoke/Party", "Okonomiyaki/Monja/Teppanyaki", "Other", "Western food",
        "Yakiniku/Korean food",
    ]
    latitude: float = Field(ge=24, le=46)
    longitude: float = Field(ge=122, le=146)
    day_of_week: Literal["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    holiday_flg: int = Field(ge=0, le=1)
    reserve_visitors: int = Field(ge=0, le=2000)
    prefecture: Literal[
        "Fukuoka-ken", "Hiroshima-ken", "Hokkaido", "Hyogo-ken", "Miyagi-ken",
        "Niigata-ken", "Osaka-fu", "Shizuoka-ken", "Tokyo-to",
    ]
    month: int = Field(ge=1, le=12)
    visitors_last_week: int = Field(ge=0, le=1000)

def predict_visitors(input_row):
    model = joblib.load(MODEL_FILE)
    return model.predict(input_row)[0]


@app.post("/predict")
def predict(data: VisitorInput):
    input_row = pd.DataFrame([data.model_dump()])
    prediction = predict_visitors(input_row)
    return {"predicted_visitors": round(float(prediction))}


@app.post("/retrain")
def retrain(file: UploadFile = File(...)):
    new_data = pd.read_csv(file.file)
    original_data = pd.read_csv(DATA_FILE)

    missing_columns = set(original_data.columns) - set(new_data.columns)
    if missing_columns:
        raise HTTPException(status_code=400, detail=f"CSV is missing columns: {sorted(missing_columns)}")

    all_data = pd.concat([original_data, new_data[original_data.columns]])
    X = all_data.drop(columns="visitors")
    y = all_data["visitors"]

    model = joblib.load(MODEL_FILE)
    model.fit(X, y)
    joblib.dump(model, MODEL_FILE)

    return {"message": "Model retrained", "new_rows": len(new_data), "total_rows": len(all_data)}
