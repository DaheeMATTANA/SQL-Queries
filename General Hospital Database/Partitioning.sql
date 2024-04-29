-- ----- General Hospital Database (credit : superdatascience.com)

-- -- PARTITIONING

-- Range Partitioning
-- 1) Move over our surgical encounters table to a new partition table
-- STEP 1 : Create partitioned table
CREATE TABLE surgical_encounters_partitioned (
	surgery_id INTEGER NOT NULL,
	master_patient_id INTEGER NOT NULL,
	surgical_admission_date DATE NOT NULL,
	surgical_discharge_date DATE
) PARTITION BY RANGE (surgical_admission_date);

-- STEP 2 : Create partitions
SELECT DISTINCT EXTRACT(YEAR FROM surgical_admission_date)
FROM surgical_encounters;

CREATE TABLE surgical_encounters_y2016
PARTITION OF surgical_encounters_partitioned
FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');

CREATE TABLE surgical_encounters_y2017
PARTITION OF surgical_encounters_partitioned
FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');

CREATE TABLE surgical_encounters_default
PARTITION OF surgical_encounters_partitioned
DEFAULT;

-- STEP 3 : Data transfer
INSERT INTO surgical_encounters_partitioned
	SELECT
		surgery_id,
		master_patient_id,
		surgical_admission_date,
		surgical_discharge_date
	FROM surgical_encounters;
	
-- STEP 4 : optional, but create an index
CREATE INDEX ON surgical_encounters_partitioned (surgical_admission_date);

-- 2016 : 7404 records, 2017 : 1999 records
SELECT
	EXTRACT(YEAR FROM surgical_admission_date),
	COUNT(*)
FROM surgical_encounters
GROUP BY 1;

-- STEP 5 : Verify
SELECT 
	COUNT(*),
	MIN(surgical_admission_date),
	MAX(surgical_admission_date)
FROM surgical_encounters_y2016;

SELECT 
	COUNT(*),
	MIN(surgical_admission_date),
	MAX(surgical_admission_date)
FROM surgical_encounters_y2017;

SELECT 
	COUNT(*),
	MIN(surgical_admission_date),
	MAX(surgical_admission_date)
FROM surgical_encounters_default;



-- List Partitioning
-- 1) Departments table
CREATE TABLE departments_partitioned(
	hospital_id INTEGER NOT NULL,
	department_id INTEGER NOT NULL,
	deparment_name TEXT,
	specialty_description TEXT
) PARTITION BY list (hospital_id);


SELECT DISTINCT hospital_id
FROM departments;

-- 2) Partition by hospital
CREATE TABLE departments_h111000
PARTITION OF departments_partitioned
FOR VALUES IN (111000);

CREATE TABLE departments_h112000
PARTITION OF departments_partitioned
FOR VALUES IN (112000);

CREATE TABLE departments_default
PARTITION OF departments_partitioned
DEFAULT;

-- 3) Values
INSERT INTO departments_partitioned
	SELECT 
		hospital_id,
		department_id,
		department_name,
		specialty_description
	FROM departments;

-- 4) Verify
SELECT 
	hospital_id,
	COUNT(*)
FROM departments_h111000
GROUP BY 1;

SELECT 
	hospital_id,
	COUNT(*)
FROM departments_h112000
GROUP BY 1;

-- 5) Defaults are the partitions that were NOT created, the remainder of partitions
SELECT 
	hospital_id,
	COUNT(*)
FROM departments_default
GROUP BY 1;



-- Hash Partitioning
-- 1) orders_procedures : there is no date column, hospital_id column etc, good candidate for hash partitioning
CREATE TABLE orders_procedures_partitioned(
	order_procedure_id INTEGER NOT NULL,
	patient_encounter_id INTEGER NOT NULL,
	ordering_provider_id INTEGER REFERENCES physicians (id),
	order_cd TEXT,
	order_procedure_description TEXT
) PARTITION BY hash (order_procedure_id, patient_encounter_id);

-- you don't usually need default table
CREATE TABLE orders_procedures_hash0
PARTITION OF orders_procedures_partitioned
FOR VALUES WITH (modulus 3, remainder 0);

CREATE TABLE orders_procedures_hash1
PARTITION OF orders_procedures_partitioned
FOR VALUES WITH (modulus 3, remainder 1);

CREATE TABLE orders_procedures_hash2
PARTITION OF orders_procedures_partitioned
FOR VALUES WITH (modulus 3, remainder 2);

-- 2) Insert data
INSERT INTO orders_procedures_partitioned
	SELECT 
		order_procedure_id,
		patient_encounter_id,
		ordering_provider_id,
		order_cd,
		order_procedure_description
	FROM orders_procedures;

-- 3) Verify
SELECT 'hash0', COUNT(*)
FROM orders_procedures_hash0
UNION
SELECT 'hash1', COUNT(*)
FROM orders_procedures_hash1
UNION
SELECT 'hash2', COUNT(*)
FROM orders_procedures_hash2;





-- Excercise
-- 1) Create and populate a new encounters table partitioned by hospital_id
CREATE TABLE encounters_partitioned (
	hospital_id INT NOT NULL,
	patient_encounter_id INT NOT NULL,
	master_patient_id INT,
	admitting_provider_id INT REFERENCES physicians (id),
	department_id INT REFERENCES departments (department_id),
	patient_admission_datetime TIMESTAMP,
	patient_discharge_datetime TIMESTAMP,
	CONSTRAINT encounters_partitioned_pk PRIMARY KEY
		(hospital_id, patient_encounter_id)
) PARTITION BY list (hospital_id);
-- Have a look at the possible partition
SELECT DISTINCT d.hospital_id
FROM encounters e
LEFT OUTER JOIN departments d
ON e.department_id = d.department_id
ORDER BY 1;
-- Create partitions
CREATE TABLE encounters_h111000
PARTITION OF encounters_partitioned
FOR VALUES IN (111000);
CREATE TABLE encounters_h112000
PARTITION OF encounters_partitioned
FOR VALUES IN (112000);
CREATE TABLE encounters_h114000
PARTITION OF encounters_partitioned
FOR VALUES IN (114000);
CREATE TABLE encounters_h115000
PARTITION OF encounters_partitioned
FOR VALUES IN (115000);
CREATE TABLE encounters_h9900006
PARTITION OF encounters_partitioned
FOR VALUES IN (9900006);
CREATE TABLE encounters_default
PARTITION OF encounters_partitioned
DEFAULT;
-- Populate partitions
INSERT INTO encounters_partitioned
SELECT
	d.hospital_id,
	e.patient_encounter_id,
	e.master_patient_id,
	e.admitting_provider_id,
	e.department_id,
	e.patient_admission_datetime,
	e.patient_discharge_datetime
FROM encounters e
LEFT OUTER JOIN departments d
ON e.department_id = d.department_id;
-- Verify
SELECT *
FROM encounters_h111000;
SELECT *
FROM encounters_h112000;
-- Creat Index
CREATE INDEX ON encounters_partitioned (patient_encounter_id);


-- 2) Create a new vitals table partitioned by a datetime field (hint : try the patient_admission_datetime) field in encouters)
CREATE TABLE vitals_partitioned (
	patient_encounter_id INT NOT NULL REFERENCES encounters (patient_encounter_id),
	collection_datetime TIMESTAMP NOT NULL,
	bp_diastolic INT,
	bp_systolic INT,
	bmi NUMERIC,
	temperature NUMERIC,
	weight INT
) PARTITION BY RANGE (collection_datetime);
-- have a look at the possible partition
SELECT DISTINCT EXTRACT(YEAR FROM patient_admission_datetime)
FROM encounters;
-- Create partitions
CREATE TABLE vitals_y2015
PARTITION OF vitals_partitioned
FOR VALUES FROM ('2015-01-01') TO ('2016-01-01');
CREATE TABLE vitals_y2016
PARTITION OF vitals_partitioned
FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');
CREATE TABLE vitals_y2017
PARTITION OF vitals_partitioned
FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');
CREATE TABLE vitals_default
PARTITION OF vitals_partitioned
DEFAULT;
-- Populate data
INSERT INTO vitals_partitioned
SELECT
	v.patient_encounter_id,
	e.patient_admission_datetime AS collection_datetime,
	v.bp_diastolic,
	v.bp_systolic,
	v.bmi,
	v.temperature,
	v.weight
FROM vitals v
LEFT OUTER JOIN encounters e
ON v.patient_encounter_id = e.patient_encounter_id;
-- Verify
SELECT *
FROM vitals_y2016;
-- Create index
CREATE INDEX ON vitals_partitioned (collection_datetime);