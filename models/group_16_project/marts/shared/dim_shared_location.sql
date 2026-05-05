WITH locations AS (

    SELECT DISTINCT
        UPPER(TRIM(CAST(borough AS STRING))) AS borough,
        TRIM(CAST(incident_zip AS STRING)) AS zip_code,
        UPPER(TRIM(CAST(street_name AS STRING))) AS street_name,
        UPPER(TRIM(CAST(cross_street_1 AS STRING))) AS cross_street_name,
        CAST(NULL AS STRING) AS off_street_name
    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}

    UNION DISTINCT

    SELECT DISTINCT 
        UPPER(TRIM(CAST(borough AS STRING))) AS borough,
        TRIM(CAST(zip_code AS STRING)) AS zip_code,
        UPPER(TRIM(CAST(on_street_name AS STRING))) AS street_name,
        UPPER(TRIM(CAST(cross_street_name AS STRING))) AS cross_street_name,
        UPPER(TRIM(CAST(off_street_name AS STRING))) AS off_street_name
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key([
            'borough',
            'zip_code',
            'street_name',
            'cross_street_name',
            'off_street_name'
        ]) }} AS location_key,
        borough,
        zip_code,
        street_name,
        cross_street_name,
        off_street_name
    FROM locations
)

SELECT *
FROM final


