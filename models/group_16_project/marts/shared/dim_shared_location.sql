WITH locations AS (

    SELECT DISTINCT
        borough,
        incident_zip AS zip_code,
        street_name
    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
    WHERE borough IS NOT NULL
       OR incident_zip IS NOT NULL 
       AND  street_name IS NOT NULL
       
    UNION DISTINCT

    SELECT DISTINCT 
        borough,
        zip_code,
        cross_street_name,
        off_street_name
    FROM {{ ref('stg_nyc_vehicle_crashes') }}
    WHERE borough IS NOT NULL
       OR zip_code IS NOT NULL 
),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} AS location_key,
        borough,
        zip_code
    FROM locations
)

SELECT * FROM final

