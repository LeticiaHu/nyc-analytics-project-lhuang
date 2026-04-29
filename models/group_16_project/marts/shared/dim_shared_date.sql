

-- WITH dates AS (
--     -- Get dates (dates, no time included) from 311 requests
--    SELECT DISTINCT CAST(created_date AS DATE) AS full_date
--    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
--    WHERE created_date IS NOT NULL

--    UNION DISTINCT

--    -- Get dates from Vehicle crash colission 

--    SELECT DISTINCT CAST(crash_date AS DATE) AS full_date
--    FROM {{ ref('stg_nyc_vehicle_crashes') }}
--    WHERE crash_date IS NOT NULL
-- ),


-- date_dimension AS (
--    SELECT
--        {{ dbt_utils.generate_surrogate_key(['full_date']) }} AS date_key,

--        full_date,
--        EXTRACT(YEAR FROM full_date) AS year,
--        EXTRACT(QUARTER FROM full_date) AS quarter,
--        EXTRACT(MONTH FROM full_date) AS month,
--        FORMAT_DATE('%B', full_date) AS month_name,
--        EXTRACT(DAY FROM full_date) AS day_of_month,
--        EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week,
--        FORMAT_DATE('%A', full_date) AS day_name,
--        EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) AS is_weekend,

--        CASE
--            WHEN EXTRACT(MONTH FROM full_date) >= 7 THEN EXTRACT(YEAR FROM full_date) + 1
--            ELSE EXTRACT(YEAR FROM full_date)
--        END AS fiscal_year

--    FROM dates
-- )

-- SELECT * FROM date_dimension 

WITH datetimes AS (

    -- Get created datetimes from 311 requests
    SELECT DISTINCT
        created_date AS datetime_value
    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
    WHERE created_date IS NOT NULL

    UNION DISTINCT

    -- Get crash datetimes from vehicle crashes
    SELECT DISTINCT
        crash_datetime AS datetime_value
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
    WHERE crash_datetime IS NOT NULL
),

date_dimension AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['datetime_value']) }} AS date_key,

        CAST(datetime_value AS DATE) AS full_date,

        FORMAT_DATE('%A', CAST(datetime_value AS DATE)) AS day,
        FORMAT_DATE('%B', CAST(datetime_value AS DATE)) AS month,
        EXTRACT(YEAR FROM CAST(datetime_value AS DATE)) AS year,

        CAST(datetime_value AS TIMESTAMP) AS time,

        EXTRACT(HOUR FROM CAST(datetime_value AS TIMESTAMP)) < 12 AS is_am,
        EXTRACT(HOUR FROM CAST(datetime_value AS TIMESTAMP)) >= 12 AS is_pm,

        EXTRACT(DAYOFWEEK FROM CAST(datetime_value AS DATE)) IN (1, 7) AS is_weekend

    FROM datetimes
)

SELECT * FROM date_dimension