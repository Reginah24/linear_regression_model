# Agaseke Savings Predictor Flutter App

This folder contains the single-screen Flutter client for the savings prediction API.

## Purpose
The app collects the same inputs used by the FastAPI prediction endpoint and sends them to the deployed model. It then displays either the predicted monthly savings value or a validation/error message.

## UI Requirements Covered
- 9 input controls matching the API schema
- a `Predict` button
- a display area for predictions and errors
- a clean single-page layout that stays readable on mobile screens

## Inputs
The screen collects:
- Age
- Gender
- Education level
- Employment status
- Monthly income
- Monthly expenses
- Has loan
- Debt to income ratio
- Region

## API Integration
The app sends a POST request to:

https://linear-regression-model-ambx.onrender.com/predict

## Dependencies
- `flutter`
- `http`

## How To Run
1. Install Flutter from https://docs.flutter.dev/get-started/install
2. Open this folder in Flutter.
3. Run `flutter pub get`.
4. Start the app with `flutter run`.

## Deployment Notes
- The app is configured to talk to the hosted Render API.
- Because the app is mobile-first, the main validation happens in the UI and in the backend Pydantic schema.
- The API also exposes a retraining endpoint at `/retrain` for uploading new CSV data.

## Demo Notes
During the submission video, show:
- the 9 input fields
- a successful prediction
- an out-of-range or missing-field error
- the API call in the Flutter source code
