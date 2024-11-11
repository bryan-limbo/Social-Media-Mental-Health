-- Query 1: Viewing all the rows 
SELECT * FROM social_media_survey;

/* 
Looking at the columns, I may drop TIMESTAMP as it doesn't add much value. I may also rename some columns 
to shorten the names. But one major question I have is how to deal with the columns that have multiple values 
separated by commas. Can I separate them into additional columns or is that not necessary as there may be
a way to delimiter them without creating more columns?
*/

/* Before I begin an analysis, I would first like to check for NULLS or duplicate values */

-- Check for NULL values or empty strings in the table
-- I noticed that organization_affiliation had N/A as values, so it could mean that people didn't input anything

SELECT 
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN timestamp IS NULL THEN 1 END) AS timestamp_nulls_or_empty,
    COUNT(CASE WHEN age IS NULL THEN 1 END) AS age_nulls_or_empty,
    COUNT(CASE WHEN gender IS NULL OR gender = '' THEN 1 END) AS gender_nulls_or_empty,
    COUNT(CASE WHEN relationship_status IS NULL OR relationship_status = '' THEN 1 END) AS relationship_status_nulls_or_empty,
    COUNT(CASE WHEN occupation_status IS NULL OR occupation_status = '' THEN 1 END) AS occupation_status_nulls_or_empty,
    COUNT(CASE WHEN organization_affiliation IS NULL OR organization_affiliation = 'N/A' OR organization_affiliation = '' THEN 1 END) AS organization_nulls_or_empty,
    COUNT(CASE WHEN uses_social_media IS NULL OR uses_social_media = '' THEN 1 END) AS uses_social_media_nulls_or_empty,
    COUNT(CASE WHEN commonly_used_platforms IS NULL OR commonly_used_platforms = '' THEN 1 END) AS platforms_nulls_or_empty,
    COUNT(CASE WHEN avg_daily_time_spent IS NULL OR avg_daily_time_spent = '' THEN 1 END) AS avg_time_nulls_or_empty,
    COUNT(CASE WHEN social_media_usage_without_purpose IS NULL THEN 1 END) AS social_media_no_purpose_nulls_or_empty,
    COUNT(CASE WHEN distraction_from_social_media IS NULL THEN 1 END) AS social_media_distraction_nulls_or_empty,
    COUNT(CASE WHEN restless_without_social_media IS NULL THEN 1 END) AS restless_nulls_or_empty,
    COUNT(CASE WHEN distraction_scale IS NULL THEN 1 END) AS distraction_nulls_or_empty,
    COUNT(CASE WHEN bothered_by_worries_scale IS NULL THEN 1 END) AS worries_nulls_or_empty,
    COUNT(CASE WHEN difficulty_concentrating IS NULL THEN 1 END) AS concentrating_nulls_or_empty,
    COUNT(CASE WHEN comparison_through_social_media_scale IS NULL THEN 1 END) AS comparison_nulls_or_empty,
    COUNT(CASE WHEN feelings_about_comparisons IS NULL THEN 1 END) AS feeling_comparison_nulls_or_empty,
    COUNT(CASE WHEN validation_from_social_media IS NULL THEN 1 END) AS validation_nulls_or_empty,
    COUNT(CASE WHEN feeling_depressed_or_down IS NULL THEN 1 END) AS depressed_nulls_or_empty,
    COUNT(CASE WHEN fluctuating_interest_scale IS NULL THEN 1 END) AS interest_nulls_or_empty,
    COUNT(CASE WHEN sleep_issues_scale IS NULL THEN 1 END) AS sleep_nulls_or_empty
FROM social_media_survey;


/* There were 30 values found to be empty or N/A in organization_affiliation. I think it makes more sense
if everyone has an affiliation of some sort, whether they're in school or a company. To fix this, I will
impute the 30 values with the mode.*/

-- Find out what the mode for the organization affiliation is
SELECT organization_affiliation, COUNT(*) as count
FROM social_media_survey
WHERE organization_affiliation <> 'N/A'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

/* University is the highest with a count of 239. This makes sense as this survey was conducted at a University. */

-- Update the organization affiliation table to replace all N/A values with University
UPDATE social_media_survey
SET organization_affiliation = 'University'
WHERE organization_affiliation = 'N/A';


-- Check for duplicates in the table
SELECT *, COUNT(*) AS count_duplicates
FROM social_media_survey
GROUP BY 
    timestamp, 
    age, 
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
    fluctuating_interest_scale,
    sleep_issues_scale
HAVING COUNT(*) > 1;

/* No duplicates found */


/* As mentioned earlier, I want to rename my columns to shorten them. Unfortunately, It didn't let me rename them all in one query,
so I had to alter each one which was very inefficient and tedious */
SELECT * FROM social_media_survey LIMIT 10;

ALTER TABLE social_media_survey
	RENAME COLUMN commonly_used_platforms to platforms_used;
	
ALTER TABLE social_media_survey
	RENAME COLUMN avg_daily_time_spent TO avg_time_spent;

ALTER TABLE social_media_survey
	RENAME COLUMN social_media_usage_without_purpose TO social_media_no_purpose;

ALTER TABLE social_media_survey
	RENAME COLUMN distraction_from_social_media TO social_media_distraction;
	
ALTER TABLE social_media_survey
	RENAME COLUMN restless_without_social_media TO social_media_restlessness;
	
ALTER TABLE social_media_survey
	RENAME COLUMN bothered_by_worries_scale TO worried_scale;

ALTER TABLE social_media_survey
	RENAME COLUMN comparison_through_social_media_scale TO success_comparison_scale;

ALTER TABLE social_media_survey
	RENAME COLUMN validation_from_social_media TO social_media_validation;

ALTER TABLE social_media_survey
	RENAME COLUMN feeling_depressed_or_down TO feeling_depressed;
	
	
/* I also don't think that the timestamp column will be that useful as it doesn't provide much value.*/

-- Drop the timestamp column
ALTER TABLE social_media_survey
DROP COLUMN timestamp;
	
/* Now that my columns are renamed and values are imputed, I will begin my analysis. 
There is no coherence or particular order. This is strictly for me to view the table
from different perspectives and gain a better understanding of the trends involved.

I may also find some values not following the same format, so changes will be made 
accordingly as I query */

-- Query 2: What is the gender distribution amongst the respondents?
SELECT gender
FROM social_media_survey
GROUP BY gender;

/* I noticed that there are 9 different values with 4 of them being the same, just without a consistent format.
To respect people's identity, I will not impute any values except for "There are others???" The rest have an
indicative answer but this is the only one where it doesn't answer the question */


-- Find the mode for the gender
SELECT gender, COUNT(*)
FROM social_media_survey
GROUP BY gender
ORDER BY COUNT(*) DESC
LIMIT 1;

/* The gender that appears the most was female, so I will be imputing "There are others???" to this mode */

-- Impute that value to "female"
UPDATE social_media_survey
SET gender = 'Female'
WHERE gender = 'There are others???'

-- Since there are 4 values for non-binary, I will make them all consistent by naming them Non-binary
UPDATE social_media_survey
SET gender = 'Non-binary'
WHERE gender = 'NB' OR gender = 'Nonbinary' OR gender = 'Non binary'

/* This was not updating the values properly, even though I know it should work. As an alternative, I used the TRIM
function because there may be trailing spaces that I am not accounting for */

-- Update the values using the TRIM function
UPDATE social_media_survey
SET gender = 'Non-binary'
WHERE TRIM(gender) IN ('NB', 'Nonbinary', 'Non binary');

-- Check that the values updated properly
SELECT gender
FROM social_media_survey
GROUP BY gender;

-- Query 3: Which gender uses more social media platforms?
SELECT gender, COUNT(DISTINCT platforms_used) AS unique_platforms_count
FROM social_media_survey
WHERE uses_social_media = 'Yes'
GROUP BY gender;

/* It was a close count but there are a few more males that use more social media platforms */


-- Query 4: Which occupation status uses more social media platforms?
SELECT occupation_status, COUNT(DISTINCT platforms_used) AS unique_platforms_count
FROM social_media_survey
WHERE uses_social_media = 'Yes'
GROUP BY 1;

/* As expected, there are more university students, thus they were the highest occupation to use
social media platforms */


-- Query 5: What is the distribution of platforms used?
WITH platforms_separated AS (
	SELECT unnest(string_to_array(platforms_used, ', ')) AS platform -- string_to_array converts the comma-separated values into an array
	FROM social_media_survey) -- unnest transforms each element of the array into a separate row
	
SELECT platform, COUNT(*)
FROM platforms_separated
GROUP BY 1
ORDER BY 2 DESC;

/* YouTube was the most popular platform used, followed closely by Facebook. This could account for
why some people are on social media longer. They could be watching videos on YouTube */


-- Query 6: What is the distribution of time spent by each gender?
SELECT gender, avg_time_spent, COUNT(*) AS total_users
FROM social_media_survey
GROUP BY gender, avg_time_spent
ORDER BY CASE avg_time_spent -- Use a case statement to customize the order of values
             WHEN 'Less than an Hour' THEN 1
             WHEN 'Between 1 and 2 hours' THEN 2
             WHEN 'Between 2 and 3 hours' THEN 3
             WHEN 'Between 3 and 4 hours' THEN 4
             WHEN 'Between 4 and 5 hours' THEN 5
			 WHEN 'More than 5 hours' THEN 6
         END, 3 DESC;
		 
/* The highest amount of female users spent more than 5 hours, whereas the highest amount of males spent
between 2 and 3 hours */
		 
		 
-- Query 7: Is there a correlation between more time spent on social media and sleeping issues?
SELECT avg_time_spent, AVG(sleep_issues_scale) AS avg_sleep_issues
FROM social_media_survey
GROUP BY avg_time_spent
ORDER BY avg_time_spent;

/* Since I am trying to see if there's a trend between social media and mental health, the results make sense
because the longer you spend on social media, the more likely the sleeping issues. In this case, spending
between 4 and 5 hours or more attributed to a higher average for sleeping issues */


-- Query 8: Is there a correlation between more time spent on social media and depression?
SELECT avg_time_spent, AVG(feeling_depressed) AS avg_depression
FROM social_media_survey
GROUP BY avg_time_spent
ORDER BY avg_time_spent;

/* Similar to the previous query, the depression score increased the longer they spent on social media. 
Those who spent more than 5 hours had the highest average score of 3.76 on a scale of 1 - 5 */


-- Query 9: Does frequently seeking validation correlate with higher levels of depression?
SELECT social_media_validation, AVG(feeling_depressed) AS avg_depression
FROM social_media_survey
GROUP BY 1
ORDER BY 1 DESC;

/* Those who seeked higher social media validation had a higher average depression score.
It seems like there may be a correlation that could be linked between social media and mental
health! */


-- Query 10: Do those who go on social media with no purpose have higher difficulty concentrating?
SELECT social_media_no_purpose, AVG(difficulty_concentrating) AS avg_concentration
FROM social_media_survey
GROUP BY 1
ORDER BY 2 DESC;

/* I also find myself going on social media for no reason at times. This survey also complements 
this because those who do the same have a higher average for difficulty concentrating */


-- Query 11: Do those who spend more time on social media seek higher validation?
SELECT avg_time_spent, AVG(social_media_validation) AS avg_validation
FROM social_media_survey
GROUP BY 1
ORDER BY 2 DESC;

/* Similar to query 7 and 8, by ordering in descending order for the average, the highest score
was for the most time spent (more than 5 hours). However, I notice that spending between 2 and 3 hours
actually had a slightly higher score than spending between 3 and 4 hours */


-- Query 12: How do different platforms compare in terms of feeling depressed?
WITH orgs_separated AS (
	SELECT unnest(string_to_array(platforms_used, ', ')) AS platforms, feeling_depressed
	FROM social_media_survey)
	
SELECT platforms, AVG(feeling_depressed) AS avg_depression, COUNT(*)
FROM orgs_separated
GROUP BY 1
ORDER BY 2 DESC;

/* The platform linked to the highest average depression score was TikTok. Though YouTube was the 
most used platform by the respondents, it ranked 8th, as I imagine most people watch the types
of videos they want. Whereas on TikTok, similar to Instagram, users may just scroll and watch
random videos that appear in their feed */


/* For the next query, I've decided to categorize the ages into 3: Teens, Young adults, and Adults.
Teens are less than 20 years old, young adults are 20 - 24 years old, and adults are over 25 years old.*/

ALTER TABLE social_media_survey
ADD COLUMN category_group VARCHAR(20);

UPDATE social_media_survey
SET category_group = CASE
	WHEN age < 20 THEN 'Teen'
	WHEN age BETWEEN 20 AND 24 THEN 'Young adult'
	ELSE 'Adult'
END;

-- Query 13: Which category has the highest depression score?
SELECT category_group, AVG(feeling_depressed) AS avg_depression, COUNT(*)
FROM social_media_survey
GROUP BY 1
ORDER BY 3 DESC;

/* Most of the respondents are young adults, as this was conducted in a university. 
As the young adults are between the ages of 20 - 24, I expected their depression score
to be the highest because they are spending the most stressful years in school for 
better education */


-- Query 14: What platform do each category group use the most of?
WITH orgs_separated AS ( -- First CTE to separate the platforms as used in previous queries
    SELECT unnest(string_to_array(platforms_used, ', ')) AS platform, category_group
    FROM social_media_survey
),
platform_counts AS ( -- Second CTE counts how many times each platform is used within each group
    SELECT category_group, platform, COUNT(*) AS platform_count
    FROM orgs_separated
    GROUP BY category_group, platform
),
ranked_platforms AS ( -- Third CTE ranks the platforms within each group based on usage count
    SELECT category_group, platform, platform_count, 
        ROW_NUMBER() OVER (PARTITION BY category_group ORDER BY platform_count DESC) AS rank
    FROM platform_counts
)

SELECT category_group, platform AS most_used_platform, platform_count
FROM ranked_platforms
WHERE rank = 1;  -- Get the top platform for each category group

/* YouTube ranked the top platform used amongst both teens and young adults, while Facebook was the top
platform for adults. As someone who categorizes as an adult, I too do not feel like Facebook is as 
popular as it once was */

-- Save the cleaned dataset with changes
SELECT * FROM social_media_survey;

/* As I was working on Tableau, I realized my comma separated values were causing issues. I was unable
to separate the values and pivot them into a column due to it being Tableau Public and not the paid version.
I also didn't have Tableau Prep, also part of the paid version. As such, I came back to my SQL queries
to expand the two columns with multiple values: organization_affiliation and platforms_used. I then
combined it into one new table that has 6 times the number of values as before because it's all 
its own row now. */

-- To ensure each row has its unique sequential ID, I will add in a column that generates the PK
ALTER TABLE social_media_survey
ADD COLUMN survey_id SERIAL PRIMARY KEY;


-- Create a new table that splits the comma separated value columns and explodes them into each row
CREATE TABLE combined_split AS
WITH organization_split AS (
    SELECT 
        survey_id,  -- Include the primary key
        age,
        gender,
        relationship_status,
        occupation_status,
        TRIM(org) AS organization_affiliation,
        uses_social_media,
        TRIM(platform) AS platforms_used,
        avg_time_spent,
        social_media_no_purpose,
        social_media_distraction,
        social_media_restlessness,
        distraction_scale,
        worried_scale,
        difficulty_concentrating,
        success_comparison_scale,
        feelings_about_comparisons,
        social_media_validation,
        feeling_depressed,
        fluctuating_interest_scale,
        sleep_issues_scale,
        category_group
    FROM social_media_survey,
         regexp_split_to_table(organization_affiliation, ',') AS org,
         regexp_split_to_table(platforms_used, ',') AS platform
)
SELECT *
FROM organization_split;

SELECT * FROM combined_split;


