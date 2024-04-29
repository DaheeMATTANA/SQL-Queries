-- ----- General Hospital Database (credit : superdatascience.com)

-- -- GROUPING SETS


-- 1) Number of patients in patients table by state and by county
SELECT 
	state,
	county,
	COUNT(*) AS num_patients
FROM patients
GROUP BY GROUPING SETS (
	(state),
	(state, county),
	()
)
ORDER BY state DESC, county;
-- using CUBE
SELECT
	state,
	county,
	COUNT(*) AS num_patients
FROM patients
GROUP BY CUBE (state, county)
ORDER BY state DESC, county;
-- With CUBE, county aggregated roll up is added to the first query


-- 2) Average profit by surgeon, admission type, and diagnosis
SELECT
	p.full_name,
	se.admission_type,
	se.diagnosis_description,
	COUNT(*) AS num_surgeries,
	AVG(total_profit) AS avg_total_profit
FROM surgical_encounters se
LEFT OUTER JOIN physicians p
ON se.surgeon_id = p.id
GROUP BY GROUPING SETS(
	(p.full_name),
	(se.admission_type),
	(se.diagnosis_description),
	(p.full_name, se.admission_type),
	(p.full_name, se.diagnosis_description)
);
-- cube
SELECT
	p.full_name,
	se.admission_type,
	se.diagnosis_description,
	COUNT(*) AS num_surgeries,
	AVG(total_profit) AS avg_total_profit
FROM surgical_encounters se
LEFT OUTER JOIN physicians p
ON se.surgeon_id = p.id
GROUP BY CUBE (p.full_name, se.admission_type, se.diagnosis_description);


-- 3) State, hospital, department level of reporting for encounters
SELECT 
	h.state,
	h.hospital_name,
	d.department_name,
	COUNT(e.patient_encounter_id) AS num_encounters
FROM encounters e
LEFT OUTER JOIN departments d
ON e.department_id = d.department_id
LEFT OUTER JOIN hospitals h
ON d.hospital_id = h.hospital_id
GROUP BY ROLLUP (h.state, h.hospital_name, d.department_name)
ORDER BY h.state DESC, h.hospital_name, d.department_name;


-- 4) Average age of patients by city, county, state
SELECT 
	state,
	county,
	city,
	COUNT(master_patient_id) AS num_patients,
	AVG(EXTRACT(YEAR FROM AGE(NOW(), date_of_birth))) AS avg_age
FROM patients
GROUP BY ROLLUP (state, county, city)
HAVING AVG(EXTRACT(YEAR FROM AGE(NOW(), date_of_birth))) IS NOT NULL
ORDER BY state, county, city;


-- 5) Find the average pulse and average body surface area by weight, height, and weight/height
SELECT 
	weight,
	height,
	AVG(pulse) AS avg_pulse,
	AVG(body_surface_area) AS avg_bsa
FROM vitals
GROUP BY CUBE (weight, height)
ORDER BY height, weight;


-- 6) Generate a report on surgical admissions by year, month, and day
SELECT 
	EXTRACT(YEAR FROM surgical_admission_date) AS year,
	EXTRACT(MONTH FROM surgical_admission_date) AS month,
	EXTRACT(DAY FROM surgical_admission_date) AS day,
	COUNT(*) AS num_surgeries
FROM surgical_encounters
GROUP BY ROLLUP (year, month, day)
ORDER BY year;
-- v2
SELECT 
	DATE_PART('YEAR', surgical_admission_date) AS year,
	DATE_PART('MONTH', surgical_admission_date) AS month,
	DATE_PART('DAY', surgical_admission_date) AS day,
	COUNT(surgery_id) AS num_surgeries
FROM surgical_encounters
GROUP BY ROLLUP (1, 2, 3)
ORDER BY 1, 2, 3;

-- 7) Generate a report on the number of patients by primary language, citizenship, primary language/citizenship, and primary language/ethnicity
SELECT 
	primary_language,
	is_citizen,
	ethnicity,
	COUNT(*) AS num_patients
FROM patients
GROUP BY GROUPING SETS (
	(primary_language),
	(is_citizen),
	(primary_language, is_citizen),
	(primary_language, ethnicity)
	)
ORDER BY primary_language;