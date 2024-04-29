-- ----- General Hospital Database (credit : superdatascience.com)

-- -- SCHEMA & RELATIONSHIP


-- 1) To get table info
SELECT *
FROM information_schema.tables
WHERE table_schema = 'public';


-- 2) Get columns structure
SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;


-- 3) Get all id columns
SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name like '%id%'
ORDER BY table_name;


-- 4) Get the number of columns by table
SELECT 
	table_name,
	data_type,
	COUNT(*) AS num_columns
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY table_name, data_type
ORDER BY table_name, 3 DESC;


-- 5) Add table comments
COMMENT ON TABLE public.vitals IS
'Patient vital sign data taken at the beginning of the encounter';

-- Check comments
SELECT obj_description('public.vitals'::regclass);


-- 6) Add column comments
COMMENT ON COLUMN public.accounts.primary_icd IS
'Primary International Classification of Diseases (ICD) code for the account';

-- Check comments
-- Get the column ordinal number
SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'accounts';
-- Check the comments
SELECT col_description('public.accounts'::regclass, 1);


-- 7) Add Constraints
ALTER TABLE public.surgical_encounters
ADD CONSTRAINT check_positive_cost
CHECK (total_cost > 0);

-- Check the new constraints
SELECT *
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND table_name = 'surgical_encounters';


-- 8) Drop constraints
ALTER TABLE public.surgical_encounters
DROP CONSTRAINT check_positive_cost;


-- 9) Add foreign keys (attending provider, physicians)
ALTER TABLE encounters
ADD CONSTRAINT encounters_attending_provider_id_fk
FOREIGN KEY (attending_provider_id)
REFERENCES physicians (id);
-- Check
SELECT *
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND table_name = 'encounters'
AND constraint_type = 'FOREIGN KEY';

-- 10) DROP
ALTER TABLE encounters
DROP CONSTRAINT encounters_attending_provider_id_fk;


-- 1) Add a comment for admitting ICD and verify that it was added (ICD = International Classification of Diseases)
COMMENT ON COLUMN accounts.primary_icd IS
'Primary International Classification of Diseases (ICD) code for the account';

SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'accounts';

SELECT col_description('accounts'::regclass, 1);


-- 2) Add NOT NULL constraint on surgical_admission_date field
ALTER TABLE surgical_encounters
ALTER COLUMN surgical_admission_date SET NOT NULL;

SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'surgical_encounters';


-- 3) Add constraint to ensure that patient_discharge_datetime is after patient_admission_datetime OR empty
ALTER TABLE encounters
ADD CONSTRAINT discharge_date_order
CHECK (
	(patient_discharge_datetime > patient_admission_datetime)
	OR (patient_discharge_datetime IS NULL)
);

SELECT *
FROM information_schema.table_constraints
WHERE table_schema = 'public'
AND table_name = 'encounters';

SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'encounters';


-- 4) Drop the previously created constraints
ALTER TABLE surgical_encounters
ALTER COLUMN surgical_admission_date 
DROP NOT NULL;

ALTER TABLE encounters
DROP CONSTRAINT discharge_date_order;