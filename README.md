[README.md](https://github.com/user-attachments/files/29985263/README.md)
# 📊 Data Analyst Job Market Analysis (SQL Project)

Exploring the 2023 data job market through SQL - with a focus on **Data Analyst** roles - to answer a simple question: *what should I actually learn to land a high-paying, in-demand job?*

This project queries a job-postings dataset with PostgreSQL to uncover the top-paying roles, the skills those roles demand, the most in-demand skills across the market, the highest-paying skills, and finally the "optimal" skills that combine both high demand and high pay.

🔗 Check out the SQL queries here: [`/sql`](./sql)

---

## Background

The data comes from a dataset of real-world job postings covering job titles, salaries, locations, and required skills. I used it to explore the data analyst job market and answer these five questions:

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with the highest salaries?
5. What are the most optimal skills to learn (high demand **and** high pay)?

### Tools I Used

- **SQL** - the backbone of the analysis, letting me query the database and surface critical insights
- **PostgreSQL** - the chosen database management system, well suited to handling the job-posting data
- **Python (pandas / matplotlib)** - to turn the query results into the visualizations below
- **Visual Studio Code** - for writing and executing SQL/Python scripts
- **Git & GitHub** - for version control and sharing the analysis

---

## The Analysis

Each query in this project targets a different facet of the data analyst job market. Below is my process, code, and takeaways for each.

### 1. Top-Paying Data Analyst Jobs

To find the highest-paying roles, I filtered data analyst positions by average yearly salary and location, focusing on remote roles (`'Anywhere'`). This highlights the highest-paying opportunities in the field.

```sql
SELECT  
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM   
    job_postings_fact
LEFT JOIN 
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere'
    AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```

![Top 10 Highest-Paying Remote Data Analyst Jobs](images/1_top_paying_jobs.png)

**Insights:**
- **Wide salary range:** the top 10 span from $184K to $650K, showing just how much earning potential exists in the field.
- **Diverse employers:** companies from AT&T and Meta to smaller/niche firms like SmartAsset and Motional all appear, showing demand is spread across industries, not concentrated in "big tech."
- **Job title variety:** titles range from "Data Analyst" to "Director of Analytics," reflecting how broad — and senior-skewed — the highest end of the pay scale is.

---

### 2. Skills for Top-Paying Jobs

Next, I joined the top 10 highest-paying jobs from the query above with their required skills, to see what those top employers are actually asking for.

```sql
WITH top_paying_jobs AS (
    SELECT  
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM   
        job_postings_fact
    LEFT JOIN 
        company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```

![Most Requested Skills Among the Top 10 Highest-Paying Jobs](images/2_top_paying_job_skills.png)

**Insights:**
- **SQL leads** the pack, appearing in 8 of the top 10 postings - it's essentially a prerequisite at the top of the pay scale.
- **Python** is close behind, appearing 7 times, reinforcing that programming skills go hand-in-hand with high pay.
- **Tableau** shows up 6 times, underlining that data visualization is a highly valued skill for senior/high-paying roles.
- Other tools — **R, Snowflake, Excel, Power BI, cloud platforms (AWS/Azure)** - appear with varying frequency, rounding out the toolkit expected of a well-paid data analyst.

---

### 3. In-Demand Skills for Data Analysts

This query aggregates skill frequency across **all** remote data analyst postings (not just the top-paying ones) to see what's most commonly asked for market-wide.

```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_work_from_home = TRUE
GROUP BY
    skills
ORDER BY demand_count DESC
LIMIT 5;
```

![Top 5 In-Demand Skills for Data Analysts](images/3_top_demanded_skills.png)

**Insights:**
- **SQL** is by far the most requested skill (7,291 postings), confirming it as the single most essential tool for the role.
- **Excel** remains highly relevant (4,611), proving that classic spreadsheet skills haven't gone away.
- **Python** (4,330) and **Tableau** (3,745) round out the core technical toolkit.
- **Power BI** (2,609) shows that BI/visualization tools are close to a baseline expectation, not a nice-to-have.

---

### 4. Skills Associated with Higher Salaries

Here I looked at average salary by skill (across all data analyst postings with a listed salary, regardless of location) to see which specific skills command the highest pay.

```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg)) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY
    skills
ORDER BY avg_salary DESC
LIMIT 25;
```

![Top 25 Highest-Paying Skills for Data Analysts](images/4_top_paying_skills.png)

**Insights:**
- **Niche/specialized tools pay the most:** skills like `SVN`, `Solidity`, and `Couchbase` top the list — these appear in relatively few postings, but the ones that do ask for them pay a premium, likely reflecting specialized or blockchain/engineering-adjacent roles.
- **Big data & ML skills pay well:** `Kafka`, `PyTorch`, `TensorFlow`, `Keras`, and `Hugging Face` all rank highly, showing that analysts who can cross over into data engineering / ML earn more.
- **DevOps & cloud-adjacent tools** (`Terraform`, `Ansible`, `Puppet`, `GitLab`, `Bitbucket`) also command strong salaries - a sign that data analysts with software-engineering-adjacent skills are rewarded financially.

---

### 5. Most Optimal Skills to Learn

Finally, I combined demand and salary data to find skills that are **both** in high demand and well paid - the best ROI for someone deciding what to learn next. This focuses on remote positions with a specified salary and a demand count above 10 (to filter out noise from one-off postings).

```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.skill_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = TRUE
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25;
```

![Optimal Skills: High Demand vs High Salary](images/5_optimal_skills.png)

**Insights:**
- **Python and R** stand out in the upper-right of the chart - strong demand paired with salaries above $100K, making them arguably the best skills to prioritize.
- **SQL** anchors the far right of the chart with the highest demand count (398) at a very solid ~$97K average - the safest, most universally required skill.
- **Cloud & big-data skills** (`Azure`, `AWS`, `Snowflake`, `Hadoop`, `Go`) offer some of the highest salaries on this list (~$108K–$115K) despite lower demand — good "specialize to differentiate" options once the core stack is covered.
- **Visualization tools** (`Tableau`, `Power BI`, `Looker`) cluster in the $97K–$104K range with solid demand, confirming they're a dependable, well-rounded addition to a data analyst's skill set.

---

## What I Learned

Through this project I strengthened my SQL toolkit with:

- 🧩 **Complex query construction:** joining multiple tables (`job_postings_fact`, `company_dim`, `skills_job_dim`, `skills_dim`) and merging them the way a pro would
- 📊 **Data aggregation:** getting comfortable with `GROUP BY`, and using aggregate functions like `COUNT()` and `AVG()` to summarize data
- 🧠 **CTEs (Common Table Expressions):** using `WITH` clauses to break complex queries into modular, readable steps for more efficient querying
- 🎯 **Analytical problem solving:** turning real-world questions into testable, actionable SQL queries

---

## Conclusions

### Insights
From the analysis, several general insights emerged about the 2023 data analyst job market:

1. **Top-paying remote data analyst jobs** range widely, from $184K up to $650K - real earning potential exists in the field.
2. **SQL is non-negotiable.** It's the most in-demand skill overall *and* one of the most common skills in the highest-paying jobs.
3. **Specialized skills = higher pay.** Niche tools (`SVN`, `Solidity`, `Couchbase`) and ML/big-data skills (`Kafka`, `PyTorch`, `TensorFlow`) are associated with the highest average salaries.
4. **Python, R, and cloud tools (Azure/AWS/Snowflake) offer the best "optimal" combination** of solid demand and strong pay — the highest-value skills to learn next after mastering SQL and Excel.
5. Overall, **SQL** is confirmed as the most valuable skill for data analysts to learn, maximizing both market value (demand) and financial value (salary).

### Closing Thoughts
This project sharpened my SQL skills and gave me practical insight into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts - the data suggests that focusing on high-demand, high-salary skills like SQL, Python, and cloud/BI tools can help aspiring data analysts position themselves competitively. This exploration also reinforces how important it is to continuously learn and adapt to emerging trends in the field of data analytics.

---

## 📁 Project Structure

```
.
├── README.md                     # This file — full write-up with visuals
├── make_charts.py                # Python script used to generate all charts
├── sql/
│   ├── 1_top_paying_jobs.sql
│   ├── 2_top_paying_job_skills.sql
│   ├── 3_top_demanded_skills.sql
│   ├── 4_top_paying_skills.sql
│   └── 5_optimal_skills.sql
├── data/
│   ├── 1_top_paying_jobs.csv
│   ├── 2_top_paying_roles.csv / .json
│   ├── 3_top_demanded_skills.csv
│   ├── 4_top_paying_skills.csv
│   └── 5_optimal_skills.csv
└── images/
    ├── 1_top_paying_jobs.png
    ├── 2_top_paying_job_skills.png
    ├── 3_top_demanded_skills.png
    ├── 4_top_paying_skills.png
    └── 5_optimal_skills.png
```
