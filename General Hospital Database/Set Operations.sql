-- ----- General Hospital Database (credit : superdatascience.com)

-- -- SET OPERATIONS


-- 1) All the surgery id across the surgical encounters table & surgical cost table
SELECT surgery_id
FROM surgical_encounters
UNION
SELECT surgery_id
FROM surgical_costs
ORDER BY surgery_id;

-- Allow duplicates
SELECT surgery_id
FROM surgical_encounters
UNION ALL
SELECT surgery_id
FROM surgical_costs
ORDER BY surgery_id;


-- 2) All the surgery id in both the surgical encounters table & surgical cost table
SELECT surgery_id
FROM surgical_encounters
INTERSECT
SELECT surgery_id
FROM surgical_costs
ORDER BY surgery_id;


-- 3) Patients in encounters & surgical_encounters : list of all the patients with normal encounters & surgical encounters
WITH all_patients AS(
	SELECT master_patient_id
	FROM encounters
	INTERSECT
	SELECT master_patient_id
	FROM surgical_encounters
	)
SELECT
	ap.master_patient_id,
	p.name
FROM all_patients ap
LEFT OUTER JOIN patients p
ON ap.master_patient_id = p.master_patient_id;


-- 4) Patients we've seen but not in a surgical context
SELECT master_patient_id
FROM encounters
EXCEPT
SELECT master_patient_id
FROM surgical_encounters
ORDER BY master_patient_id;


-- 5) Surgeries that are in the surgical cost table but not in the surgical encounters
SELECT surgery_id
FROM surgical_costs
EXCEPT
SELECT surgery_id
FROM surgical_encounters
ORDER BY surgery_id;


-- 6) Departments without associated encounters
WITH dept_no_encounters AS(
	SELECT department_id
	FROM departments
	EXCEPT
	SELECT department_id
	FROM encounters
	)
SELECT 
	dne.department_id,
	d.department_name
FROM dept_no_encounters dne
LEFT JOIN departments d
ON dne.department_id = d.department_id;


-- 7) Generate a list of all physicians and physician types in the encounters table (including their names)
WITH type_provider AS(
	SELECT 
		admitting_provider_id AS id,
		'admitting' AS provider_type
	FROM encounters
	UNION
	SELECT
		attending_provider_id,
		'attending' AS provider_type
	FROM encounters
	UNION
	SELECT
		discharging_provider_id,
		'discharging' AS provider_type
	FROM encounters
	)
SELECT
	p.id,
	p.full_name,
	tp.provider_type
FROM type_provider tp
INNER JOIN physicians p
ON p.id = tp.id
ORDER BY p.id;


-- 8) Find all primary care physicians (PCPs) who also are admitting providers
WITH pcp_admitting AS(
	SELECT pcp_id AS id
	FROM patients
	INTERSECT
	SELECT admitting_provider_id
	FROM encounters
	)
SELECT 
	pcp.id,
	p.full_name
FROM pcp_admitting pcp
INNER JOIN physicians p
ON pcp.id = p.id
ORDER BY pcp.id;


-- 9) Determine whether there are any surgeons in the surgical_encounters table who are not in the physicians table (Quality check)
SELECT surgeon_id
FROM surgical_encounters
EXCEPT
SELECT id
FROM physicians;