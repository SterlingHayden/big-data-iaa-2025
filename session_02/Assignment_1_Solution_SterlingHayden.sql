-- What is the average trip duration?
SELECT avg(dropoff_datetime - pickup_datetime) as avg_duration
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2017`


-- What is the passenger count distribution?
SELECT 
  COUNT(*) AS total_rows,
  AVG(passenger_count) AS avg_value,
  MIN(passenger_count) AS min_value,
  MAX(passenger_count) AS max_value,
  STDDEV(passenger_count) AS std_dev
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2017`


-- Extract day_of_week (e.g., Monday, Tuesday) from pickup_datetime
CREATE TABLE `iaa2025.taxi_data.new_taxi_trips_2017` AS
SELECT 
    *, 
    FORMAT_TIMESTAMP('%A', pickup_datetime) AS day_of_week
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2017`


-- Create Training Table
CREATE TABLE `iaa2025.taxi_data.new_taxi_trips_train` AS
SELECT * FROM `iaa2025.taxi_data.new_taxi_trips_2017`
WHERE RAND() < 0.8;
-- Create Test Table
CREATE TABLE `iaa2025.taxi_data.new_taxi_trips_test` AS
SELECT * FROM `iaa2025.taxi_data.new_taxi_trips_2017`
WHERE RAND() >= 0.8;


-- Train a Regression Model
CREATE MODEL `taxi_data.Taxi_Model`
OPTIONS(
  model_type='linear_reg',
  input_label_cols=['trip_duration']
) AS
SELECT 
  * EXCEPT(dropoff_datetime, pickup_datetime, airport_fee),  -- Excludes original col & null col
  TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) AS trip_duration
FROM `iaa2025.taxi_data.new_taxi_trips_train`
WHERE dropoff_datetime IS NOT NULL AND pickup_datetime IS NOT NULL


-- Model's Performance
SELECT *
FROM ML.EVALUATE(MODEL taxi_data.Taxi_Model);


-- Make Predictions
SELECT *
FROM
ML.PREDICT(MODEL `taxi_data.Taxi_Model`,
  (
  SELECT *
  FROM `iaa2025.taxi_data.new_taxi_trips_test`
  WHERE dropoff_datetime IS NOT NULL AND pickup_datetime IS NOT NULL
  ));
    


