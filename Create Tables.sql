-- Step 1: Create a database
-- CREATE DATABASE social_media_survey;

-- Step 2: Create a table before importing the CSV file
/* CREATE TABLE social_media_survey ( 
    timestamp TIMESTAMP WITH TIME ZONE,
    age INT,
    gender VARCHAR(20),
    relationship_status VARCHAR(50),
    occupation_status VARCHAR(50),
    organization_affiliation VARCHAR(100),
    uses_social_media TEXT,
    commonly_used_platforms TEXT,
    avg_daily_time_spent VARCHAR(50),
    social_media_usage_without_purpose INT,
    distraction_from_social_media INT,
    restless_without_social_media INT,
    distraction_scale INT,
    bothered_by_worries_scale INT,
    difficulty_concentrating INT,
    comparison_through_social_media_scale INT,
    feelings_about_comparisons INT,
    validation_from_social_media INT,
    feeling_depressed_or_down INT,
    fluctuating_interest_scale INT,
    sleep_issues_scale INT
);
*/

-- Step 3: Import data into the table
-- COPY social_media_survey FROM 'C:\Users\blim9\Desktop\Projects\Social Media Mental Health Analysis\smmh.csv' DELIMITER ',' CSV HEADER;

/*
Ran into an error because the values in the "timestamp" column are not in the YYYY-MM-DD format. 
Instead, it's MM/DD/YYYY. Without touching the original file, I will create a staging table to temporarily hold the
data. Then, I will transform the data, converting it to the correct format before moving it to the main table.
*/

-- Step 3B: Create a staging table
/* CREATE TABLE social_media_survey_staging (
    timestamp TEXT,  -- Temporarily store as TEXT
    age INT,
    gender VARCHAR(20),
    relationship_status VARCHAR(50),
    occupation_status VARCHAR(50),
    organization_affiliation VARCHAR(100),
    uses_social_media TEXT,
    commonly_used_platforms TEXT,
    avg_daily_time_spent VARCHAR(50),
    social_media_usage_without_purpose INT,
    distraction_from_social_media INT,
    restless_without_social_media INT,
    distraction_scale INT,
    bothered_by_worries_scale INT,
    difficulty_concentrating INT,
    comparison_through_social_media_scale INT,
    feelings_about_comparisons INT,
    validation_from_social_media INT,
    feeling_depressed_or_down INT,
    fluctuating_interest_scale INT,
    sleep_issues_scale INT
);
*/

-- Step 3C: Import the data into the staging table
-- COPY social_media_survey_staging FROM 'C:\Users\blim9\Desktop\Projects\Social Media Mental Health Analysis\smmh.csv' DELIMITER ',' CSV HEADER;

/*
Ran into another issue because the age column is supposed to be INT but there's a float value. 
*/

-- Step 3D: Alter the staging table to update the column data types
/* ALTER TABLE social_media_survey_staging
ALTER COLUMN age TYPE FLOAT;  -- Change age to FLOAT for decimal values
*/

-- Step 3E: Re-import the data
-- COPY social_media_survey_staging FROM 'C:\Users\blim9\Desktop\Projects\Social Media Mental Health Analysis\smmh.csv' DELIMITER ',' CSV HEADER;

-- Step 4: Add a new column for the converted timestamp
-- ALTER TABLE social_media_survey_staging ADD COLUMN timestamp_converted TIMESTAMP WITH TIME ZONE;

-- Step 5: Update the new timestamp column with converted values
/* UPDATE social_media_survey_staging
SET timestamp_converted = TO_TIMESTAMP(timestamp, 'MM/DD/YYYY HH24:MI:SS');
*/

-- Step 6: Insert the new changed columns into the original table
/* INSERT INTO social_media_survey 
SELECT timestamp_converted, 
    ROUND(age::FLOAT),  
    gender, 
    relationship_status, 
    occupation_status, 
    organization_affiliation, 
    uses_social_media, 
    commonly_used_platforms, 
    avg_daily_time_spent, 
    social_media_usage_without_purpose, 
    distraction_from_social_media, 
    restless_without_social_media, 
    distraction_scale, 
    bothered_by_worries_scale, 
    difficulty_concentrating, 
    comparison_through_social_media_scale, 
    feelings_about_comparisons, 
    validation_from_social_media, 
    feeling_depressed_or_down, 
    fluctuating_interest_scale, commonly_used_platforms
    sleep_issues_scale
FROM social_media_survey_staging;
*/

DROP TABLE social_media_survey_staging;