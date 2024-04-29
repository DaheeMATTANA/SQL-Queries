-- ----- General Hospital Database (credit : superdatascience.com)

-- -- ADVANCED JOINS


-- 1) All surgeries that have the same length
-- Ver.1
WITH surgery_length AS(
	SELECT
		surgery_id,
		surgical_admission_date,
		surgical_discharge_date,
		surgical_discharge_date - surgical_admission_date AS len_surgery
	FROM surgical_encounters
	)
SELECT 
	a.surgery_id,
	b.surgery_id,
	a.len_surgery
FROM surgery_length a
INNER JOIN surgery_length b
ON a.surgery_id != b.surgery_id
AND a.len_surgery = b.len_surgery
WHERE a.len_surgery > 0;
-- Ver.2
SELECT
	se1.surgery_id AS surgery_id_1,
	(se1.surgical_discharge_date - se1.surgical_admission_date) AS los1,
	(se2.surgical_discharge_date - se2.surgical_admission_date) AS los2
FROM surgical_encounters se1
INNER JOIN surgical_encounters se2
ON (se1.surgical_discharge_date - se1.surgical_admission_date) 
	= (se2.surgical_discharge_date - se2.surgical_admission_date);


-- 2) Orders & parent orders 
SELECT
	o1.order_parent_order_id,
	o1.order_procedure_id,
	o1.order_procedure_description,
	o2.order_procedure_description
FROM orders_procedures o1
INNER JOIN orders_procedures o2
ON o1.order_parent_order_id = o2.order_procedure_id;


-- 3) Hospital & department names all possible combinations
SELECT
	h.hospital_name,
	d.department_name
FROM hospitals h
CROSS JOIN departments d;


-- 4) Any departments without hospitals in our departments table (data quality inspection)
SELECT 
	d.department_id,
	d.department_name
FROM departments d
FULL JOIN hospitals h
ON d.hospital_id = h.hospital_id
WHERE h.hospital_id IS NULL;


-- 5) Any encounters without accounts or any accounts without encounters
SELECT 
	a.account_id AS account,
	e.patient_encounter_id AS encounter
FROM accounts a
FULL JOIN encounters e
ON a.account_id = e.hospital_account_id
WHERE a.account_id IS NULL
OR e.hospital_account_id IS NULL
ORDER BY 2;


-- 6) USING
SELECT 
	h.hospital_name,
	d.department_name
FROM departments d
INNER JOIN hospitals h
USING (hospital_id);


-- 7) Natural Join
SELECT
	h.hospital_name,
	d.department_name
FROM departments d
NATURAL JOIN hospitals h;


-- 8) Find the average blood pressure (systolic and diastolic) by admitting provider
SELECT 
	e.admitting_provider_id,
	AVG(v.bp_systolic) AS avg_systolic,
	AVG(v.bp_diastolic) AS avg_diastolic
FROM vitals v
INNER JOIN encounters e
ON v.patient_encounter_id = e.patient_encounter_id
GROUP BY e.admitting_provider_id

-- v2
SELECT 
	p.full_name,
	AVG(v.bp_systolic) AS avg_systolic,
	AVG(v.bp_diastolic) AS avg_diastolic
FROM vitals v
INNER JOIN encounters e
USING (patient_encounter_id)
LEFT OUTER JOIN physicians p
ON e.admitting_provider_id = p.id
GROUP BY p.full_name;


-- 9) Find the number of surgeries in the surgical costs table WITHOUT data in the surgical encounters table
SELECT COUNT(DISTINCT sc.surgery_id) AS no_data
FROM surgical_costs sc
FULL OUTER JOIN surgical_encounters se
ON sc.surgery_id = se.surgery_id
WHERE se.surgery_id IS NULL;

-- v2
SELECT COUNT(DISTINCT sc.surgery_id)
FROM surgical_costs sc
FULL JOIN surgical_encounters se 
USING (surgery_id)
WHERE se.surgery_id IS NULL;