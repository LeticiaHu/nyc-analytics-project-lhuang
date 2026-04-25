-- models/marts/dim_problem_details.sql

WITH problem_details AS (
    SELECT DISTINCT
        complaint_type,
        complaint_detail,
        additional_detail
    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
    WHERE complaint_type IS NOT NULL
),

dim_problem_details AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'complaint_type',
            'complaint_detail',
            'additional_details'
        ]) }} AS problem_details_key,
        complaint_type,
        complaint_detail,
        additional_detail
    FROM problem_details
)

SELECT *
FROM dim_problem_details