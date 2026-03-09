-- ============================================================
-- Cyclistic Case Study
-- Analyze Phase: Descriptive Analysis and Trend Exploration
-- Tool: SQL (BigQuery)
-- Dataset: cyclistic_2025.trips_2025_cleaned
-- ============================================================


-- ------------------------------------------------------------
-- 1) Compare overall usage between member and casual riders
--    - total_rides: number of rides per user type
--    - avg_ride_length: average trip duration (minutes)
--    - max_ride_length: longest observed trip duration (minutes)
-- ------------------------------------------------------------

SELECT
  member_casual,
  COUNT(*) AS total_rides,
  AVG(ride_length) AS avg_ride_length,
  MAX(ride_length) AS max_ride_length
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY member_casual;



-- ------------------------------------------------------------
-- 2) Validate whether the maximum duration value is rare
--    This checks how many rides have the maximum observed duration
--    (1439 minutes = 24h - 1 minute, due to earlier outlier filtering).
-- ------------------------------------------------------------

SELECT
  member_casual,
  COUNT(*) AS rides_with_max_duration
FROM cyclistic_2025.trips_2025_cleaned
WHERE ride_length = 1439
GROUP BY member_casual;



-- ------------------------------------------------------------
-- 3) Count rides by day of week for each user type (absolute counts)
--    Useful for a first look, but can be misleading because the two
--    groups have different total ride volumes.
-- ------------------------------------------------------------

SELECT
  day_of_week,
  member_casual,
  COUNT(*) AS number_of_rides
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY day_of_week, member_casual
ORDER BY day_of_week;



-- ------------------------------------------------------------
-- 4) Count rides by day of week (relative percentages within each user type)
--    This normalizes counts so that weekday/weekend patterns are comparable
--    between members and casual riders.
--    percentage_of_rides = (rides on that weekday / total rides of that user type) * 100
-- ------------------------------------------------------------

SELECT
  day_of_week,
  member_casual,
  COUNT(*) AS rides,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (PARTITION BY member_casual),
    2
  ) AS percentage_of_rides
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY day_of_week, member_casual
ORDER BY
  member_casual,
  CASE day_of_week
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END;



-- ------------------------------------------------------------
-- 5) Average ride duration by day of week for each user type
--    This shows whether ride duration changes across weekdays vs weekends
--    and highlights differences in behavior between members and casual riders.
-- ------------------------------------------------------------

SELECT
  day_of_week,
  member_casual,
  ROUND(AVG(ride_length), 2) AS avg_ride_length_min
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY day_of_week, member_casual
ORDER BY member_casual, day_of_week;



-- ------------------------------------------------------------
-- 6) Seasonal distribution: rides by month (absolute + percentage within each user type)
--    - rides: number of rides in each month
--    - percentage_of_year: share of annual rides occurring in that month,
--      computed separately for members and casual riders
--    This highlights seasonality differences between user groups.
-- ------------------------------------------------------------

SELECT
  FORMAT_TIMESTAMP('%B', started_at) AS month,
  member_casual,
  COUNT(*) AS rides,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (PARTITION BY member_casual),
    2
  ) AS percentage_of_year
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY month, member_casual
ORDER BY member_casual, percentage_of_year DESC;

-- ------------------------------------------------------------
--    Monthly distribution ordered chronologically (Jan -> Dec)
--    Includes absolute rides + % of annual rides (per user type).
-- ------------------------------------------------------------

SELECT
  month,
  member_casual,
  rides,
  percentage_of_year
FROM (
  SELECT
    EXTRACT(MONTH FROM started_at) AS month_num,
    FORMAT_TIMESTAMP('%B', started_at) AS month,
    member_casual,
    COUNT(*) AS rides,
    ROUND(
      COUNT(*) * 100.0 /
      SUM(COUNT(*)) OVER (PARTITION BY member_casual),
      2
    ) AS percentage_of_year
  FROM cyclistic_2025.trips_2025_cleaned
  GROUP BY month_num, month, member_casual
)
ORDER BY member_casual, month_num;


-- ------------------------------------------------------------
-- 7) Create a compact "final_insights_overview" table
--    This table summarizes the key overall metrics by user type:
--    - total rides
--    - average ride length (min)
--    - maximum ride length (min)
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.final_insights_overview AS
SELECT
  member_casual,
  COUNT(*) AS total_rides,
  ROUND(AVG(ride_length), 2) AS avg_ride_length_min,
  MAX(ride_length) AS max_ride_length_min
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY member_casual;



-- ------------------------------------------------------------
-- 8) Create "final_insights_weekly" table
--    This is ready for weekday/weekend charts:
--    - rides per day_of_week per user type
--    - % distribution within each user type
--    - average ride length per day_of_week
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.final_insights_weekly AS
SELECT
  day_of_week,
  member_casual,
  COUNT(*) AS rides,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (PARTITION BY member_casual),
    2
  ) AS pct_of_user_rides,
  ROUND(AVG(ride_length), 2) AS avg_ride_length_min,
  CASE day_of_week
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END AS day_sort
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY day_of_week, member_casual;


-- ------------------------------------------------------------
-- 9) Create "final_insights_monthly" table
--    This is ready for seasonality charts:
--    - rides per month per user type
--    - % distribution within each user type
--    Month sorting is included (month_sort) for Jan -> Dec plotting.
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE cyclistic_2025.final_insights_monthly AS
SELECT
  FORMAT_TIMESTAMP('%B', started_at) AS month,
  member_casual,
  COUNT(*) AS rides,
  ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (PARTITION BY member_casual),
    2
  ) AS pct_of_user_rides,
  CASE FORMAT_TIMESTAMP('%B', started_at)
    WHEN 'January' THEN 1
    WHEN 'February' THEN 2
    WHEN 'March' THEN 3
    WHEN 'April' THEN 4
    WHEN 'May' THEN 5
    WHEN 'June' THEN 6
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    WHEN 'December' THEN 12
  END AS month_sort
FROM cyclistic_2025.trips_2025_cleaned
GROUP BY month, member_casual, month_sort;