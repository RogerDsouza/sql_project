-- 1. DROP tables if they exist (handling foreign keys)
DROP TABLE IF EXISTS skills_job_dim CASCADE;
DROP TABLE IF EXISTS job_postings_fact CASCADE;
DROP TABLE IF EXISTS company_dim CASCADE;
DROP TABLE IF EXISTS skills_dim CASCADE;

-- 2. Create main tables with PRIMARY KEYS
CREATE TABLE company_dim (
    company_id INT PRIMARY KEY,
    name TEXT,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

CREATE TABLE skills_dim (
    skill_id INT PRIMARY KEY,
    skills TEXT,
    type TEXT
);

CREATE TABLE job_postings_fact (
    job_id INT PRIMARY KEY,
    company_id INT,
    job_title_short VARCHAR(255),
    job_title TEXT,
    job_location TEXT,
    job_via TEXT,
    job_schedule_type TEXT,
    job_work_from_home BOOLEAN,
    search_location TEXT,
    job_posted_date DATE,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country TEXT,
    salary_rate TEXT,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE skills_job_dim (
    job_id INT,
    skill_id INT,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id)
);

-- 3. TEMPORARY tables for raw CSV loading (NO primary keys yet)
DROP TABLE IF EXISTS company_dim_temp;
CREATE TABLE company_dim_temp (
    company_id INT,
    name TEXT,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

DROP TABLE IF EXISTS skills_dim_temp;
CREATE TABLE skills_dim_temp (
    skill_id INT,
    skills TEXT,
    type TEXT
);

DROP TABLE IF EXISTS job_postings_fact_temp;
CREATE TABLE job_postings_fact_temp (
    job_id INT,
    company_id INT,
    job_title_short VARCHAR(255),
    job_title TEXT,
    job_location TEXT,
    job_via TEXT,
    job_schedule_type TEXT,
    job_work_from_home BOOLEAN,
    search_location TEXT,
    job_posted_date DATE,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country TEXT,
    salary_rate TEXT,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC
);

DROP TABLE IF EXISTS skills_job_dim_temp;
CREATE TABLE skills_job_dim_temp (
    job_id INT,
    skill_id INT
);

-- 4. COPY CSV files into TEMP tables
COPY company_dim_temp
FROM 'C:\sql_project\CSV\company_dim.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY skills_dim_temp
FROM 'C:\sql_project\CSV\skills_dim.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY job_postings_fact_temp
FROM 'C:\sql_project\CSV\job_postings_fact.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY skills_job_dim_temp
FROM 'C:\sql_project\CSV\skills_job_dim.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- 5. Insert data safely into real tables (ignoring duplicates)

-- Company
INSERT INTO company_dim (company_id, name, link, link_google, thumbnail)
SELECT DISTINCT company_id, name, link, link_google, thumbnail
FROM company_dim_temp
ON CONFLICT (company_id) DO NOTHING;

-- Skills
INSERT INTO skills_dim (skill_id, skills, type)
SELECT DISTINCT skill_id, skills, type
FROM skills_dim_temp
ON CONFLICT (skill_id) DO NOTHING;

-- Job Postings
INSERT INTO job_postings_fact (job_id, company_id, job_title_short, job_title, job_location, job_via,
                               job_schedule_type, job_work_from_home, search_location, job_posted_date,
                               job_no_degree_mention, job_health_insurance, job_country,
                               salary_rate, salary_year_avg, salary_hour_avg)
SELECT DISTINCT job_id, company_id, job_title_short, job_title, job_location, job_via,
                job_schedule_type, job_work_from_home, search_location, job_posted_date,
                job_no_degree_mention, job_health_insurance, job_country,
                salary_rate, salary_year_avg, salary_hour_avg
FROM job_postings_fact_temp
ON CONFLICT (job_id) DO NOTHING;

-- Skills Job Mapping
INSERT INTO skills_job_dim (job_id, skill_id)
SELECT DISTINCT job_id, skill_id
FROM skills_job_dim_temp
ON CONFLICT (job_id, skill_id) DO NOTHING;

-- 6. Create indexes to speed up queries
CREATE INDEX IF NOT EXISTS idx_company_id_company_dim ON company_dim(company_id);
CREATE INDEX IF NOT EXISTS idx_skill_id_skills_dim ON skills_dim(skill_id);
CREATE INDEX IF NOT EXISTS idx_company_id_job_postings_fact ON job_postings_fact(company_id);
CREATE INDEX IF NOT EXISTS idx_skill_id_skills_job_dim ON skills_job_dim(skill_id);
CREATE INDEX IF NOT EXISTS idx_job_id_skills_job_dim ON skills_job_dim(job_id);

-- 7. Optional: Preview your data
SELECT * FROM job_postings_fact
LIMIT 100;


