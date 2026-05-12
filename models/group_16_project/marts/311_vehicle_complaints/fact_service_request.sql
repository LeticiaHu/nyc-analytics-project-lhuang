{{ config(materialized='table') }}

SELECT
    unique_key,
    created_date,
    complaint_type,
    borough
FROM {{ ref('stg_nyc_vehicle_crash') }}