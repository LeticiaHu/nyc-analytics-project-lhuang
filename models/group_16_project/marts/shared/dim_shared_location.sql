WITH locations AS (

    SELECT DISTINCT
        borough,
        zip_code
    FROM {{ ref('stg_nyc_311_vehicle_complaints') }}
    WHERE borough IS NOT NULL
       OR zip_code IS NOT NULL 
UNION DISTINCT

   -- Get locations from restaurant applications
   SELECT DISTINCT 
    borough,
        zip_code
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

