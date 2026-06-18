--create database
CREATE DATABASE workforceiq;

--create tables
CREATE TABLE IF NOT EXISTS department(
              dept_id	INT	NOT NULL PRIMARY KEY,
              dept_name	VARCHAR(20),
              location	VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS employees(
              emp_id	INT	NOT NULL	PRIMARY KEY,
              first_name	VARCHAR(15),		
              last_name	VARCHAR(15),		
              gender	VARCHAR(15),		
              date_of_birth	DATE,		
              hire_date	DATE,		
              dept_id	INT,		
              department	VARCHAR(15),		
              job_title	VARCHAR(35),		
              employment_type	VARCHAR(20),		
              education	VARCHAR(40),		
              location	VARCHAR(20),		
              status	VARCHAR(20),		
              exit_date	DATE,
              FOREIGN KEY(dept_id) REFERENCES department(dept_id)
);

CREATE TABLE IF NOT EXISTS attendance 
              (att_id	INT	NOT NULL PRIMARY KEY,
              emp_id	INT,	
              att_date	DATE,	
              status	VARCHAR(15),
              FOREIGN KEY(emp_id)	REFERENCES employees(emp_id)
);

CREATE TABLE IF NOT EXISTS performance(
             review_id	INT	NOT NULL	PRIMARY KEY,
             emp_id	INT,		
             review_year	INT,		
             rating	INT,	
             manager_comment	VARCHAR(100),
             FOREIGN KEY(emp_id) REFERENCES employees(emp_id)		
);

CREATE TABLE IF NOT EXISTS salaries(
             salary_id	INT	NOT NULL	PRIMARY KEY,
             emp_id	INT,	
             base_salary DECIMAL(12,2),			
             bonus DECIMAL(12,2),			
             effective_date	DATE,
             FOREIGN KEY(emp_id) REFERENCES employees(emp_id)	
);