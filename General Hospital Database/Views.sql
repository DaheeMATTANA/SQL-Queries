-- ----- General Hospital Database (credit : superdatascience.com)

-- -- VIEWS


-- 1) Easy way to look at surgery statistics by department
CREATE VIEW v_monthly_surgery_stats_by_department AS
	SELECT 
		TO_CHAR(surgical_admission_date, 'YYYY-MM'),
		unit_name,
		COUNT(surgery_id) AS num_surgeries,
		SUM(total_cost) AS total_cost,
		SUM(total_profit) AS total_profit
	FROM surgical_encounters
	GROUP BY TO_CHAR(surgical_admission_date, 'YYYY-MM'), unit_name
	ORDER BY unit_name, TO_CHAR(surgical_admission_date, 'YYYY-MM');
	
-- look at the view
SELECT *
FROM v_monthly_surgery_stats_by_department;


-- 2) System-level views
SELECT *
FROM information_schema.views;

SELECT *
FROM information_schema.views
WHERE table_schema = 'public';


-- 3) Copied From the 'view_definition', how the view is defined by the database
SELECT 
	to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text) AS to_char,
    unit_name,
    count(surgery_id) AS num_surgeries,
    sum(total_cost) AS total_cost,
    sum(total_profit) AS total_profit
FROM surgical_encounters
GROUP BY (to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text)), unit_name
ORDER BY unit_name, (to_char((surgical_admission_date)::timestamp with time zone, 'YYYY-MM'::text));

-- drop
DROP VIEW IF EXISTS v_monthly_surgery_stats_by_department;

-- replace
CREATE OR REPLACE VIEW v_monthly_surgery_stats AS
	SELECT 
		TO_CHAR(surgical_admission_date, 'YYYY-MM') AS year_month,
		COUNT(surgery_id) AS num_surgeries,
		SUM(total_cost) AS total_cost,
		SUM(total_profit) AS total_profit
	FROM surgical_encounters
	GROUP BY 1
	ORDER BY 1;
	
-- alter
ALTER VIEW IF EXISTS v_monthly_surgery_stats
RENAME TO view_monthly_surgery_stats;


-- 4) View on encounters table : to only show datas by department 22100005
SELECT DISTINCT department_id
FROM encounters
ORDER BY 1;

CREATE VIEW v_encounters_department_22100005 AS
	SELECT 
		patient_encounter_id,
		admitting_provider_id,
		department_id,
		patient_in_icu_flag
	FROM encounters
	WHERE department_id = 22100005;
	
	
SELECT *
FROM v_encounters_department_22100005;
-- it is an updatable view
	
-- Update into the view & underlying table	
INSERT INTO v_encounters_department_22100005 VALUES
	(123456, 5611, 22100006, 'Yes');
	
SELECT *
FROM encounters
WHERE patient_encounter_id = 123456;

-- with check option
CREATE OR REPLACE VIEW v_encounters_department_22100005 AS
	SELECT
		patient_encounter_id,
		admitting_provider_id,
		department_id,
		patient_in_icu_flag
	FROM encounters
	WHERE department_id = 22100005
	WITH CHECK OPTION;
-- We get error due to added check option
INSERT INTO v_encounters_department_22100005 VALUES
	(123457, 5611, 22100006, 'Yes');
-- We get error due to added check option
UPDATE v_encounters_department_22100005
SET department_id = 22100006
WHERE patient_encounter_id = 4915064;


-- 5) Materialized view (with no data)
CREATE MATERIALIZED VIEW v_monthly_surgery_stats AS
SELECT
	TO_CHAR(surgical_admission_date, 'YYYY-MM'),
	unit_name,
	COUNT(surgery_id) AS num_surgeries,
	SUM(total_cost) AS total_cost,
	SUM(total_profit) AS total_profit
FROM surgical_encounters
GROUP BY 1, 2
ORDER BY 2, 1
WITH NO DATA;

-- We get an error due to with no data statement
SELECT *
FROM v_monthly_surgery_stats;

--
REFRESH MATERIALIZED VIEW v_monthly_surgery_stats;

ALTER MATERIALIZED VIEW v_monthly_surgery_stats
RENAME TO mv_monthly_surgery_stats;

SELECT *
FROM mv_monthly_surgery_stats;


ALTER MATERIALIZED VIEW mv_monthly_surgery_stats
RENAME COLUMN to_char TO year_month;

SELECT *
FROM pg_matviews;


-- 6) Recursive views
CREATE RECURSIVE VIEW v_fibonacci (a, b) AS
	SELECT 1 AS a, 1 AS b
	UNION ALL
	SELECT b, a+b
	FROM v_fibonacci
	WHERE b < 200;
	
SELECT *
FROM v_fibonacci;

-- another example
CREATE RECURSIVE VIEW v_orders (order_procedure_id, order_parent_order_id, level) AS
	SELECT 
		order_procedure_id,
		order_parent_order_id,
		0 AS level
	FROM orders_procedures
	WHERE order_parent_order_id IS NULL
	UNION ALL
	SELECT
		op.order_procedure_id,
		op.order_parent_order_id,
		o.level + 1 AS level
	FROM orders_procedures op
	INNER JOIN v_orders o
	ON op.order_parent_order_id = o.order_procedure_id;
	
SELECT *
FROM v_orders
WHERE level = 1;


/* 7) Create a view for primary care patients by 
excluding sensitive geographic/address information (but include PCP name) */

CREATE VIEW v_patients_primary_care AS
	SELECT 
		p.master_patient_id,
		p.name AS patient_name,
		p.gender,
		p.primary_language,
		p.date_of_birth,
		p.pcp_id,
		ph.full_name AS pcp_name
	FROM patients p
	LEFT OUTER JOIN physicians ph
	ON p.pcp_id = ph.id;
	
SELECT *
FROM v_patients_primary_care;


/* 8) Create a unpopulated materialized view mv_hospital_encounters reporting on the number of encounters 
and ICU patients by year/month by hospital */
CREATE MATERIALIZED VIEW mv_hospital_encounters AS
	SELECT
		h.hospital_id,
		h.hospital_name,
		TO_CHAR(patient_admission_datetime, 'YYYY-MM') AS year_month,
		COUNT(patient_encounter_id) AS num_encounters,
		COUNT(NULLIF(patient_in_icu_flag, 'No')) AS num_icu_patients
	FROM encounters e
	LEFT OUTER JOIN departments d
	ON e.department_id = d.department_id
	LEFT OUTER JOIN hospitals h
	ON d.hospital_id = h.hospital_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3
	WITH NO DATA;

REFRESH MATERIALIZED VIEW mv_hospital_encounters;

SELECT *
FROM mv_hospital_encounters;


-- 9) Populate the new materialized view and alter the name to mv_hospital_encounters_statistics
ALTER MATERIALIZED VIEW mv_hospital_encounters
RENAME TO mv_hospital_encounters_statistics;


/* 10) Create a primary care patients view for pcp_id = 4121 and 
prevent unwanted inserts/updates : 
Set a default value for pcp_id.
Check that inserts work as expected. */
CREATE VIEW v_patients_primary_care_maleham AS
	SELECT
		p.master_patient_id,
		p.name AS patient_name,
		p.gender,
		p.primary_language,
		p.date_of_birth,
		p.pcp_id
	FROM patients p
	WHERE p.pcp_id = 4121
	WITH CHECK OPTION;
	
SELECT *
FROM v_patients_primary_care_maleham;

ALTER VIEW v_patients_primary_care_maleham
ALTER COLUMN pcp_id SET DEFAULT 4121;

INSERT INTO v_patients_primary_care_maleham
VALUES
	(1240, 'John Doe', 'Male', 'ENGLISH', DEFAULT, '2003-07-09');

INSERT INTO v_patients_primary_care_maleham
VALUES
	(1244, 'John Doe', 'Male', 'ENGLISH', 4122, '2003-07-09');