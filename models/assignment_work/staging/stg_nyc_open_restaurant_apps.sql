-- Clean and standardize restaurant open application data
-- One row per service request

WITH source AS (
   SELECT * FROM {{ source('raw_restaurants', 'source_nyc_open_restaurant_apps') }}
), -- Easier to refer to the dbt reference to a long name table this way

cleaned AS (
   SELECT
       -- Get all columns from source, except ones we're transforming below
       -- To do cleaning on them or explicitly cast them as types just in case
       * EXCEPT (
           globalid,
           time_of_submission,
           seating_interest_sidewalk,
           restaurant_name,
           legal_business_name,
           doing_business_as_dba,
           bulding_number,
           street,
           borough,
           zip,
           business_address,
           food_service_establishment,
           sidewalk_dimensions_length,
           sidewalk_dimensions_width,
           sidewalk_dimensions_area,
           approved_for_sidewalk_seating,
           approved_for_roadway_seating,
           qualify_alcohol,
           latitude,
           longitude
       ),

       -- Identifiers
       CAST(globalid AS STRING) AS unique_id,

       -- Date/Time
       CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,
       

       -- Request details
       CAST(seating_interest_sidewalk AS STRING) AS seating_interest_sidewalk,
       CAST(restaurant_name AS STRING) AS restaurant_name,
       CAST(legal_business_name AS STRING) AS legal_business_name,
       CAST(doing_business_as_dba AS STRING) AS doing_business_as_dba,


       -- Location - clean zip code, handling several common zip code data problems
       CASE
           WHEN UPPER(TRIM(CAST(zip AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(zip AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(zip AS STRING)) = 5 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 9 THEN CAST(zip AS STRING)
           WHEN LENGTH(CAST(zip AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(zip AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(zip AS STRING)
           ELSE NULL
       END AS zip,

       -- Location - standardized borough, just in case
       CASE
           WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
           WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
           WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
           WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
           WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
           ELSE 'UNKNOWN or CITYWIDE'
       END AS borough,

       CAST(business_address AS STRING) AS business_address,
       CAST(street AS STRING) AS street,
       CAST(bulding_number AS STRING) AS bulding_number,
       CAST(food_service_establishment AS STRING) AS food_service_establishment,
       CAST(sidewalk_dimensions_length AS STRING) AS sidewalk_dimensions_length,
       CAST(sidewalk_dimensions_width AS STRING) AS sidewalk_dimensions_width,
       CAST(sidewalk_dimensions_area AS STRING) AS sidewalk_dimensions_area,
       CAST(approved_for_sidewalk_seating AS BOOLEAN) AS approved_for_sidewalk_seating,
       CAST(approved_for_roadway_seating AS Boolean) AS approved_for_roadway_seating,
       CAST(qualify_alcohol AS BOOLEAN) AS qualify_alcohol,
       CAST(latitude AS DECIMAL) AS latitude,
       CAST(longitude AS DECIMAL) AS longitude,

        
           

       -- Metadata

        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
    WHERE globalid IS NOT NULL
      AND SAFE_CAST(time_of_submission AS TIMESTAMP) IS NOT NULL
      AND borough IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY globalid
        ORDER BY SAFE_CAST(time_of_submission AS TIMESTAMP) DESC) = 1
)
     

SELECT * FROM cleaned
-- All should be part of this table: stg_nyc_open_restaurant_apps

