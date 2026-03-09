-- Cyclistic Case Study
-- Data Integrity Checks (Prepare Phase)

-- Count total number of trip records in the dataset
SELECT COUNT(*)
FROM cyclistic_2025.trips_2025;

-- Check for duplicate ride IDs (each ride should have a unique identifier)
SELECT
  ride_id,
  COUNT(*) AS occurrences
FROM cyclistic_2025.trips_2025
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- Verify uniqueness by comparing total rows with distinct ride IDs
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ride_id) AS unique_ride_ids
FROM cyclistic_2025.trips_2025;

-- Check missing values in key variables (station names and rider type)
SELECT
  COUNT(*) AS total_rows,
  COUNT(start_station_name) AS start_station_not_null,
  COUNT(end_station_name) AS end_station_not_null,
  COUNT(member_casual) AS member_not_null
FROM cyclistic_2025.trips_2025;

-- Identify rides with negative durations (end time earlier than start time)
SELECT COUNT(*) AS negative_durations
FROM cyclistic_2025.trips_2025
WHERE ended_at < started_at;

-- Explore duration distribution (minimum, maximum and average ride duration)
SELECT
  MIN(TIMESTAMP_DIFF(ended_at, started_at, MINUTE)) AS min_duration,
  MAX(TIMESTAMP_DIFF(ended_at, started_at, MINUTE)) AS max_duration,
  AVG(TIMESTAMP_DIFF(ended_at, started_at, MINUTE)) AS avg_duration
FROM cyclistic_2025.trips_2025;

-- Count extremely long rides (potential outliers longer than 24 hours)
SELECT COUNT(*) AS rides_over_24h
FROM cyclistic_2025.trips_2025
WHERE TIMESTAMP_DIFF(ended_at, started_at, HOUR) > 24;

-- Count extremely short rides (potential outliers shorter than one minute)
SELECT COUNT(*) AS rides_under_1min
FROM cyclistic_2025.trips_2025
WHERE TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60
AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) >= 0;