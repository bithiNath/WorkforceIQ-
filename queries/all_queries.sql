/*1 — Write a query to find the total number of employees and how many are currently active, resigned, or terminated.*/
 
SELECT
    COUNT(*) As total_employess,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) as total_active_emp,
    SUM(CASE WHEN status = 'Resigned' THEN 1 ELSE 0 END) total_resigned_emp,
    SUM(CASE WHEN status = 'Terminated' THEN 1 ELSE 0 END) as total_terminated_emp 
FROM employees;


/*
Q2 — Calculate the overall attrition rate of the company. What percentage of employees have left? */

SELECT
    COUNT(*) AS total,
SUM(CASE WHEN status IN ('Resigned', 'Terminated') THEN 1 ELSE 0 END) AS attritrd,
ROUND( 
  100 * SUM(CASE WHEN status IN ('Resigned', 'Terminated') THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees;

/* Q3 — Which department has the highest employee attrition rate? Write a query to find department-wise attrition percentage. */

SELECT 
   department,
   ROUND(100 * SUM(CASE WHEN status IN ('Resigned','Terminated') THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;



/* Q4 — Find the number of new hires per year. Is the company's headcount growing or shrinking over time? */

SELECT 
      EXTRACT(YEAR FROM hire_date) AS hire_year,
      COUNT(*) AS new_hire
      FROM employees
GROUP BY EXTRACT(YEAR FROM hire_date)
ORDER BY hire_year ASC;


/*Q5 —Write a query to check if there's a pay gap between male and female employees across departments. */

SELECT
   e.department,
   ROUND(AVG(CASE WHEN e.gender = 'Male' THEN s.base_salary +  COALESCE(s.bonus, 0) END), 0) AS avg_male_total_comp,
   ROUND(AVG(CASE WHEN gender = 'Female' THEN s.base_salary + COALESCE(s.bonus, 0) END), 0) AS avg_female_total_comp,
   ROUND(AVG(CASE WHEN e.gender = 'Male' THEN s.base_salary + COALESCE(s.bonus, 0) END), 0) - ROUND(AVG(CASE WHEN e.gender = 'Female' THEN s.base_salary + COALESCE(s.bonus, 0) END), 0) AS pay_gap
FROM employees e
LEFT JOIN salaries s
ON e.emp_id = s.emp_id
WHERE e.status = 'Active'
GROUP BY e.department;




/* Q6 — How many employees fall into each performance rating category (1 to 5)? Show the distribution.*/

SELECT
    rating,
    CASE rating
    WHEN 1 THEN '1 - Poor'
    WHEN 2 THEN '2 - Below Average'
    WHEN 3 THEN ' 3 - Average'
    WHEN 4 THEN '4 - Good'
    WHEN 5 THEN '5 - Excellent'
    END AS rating_label,
    COUNT(*) AS employee_count
FROM performance
WHERE review_year = 2023
GROUP BY rating
ORDER BY rating ASC;


/*Q7 — Is there a correlation between employee performance rating and salary? Do high performers earn more on average?*/

SELECT 
    p.rating,
    ROUND(AVG(s.base_salary), 0) + COALESCE(ROUND(AVG(s.bonus), 0), 0) AS total_comp
FROM performance AS p
LEFT JOIN salaries AS s
ON p.emp_id = s.emp_id
GROUP BY p.rating
ORDER BY p.rating;


/*Q8 — Find how long employees typically stay with the company before leaving. Group employees by tenure (less than 1 year, 1-3 years, etc.).*/

SELECT
    tenure_bucket,
    COUNT(*) AS employee_count

FROM (
    SELECT
    CASE
        WHEN ((EXTRACT(YEAR FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(YEAR FROM hire_date)) * 12 + (EXTRACT(MONTH FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(MONTH FROM hire_date))) < 12 THEN 'A: 1 Year'
        WHEN ((EXTRACT(YEAR FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(YEAR FROM hire_date)) * 12 + (EXTRACT(MONTH FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(MONTH FROM hire_date))) < 36 THEN 'B: 1 - 3 Years'
        WHEN ((EXTRACT(YEAR FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(YEAR FROM hire_date)) * 12 + (EXTRACT(MONTH FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(MONTH FROM hire_date))) < 60 THEN 'C: 3 - 5 Years'
        WHEN ((EXTRACT(YEAR FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(YEAR FROM hire_date)) * 12 + (EXTRACT(MONTH FROM COALESCE(exit_date, CURRENT_DATE)) - EXTRACT(MONTH FROM hire_date))) < 120 THEN 'D: 5 - 10 Years'
        ELSE 'E: 10+ Years'
    END AS tenure_bucket
FROM employees) AS t

GROUP BY tenure_bucket
ORDER BY tenure_bucket;

/*Q9 — Write a query to find the gender ratio (male vs female) in each department for diversity reporting.*/

SELECT
    department,
    SUM(CASE 
           WHEN gender = 'Male' THEN 1 ELSE 0 
        END) AS male_count,
    SUM(CASE 
            WHEN gender = 'Female' THEN 1 ELSE 0 
        END) AS female_count,
    SUM(CASE 
            WHEN gender = 'Other' THEN 1 ELSE 0 
        END) AS other_count,
    COUNT(*) AS total_count,
    ROUND(100 * SUM(CASE 
                        WHEN gender = 'Male' THEN 1 ELSE 0 
                    END) / COUNT(*), 1) AS male_pct,
    ROUND(100 * SUM(CASE 
                        WHEN gender = 'Female' THEN 1 ELSE 0 
                    END) / COUNT(*), 1) AS female_pct,
    ROUND(100 * SUM(CASE
                       WHEN gender = 'Other' THEN 1 ELSE 0 
                    END) / COUNT(*), 1) AS other_pct
FROM employees
WHERE status = 'Active'
GROUP BY department
ORDER BY female_pct DESC;

/*Q10 — Find the absenteeism rate by department for each month. Which department has the worst attendance? */

SELECT *
FROM (
    SELECT
    e.department,

    EXTRACT(YEAR FROM a.att_date) AS year,
    EXTRACT(MONTH FROM a.att_date) AS month,

    COUNT(*) AS total_days,

    SUM(
        CASE 
            WHEN a.status = 'Absent' THEN 1 ELSE 0
        END
    ) AS absent_days,

    ROUND(100.0 * SUM(
            CASE 
                WHEN a.status = 'Absent' THEN 1 ELSE 0
             END) / COUNT(*), 1) as absenteeism_rate

FROM attendance AS a
INNER JOIN employees AS e
ON a.emp_id = e.emp_id

WHERE a.status <>  'Holiday'

GROUP BY
    e.department,
    EXTRACT(YEAR FROM a.att_date),
    EXTRACT(MONTH FROM a.att_date)
    
ORDER BY
    year,
    month,
    e.department) t
ORDER BY absenteeism_rate DESC
LIMIT 1;


/*Q11 — Write a query to find the top 10 highest-paid active employees along with their department and job title. */

SELECT 
e.emp_id,
CONCAT(e.first_name, ' ',
e.last_name) AS full_name,
e.department,
e.job_title,
s.base_salary + s.bonus AS total_comp
FROM salaries AS s
INNER JOIN employees AS e
ON s.emp_id = e.emp_id
WHERE status = 'Active'
ORDER by total_comp DESC
LIMIT 10;


/*Q12 — Compare the average performance rating of each department between 2022 and 2023. Has performance improved or declined? */

SELECT
    e.department,
    p.review_year,
    ROUND(AVG(p.rating), 2) AS avg_rating
FROM performance AS p
INNER JOIN employees AS e
ON e.emp_id = p.emp_id
GROUP BY e.department, p.review_year
ORDER BY e.department, p.review_year;
