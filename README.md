# Restaurant Visitor Prediction

## Mission and problem

I run a restaurant and never know exactly how many people will come to eat, so we often cook too much or too little.
This project predicts how many visitors a restaurant will have on a given day, so the chef knows how much to cook and I know how much stock to buy each week.

## Dataset

I used the Recruit Restaurant Visitor Forecasting dataset from Kaggle. It is real data from Recruit Holdings in Japan, taken from their restaurant booking site (Hot Pepper Gourmet) and their point-of-sale system (AirREGI). It covers 829 restaurants from January 2016 to April 2017.

The data comes as separate tables (daily visitors, restaurant info, bookings and a calendar). I joined them into one table of about 229,000 rows, one row per restaurant per day. The model uses 9 features: restaurant genre, prefecture, day of the week, holiday, month, latitude, longitude, number of people who booked for that day, and visitors on the same day the week before. The target is the number of visitors.

Source: https://www.kaggle.com/competitions/recruit-restaurant-visitor-forecasting/data

## API

Swagger UI: https://restaurant-visitors-api.onrender.com/docs

The API is on Render's free plan, so if nobody has used it for a while the first request can take up to a minute while the server wakes up.

## Video demo

YouTube: ADD LINK HERE

## How to run the mobile app

You need Flutter and Android Studio installed, with an Android emulator set up (or an Android phone connected with USB debugging turned on).

1. Clone the repository:
   ```
   git clone https://github.com/Reginah24/linear_regression_model1.git
   ```
2. Go into the Flutter app folder:
   ```
   cd linear_regression_model1/summative/FlutterApp
   ```
3. Get the packages:
   ```
   flutter pub get
   ```
4. Start the emulator (or plug in your phone). To see the emulators you have:
   ```
   flutter emulators
   flutter emulators --launch <emulator_id>
   ```
5. When the emulator has finished starting, run the app:
   ```
   flutter run
   ```
6. Fill in all 9 fields and press Predict. The predicted number of visitors shows in the box under the button. If a value is missing, the wrong type or out of range, the error shows in the same box.

Example input you can try: Izakaya, 34.69, 135.19, Monday, 0, 0, Hyogo-ken, 3, 16 (this should give about 18 visitors).
