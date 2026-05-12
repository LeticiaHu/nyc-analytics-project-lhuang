{{ config(materialized='table') }}

SELECT
    collision_id,
    crash_date,
    crash_time,

FROM {{ ref('stg_nyc_vehicle_crashes') }}