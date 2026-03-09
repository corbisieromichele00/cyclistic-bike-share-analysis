-- ============================================================
-- Cyclistic Case Study
-- Process Phase: Data Cleaning and Transformation
-- Tool: SQL (BigQuery)
-- ============================================================


-- ------------------------------------------------------------
-- 1. Create cleaned working table and calculate ride duration
--    in minutes using timestamp difference.
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.trips_2025_cleaned AS
SELECT
  *,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length
FROM cyclistic_2025.trips_2025;



-- ------------------------------------------------------------
-- 2. Preview sample records to validate ride_length calculation
-- ------------------------------------------------------------

SELECT
  started_at,
  ended_at,
  ride_length
FROM cyclistic_2025.trips_2025_cleaned
LIMIT 20;



-- ------------------------------------------------------------
-- 3. Remove records with negative ride durations
--    (clear timestamp inconsistencies)
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.trips_2025_cleaned AS
SELECT *
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length >= 0;



-- ------------------------------------------------------------
-- 4. Verify removal of negative durations
-- ------------------------------------------------------------

SELECT COUNT(*) AS negative_durations_remaining
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length < 0;



-- ------------------------------------------------------------
-- 5. Check total record count after removing invalid durations
-- ------------------------------------------------------------

SELECT COUNT(*) AS total_records_after_negative_removal
FROM cyclistic_2025.trips_2025_cleaned;



-- ------------------------------------------------------------
-- 6. Identify extreme duration outliers (rides > 24 hours)
--    1440 minutes = 24 hours
-- ------------------------------------------------------------

SELECT
  ride_id,
  ride_length
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length > 1440
ORDER BY ride_length DESC;



-- ------------------------------------------------------------
-- 7. Remove rides longer than 24 hours
--    (considered non-representative extreme outliers)
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.trips_2025_cleaned AS
SELECT *
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length <= 1440;



-- ------------------------------------------------------------
-- 8. Verify removal of >24h rides
-- ------------------------------------------------------------

SELECT COUNT(*) AS rides_over_24h_remaining
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length > 1440;



-- ------------------------------------------------------------
-- 9. Analyze distribution of very short rides (0 or 1 minute)
--    to evaluate potential system artifacts
-- ------------------------------------------------------------

SELECT
  ride_length,
  COUNT(*) AS count
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length <= 1
GROUP BY ride_length
ORDER BY ride_length;



-- ------------------------------------------------------------
-- 10. Remove rides with 0-minute duration
--     (likely accidental unlocks or system noise)
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.trips_2025_cleaned AS
SELECT *
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length >= 1;



-- ------------------------------------------------------------
-- 11. Verify removal of 0-minute rides
-- ------------------------------------------------------------

SELECT COUNT(*) AS rides_under_1min_remaining
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length < 1;



-- ------------------------------------------------------------
-- 12. Add day_of_week variable extracted from started_at
--     to support weekly behavioral analysis
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.trips_2025_cleaned AS
SELECT
  *,
  FORMAT_TIMESTAMP('%A', started_at) AS day_of_week
FROM cyclistic_2025.trips_2025_cleaned;



-- ------------------------------------------------------------
-- 13. Preview day_of_week values to validate transformation
-- ------------------------------------------------------------

SELECT
  started_at,
  day_of_week
FROM cyclistic_2025.trips_2025_cleaned
LIMIT 10;