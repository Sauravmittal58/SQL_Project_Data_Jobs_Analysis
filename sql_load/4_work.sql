SELECT 
    '2023-02-19'::DATE,
    '123':: INTEGER,
    'true'::BOOLEAN,
    '3.14'::REAL;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date::DATE AS date
FROM
    job_postings_fact;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    EXTRACT(YEAR FROM job_posted_date) AS date_year 
FROM
    job_postings_fact
LIMIT 5;

SELECT
    job_id,
    EXTRACT(MONTH FROM job_posted_date) AS MONTH
FROM
    job_postings_fact
LIMIT 5;

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS MONTH
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
ORDER BY
    job_posted_count DESC;

SELECT
    AVG(salary_year_avg) AS avg_year_salary,
    AVG(salary_hour_avg) AS avg_hour_salary,
    job_posted_date::DATE AS date
FROM job_postings_fact
WHERE job_posted_date::DATE > DATE '2023-06-01'
GROUP BY job_posted_date::DATE;

SELECT
    COUNT (job_title_short)job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    EXTRACT(YEAR FROM job_posted_date) AS date_year 
FROM
    job_postings_fact
LIMIT 5;

SELECT
    job_title_short AS Title,
    job_location AS Locations,
    job_via AS Portal,
    job_schedule_type AS Schedule
FROM
    job_postings_fact
WHERE
    job_schedule_type = 'Full-time' AND job_location = 'Anywhere';


CREATE TABLE january_jobs AS
SELECT * FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
SELECT * FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
SELECT * FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT *
FROM january_jobs;

drop table january_jobs

create table january_jobs AS
SELECT * FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

SELECT
    job_title_short,
    job_location,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact;

SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'New York' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
        END AS Location_category
    FROM
        job_postings_fact;

SELECT 
    job_title_short,
    job_location,
        CASE
            WHEN job_location = 'Anywhere' THEN 'Onsite'
            WHEN job_location = 'New York, NY' THEN 'Local'
            ELSE 'Remote'
            END AS Location_CAT
FROM
    job_postings_fact
WHERE job_title_short = 'Data Analyst'
    LIMIT 50;

SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Onsite'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Remote'
    END AS location_cat
FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
        LIMIT 50;

SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Onsite'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Remote'
    END AS location_category
FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
    GROUP BY location_category
    ORDER BY number_of_jobs DESC;

SELECT
    job_title_short,
    job_location,
CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Onsite'
        ELSE 'Others'
            END as New_locations
FROM
     job_postings_fact
        WHERE 
job_title_short = 'Data Analyst'
        LIMIT 500;

SELECT  
    COUNT (job_id) AS Number_of_jobs,
        CASE
    WHEN job_location = 'New York, NY' THEN 'Inhouse'
    WHEN job_location = 'Anywhere' THEN 'Remote'
    ELSE 'Others'
    END AS Locations_Searched
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Engineer' OR job_title_short = 'Data Analyst'
Group BY Locations_Searched;

SELECT *
FROM (
SELECT *
FROM job_postings_fact
WHERE EXTRACT (MONTH FROM job_posted_date) = 1
) as January_jobs_1;

WITH January_Jobs AS (
SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1
    ) 
SELECT *
FROM January_Jobs;

SELECT 
company_id,
name AS company_name
FROM company_dim
WHERE company_id IN (
SELECT
    company_id
FROM
job_postings_fact
WHERE
    job_no_degree_mention = true
    ORDER BY company_id ASC
)

WITH company_jobs_count AS (
    SELECT
    company_id,
    COUNT(*) AS total_jobs
    FROM
        job_postings_fact
        GROUP BY company_id
)
SELECT company_dim.name as compnay_name,
company_jobs_count.total_jobs
FROM company_dim
LEFT JOIN company_jobs_count ON company_jobs_count.company_id = company_dim.company_id
order by total_jobs DESC;


WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = True AND
        job_postings.job_title_short = 'Data Analyst'  
    GROUP BY
        skill_id
)
SELECT
    skills.skill_id,
    skills AS skill_name,  -- as given
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;


WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skills_count
    FROM skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings
        ON job_postings.job_id = skills_to_job.job_id
    WHERE job_postings.job_work_from_home = TRUE AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)

SELECT
    skills.skill_id,
    skills.skills AS skill_name,
    remote_job_skills.skills_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills
    ON skills.skill_id = remote_job_skills.skill_id
    ORDER BY
    skills_count DESC
    LIMIT 5;


/* Get jobs and companies from January */

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs

--Practice Problem 1 (Union/Union ALL)

SELECT
    skills,
    skills_to_job
FROM
    january_jobs

UNION ALL

SELECT
    skills,
    skills_to_job
FROM
    february_jobs

UNION ALL

SELECT
    skills,
    skills_to_job
FROM
    march_jobs

SELECT *
FROM (

SELECT *
FROM job_postings_fact
WHERE EXTRACT (MONTH FROM job_posted_date) = 4
) as April_jobs;

SELECT *
FROM (
SELECT *
FROM job_postings_fact
WHERE EXTRACT (MONTH FROM job_posted_date) = 5
) as May_jobs;

SELECT *
FROM (

    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 6
) AS June_jobs;

SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    skills_job_dim.job_id
FROM skills_dim
JOIN skills_job_dim
    ON skills_dim.skill_id = skills_job_dim.skill_id
JOIN
    skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id;

SELECT
    s.skill_id,
    s.skills,
    sj.job_id
FROM skills_dim s
JOIN skills_job_dim sj
    ON s.skill_id = sj.skill_id
JOIN job_postings_fact j
    ON j.job_id = sj.job_id;


SELECT 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date :: date,
    quarter1_job_postings.salary_year_avg
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
    ) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg >70000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quarter1_job_postings.salary_year_avg DESC;





