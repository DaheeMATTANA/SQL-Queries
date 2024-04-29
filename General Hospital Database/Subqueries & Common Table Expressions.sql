-- ----- General Hospital Database (credit : superdatascience.com)

-- -- SUBQUERIES & COMMON TABLE EXPRESSIONS


-- 1) Surgical procedures whose total profit is greater than the average cost for each dignosis
SELECT *
FROM surgical_encounters
WHERE total_profit > ALL(
	SELECT AVG(total_cost) 
	FROM surgical_encounters 
	GROUP BY diagnosis_description
);


-- 2) Dignosis whose average length of stay is less than or equal to the average length of stay for all encounters by department
SELECT diagnosis_description,
	   AVG(surgical_discharge_date - surgical_admission_date) AS len_stay_by_diagnosis
FROM surgical_encounters
GROUP BY diagnosis_description
HAVING AVG(surgical_discharge_date - surgical_admission_date) <= ALL(
	SELECT AVG(EXTRACT(DAY FROM patient_discharge_datetime - patient_admission_datetime)) AS len_stay_by_dept
	FROM encounters
	GROUP BY department_id
);
	
	
-- 3) Units who saw all types of surgical types
SELECT unit_name, 
	   COUNT(DISTINCT surgical_type)
FROM surgical_encounters
GROUP BY unit_name
HAVING COUNT(DISTINCT surgical_type) >= ANY(
	SELECT COUNT(DISTINCT surgical_type)
	FROM surgical_encounters
);
-- other solution
SELECT unit_name,
	   STRING_AGG(DISTINCT surgical_type, ', ') AS case_types
FROM surgical_encounters
GROUP BY unit_name
HAVING STRING_AGG(DISTINCT surgical_type, ', ') LIKE ALL(
	SELECT STRING_AGG(DISTINCT surgical_type, ', ')
	FROM surgical_encounters
);


-- 4) All the encounters with an order or all the encounters with at least one order
SELECT e.*
FROM encounters AS e
WHERE EXISTS (
	SELECT 1
	FROM orders_procedures AS o
	WHERE e.patient_encounter_id = o.patient_encounter_id
);


-- 5) All patients who have not had surgery
SELECT p.*
FROM patients AS p
WHERE NOT EXISTS(
	SELECT 1
	FROM surgical_encounters AS s
	WHERE p.master_patient_id = s.master_patient_id
);


-- 6) First 15 of the Fibonacci sequence
WITH RECURSIVE fibonacci AS(
	SELECT 1 AS a, 1 as b
	UNION ALL
	SELECT b, a+b
	FROM fibonacci
)
SELECT a, b
FROM fibonacci
LIMIT 15;


-- 7) Write recursive : order procedure id, order parent order id
SELECT *
FROM orders_procedures

WITH RECURSIVE orders AS(
	SELECT order_procedure_id, order_parent_order_id, 0 AS level
	FROM orders_procedures
	WHERE order_parent_order_id IS NULL
	UNION ALL
	SELECT op.order_procedure_id, op.order_parent_order_id, o.level + 1 AS level
	FROM orders_procedures AS op
	INNER JOIN orders AS o
	ON op.order_parent_order_id = o.order_procedure_id
)
SELECT *
FROM orders
WHERE level != 0;


-- 8) patients information who is born after the year 2000 and whose name starts with the letter m
SELECT *
FROM (
	SELECT *
	FROM patients
	WHERE date_of_birth >= '2000-01-01'
	ORDER BY master_patient_id
	) AS p
WHERE p.name ILIKE 'm%';


-- 9) Selecting surgerys during the month of November 2016 and find the patient who is born after the year 1990
SELECT p.master_patient_id, surgery_id, date_of_birth, surgical_admission_date
FROM patients AS p
INNER JOIN (
	SELECT *	
	FROM surgical_encounters
	WHERE surgical_admission_date BETWEEN '2016-11-01' AND '2016-11-30') AS s
ON p.master_patient_id = s.master_patient_id
WHERE date_of_birth >= '1990-01-01'
ORDER BY surgical_admission_date
-- solution 2
SELECT se.*
FROM (
	SELECT *	
	FROM surgical_encounters
	WHERE surgical_admission_date BETWEEN '2016-11-01' AND '2016-11-30'
	) AS se
INNER JOIN (
	SELECT master_patient_id
	FROM patients
	WHERE date_of_birth >= '1990-01-01'
	) AS p
ON se.master_patient_id = p.master_patient_id;
-- Using CTE (same result as the first query)
WITH young_patients AS (
	SELECT *
	FROM patients
	WHERE date_of_birth >= '2000-01-01'
	)
SELECT *
FROM young_patients
WHERE name ILIKE 'm%';


-- 10) Number of surgeries by county for counties where we have more than 1500 patients
WITH top_counties AS(
	SELECT county,
		   COUNT(*) AS n_patients
	FROM patients
	GROUP BY county
	HAVING COUNT(*) > 1500
	),
	county_patients AS(
	SELECT master_patient_id,
		   p.county
	FROM patients AS p
	INNER JOIN top_counties AS t
	ON p.county = t.county
	)
SELECT county,
	   COUNT(surgery_id) AS n_surgeries
FROM surgical_encounters AS s
INNER JOIN county_patients AS c
ON s.master_patient_id = c.master_patient_id
GROUP BY county;


-- 11) Surgeries where the total cost is greater than the average total cost
SELECT surgery_id,
	   SUM(total_cost) AS total_surgery_cost
FROM surgical_encounters
GROUP BY surgery_id
HAVING total_cost > (SELECT AVG(total_cost) AS avg_cost FROM surgical_encounters);
-- solution 2
WITH total_cost AS(
	SELECT surgery_id,
	  	   SUM(total_cost) AS total_surgery_cost
	FROM surgical_encounters
	GROUP BY surgery_id
	)
SELECT *
FROM total_cost
WHERE total_surgery_cost > (SELECT AVG(total_cost) AS avg_cost FROM surgical_encounters);


-- 12) Find patients that fulfills 2 conditions
SELECT *
FROM vitals
WHERE bp_diastolic > (SELECT MIN(bp_diastolic) FROM vitals)
AND bp_systolic < (SELECT MAX(bp_systolic) FROM vitals);


-- 13) Only patients who have had surgeries
SELECT *
FROM general_hospital.patients
WHERE master_patient_id IN(SELECT DISTINCT master_patient_id FROM surgical_encounters)
ORDER BY master_patient_id;
-- Patients who did not have surgeries
SELECT *
FROM patients
WHERE master_patient_id NOT IN(SELECT DISTINCT master_patient_id FROM surgical_encounters);
-- Join method
SELECT DISTINCT p.master_patient_id
FROM patients AS p
INNER JOIN surgical_encounters AS s
ON p.master_patient_id = s.master_patient_id
ORDER BY p.master_patient_id;


-- 14) Find the average number of orders per encounter by provider/physician
WITH orders_per_encounter AS(
	SELECT patient_encounter_id,
		   ordering_provider_id,
		   COUNT(*) AS num_orders
	FROM orders_procedures
	GROUP BY patient_encounter_id, ordering_provider_id
	)
SELECT ordering_provider_id,
	   ROUND(AVG(num_orders), 2) AS avg_num_orders
FROM orders_per_encounter
GROUP BY ordering_provider_id
ORDER BY 2 DESC;

-- Solution (difference : takes out 1 null column & gives physician name instead of provider id)
WITH provider_encounters AS(
	SELECT ordering_provider_id,
		   patient_encounter_id,
		   COUNT(order_procedure_id) AS num_procedures
	FROM orders_procedures
	GROUP BY ordering_provider_id, patient_encounter_id
	),
	provider_orders AS(
	SELECT ordering_provider_id,
		   AVG(num_procedures) AS avg_num_procedures
	FROM provider_encounters
	GROUP BY ordering_provider_id
	)
SELECT p.full_name, o.avg_num_procedures
FROM physicians p
LEFT OUTER JOIN provider_orders o
ON p.id = o.ordering_provider_id
WHERE o.avg_num_procedures IS NOT NULL
ORDER BY o.avg_num_procedures DESC;


-- 15) Find encounters with any of the top 10 most common order codes
SELECT DISTINCT patient_encounter_id
FROM orders_procedures
WHERE order_cd IN(
	SELECT order_cd
	FROM orders_procedures
	GROUP BY order_cd
	ORDER BY COUNT(*) DESC
	LIMIT 10
);


-- 16) Find accounts with a total account balance over $10,000 and at least one ICU encounter
SELECT account_id
FROM accounts
WHERE total_account_balance > 10000;

SELECT hospital_account_id,
	   COUNT(*)
FROM encounters
WHERE patient_in_icu_flag = 'Yes'
GROUP BY hospital_account_id;

-- JOIN METHOD
SELECT account_id,
	   total_account_balance
FROM accounts AS a
INNER JOIN (
	SELECT hospital_account_id,
		   COUNT(*)
	FROM encounters
	WHERE patient_in_icu_flag = 'Yes'
	GROUP BY hospital_account_id) AS icu
ON a.account_id = icu.hospital_account_id
WHERE total_account_balance > 10000;

-- CTE METHOD
WITH balance_10k AS(
	SELECT account_id, total_account_balance
	FROM accounts
	WHERE total_account_balance > 10000
	)
SELECT hospital_account_id,
	   COUNT(*)
FROM encounters
INNER JOIN balance_10k
ON hospital_account_id = account_id
WHERE patient_in_icu_flag = 'Yes'
GROUP BY hospital_account_id;

-- Solution (difference : using EXISTS command, simpler)
SELECT a.account_id, a.total_account_balance
FROM accounts a
WHERE total_account_balance > 10000
AND EXISTS(
	SELECT 1
	FROM encounters e
	WHERE e.hospital_account_id = a.account_id
	AND patient_in_icu_flag = 'Yes'
);



/* 17) Find encounters for patients born on or after 1995-01-01 whose length of stay is greater than or equal to 
the average SURGICAL length of stay for patients 65 or older */
		
SELECT *
FROM patients;

SELECT master_patient_id, date_of_birth
FROM patients
WHERE date_of_birth >= '1995-01-01';

SELECT *
FROM encounters;

SELECT master_patient_id,
	   EXTRACT(DAY FROM patient_discharge_datetime - patient_admission_datetime) AS length_of_stay
FROM encounters;

SELECT *
FROM surgical_encounters;

SELECT master_patient_id,
	   AVG(surgical_discharge_date - surgical_admission_date) AS surgical_length_stay
FROM surgical_encounters
GROUP BY master_patient_id;

SELECT master_patient_id
FROM patients
WHERE CURRENT_DATE - date_of_birth >= 65;

-- Assemble
WITH patients_after_1995 AS(
	SELECT master_patient_id, date_of_birth
	FROM patients
	WHERE date_of_birth >= '1995-01-01'
	),
	length_of_stay AS(
	SELECT master_patient_id,
	  	   EXTRACT(DAY FROM patient_discharge_datetime - patient_admission_datetime) AS length_of_stay
	FROM encounters
	),
	surgical_stay_older_65 AS(
	SELECT a.master_patient_id, date_of_birth, surgical_discharge_date, surgical_admission_date
	FROM patients AS a
	INNER JOIN surgical_encounters AS b
	ON a.master_patient_id = b.master_patient_id
	WHERE EXTRACT(YEAR FROM AGE(now(), date_of_birth)) >= 65
	)
SELECT *
FROM patients_after_1995
INNER JOIN length_of_stay
ON patients_after_1995.master_patient_id = length_of_stay.master_patient_id
WHERE length_of_stay >= 
	  (SELECT AVG(surgical_discharge_date - surgical_admission_date) FROM surgical_stay_older_65);

-- Solution (difference : different intepretation of the question)
WITH old_los AS(
	SELECT EXTRACT(YEAR FROM AGE(now(), p.date_of_birth)) AS age,
		   AVG(s.surgical_discharge_date - s.surgical_admission_date) AS avg_los
	FROM patients p
	INNER JOIN surgical_encounters s
	ON p.master_patient_id = s.master_patient_id
	WHERE p.date_of_birth IS NOT NULL
	AND EXTRACT(YEAR FROM AGE(now(), p.date_of_birth)) >= 65
	GROUP BY EXTRACT(YEAR FROM AGE(now(), p.date_of_birth))
	)
SELECT e.*
FROM encounters e
INNER JOIN patients p
ON e.master_patient_id = p.master_patient_id
AND p.date_of_birth >= '1995-01-01'
WHERE EXTRACT(DAY FROM e.patient_discharge_datetime - e.patient_admission_datetime) 
	  >= ALL(SELECT avg_los FROM old_los);
	  
-- Solution with my interpretation	  
WITH old_los AS(
	SELECT EXTRACT(YEAR FROM AGE(now(), p.date_of_birth)) AS age,
		   AVG(s.surgical_discharge_date - s.surgical_admission_date) AS avg_los
	FROM patients p
	INNER JOIN surgical_encounters s
	ON p.master_patient_id = s.master_patient_id
	WHERE p.date_of_birth IS NOT NULL
	AND EXTRACT(YEAR FROM AGE(now(), p.date_of_birth)) >= 65
	GROUP BY EXTRACT(YEAR FROM AGE(now(), p.date_of_birth))
	)
SELECT e.*
FROM encounters e
INNER JOIN patients p
ON e.master_patient_id = p.master_patient_id
AND p.date_of_birth >= '1995-01-01'
WHERE EXTRACT(DAY FROM e.patient_discharge_datetime - e.patient_admission_datetime) 
	  >= ALL(SELECT AVG(avg_los) FROM old_los);	  	  