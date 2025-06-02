-- Connect to the new database
\c sample_jobs

-- Create company_dim table
CREATE TABLE company_dim (
    company_id INT PRIMARY KEY,
    name TEXT,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

-- Create skills_dim table
CREATE TABLE skills_dim (
    skill_id INT PRIMARY KEY,
    skills TEXT,
    type TEXT
);

-- Create job_postings_fact table
CREATE TABLE job_postings_fact (
    job_id INT PRIMARY KEY,
    company_id INT REFERENCES company_dim(company_id),
    job_title TEXT,
    job_location TEXT,
    salary_year_avg NUMERIC
);

-- Create skills_job_dim table with composite key
CREATE TABLE skills_job_dim (
    job_id INT,
    skill_id INT,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id)
);


