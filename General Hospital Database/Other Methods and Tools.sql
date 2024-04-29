-- ----- General Hospital Database (credit : superdatascience.com)

-- -- OTHER METHODS AND TOOLS


-- 1) COPY
-- Export physicians table
COPY physicians TO 'C:\Users\Public\physicians.csv'
WITH DELIMITER ',' CSV HEADER;

-- Create a table to import a table
CREATE TABLE physicians_2 (
	first_name TEXT,
	last_name TEXT,
	full_name TEXT,
	id INT
);

-- Import table into it
COPY physicians_2 FROM 'C:\Users\Public\physicians.csv'
WITH DELIMITER ',' CSV HEADER;

-- Check
SELECT *
FROM physicians_2;


-- 2) Array functions
-- array aggregation
SELECT 
	surgery_id,
	ARRAY_AGG(DISTINCT resource_name ORDER BY resource_name) AS resource_array
FROM surgical_costs
GROUP BY surgery_id;
-- Self join (surgeries using same group of resources and full blood count)
WITH resources AS (
	SELECT 
		surgery_id,
		ARRAY_AGG(DISTINCT resource_name ORDER BY resource_name) AS resource_array
	FROM surgical_costs
	GROUP BY surgery_id
	)
SELECT
	r1.surgery_id,
	r2.surgery_id,
	r1.resource_array
FROM resources r1
LEFT OUTER JOIN resources r2
ON r1.surgery_id != r2.surgery_id
AND r1.resource_array = r2.resource_array
WHERE r1.resource_array @> array['Full Blood Count']::varchar[];


-- 3) JSON
-- construct JSON object, pull text 
SELECT '{"first_name":"Ben", "last_name":"Doe"}'::JSONB->>'first_jname';

-- construct JSONB object field
SELECT
	jsonb_build_object(
		'id', id,
		'first_name', first_name,
		'last_name', last_name
	) AS physician_json
FROM physicians;


-- 4) Modules and Extensions
-- available extensions
SELECT *
FROM pg_available_extensions
ORDER BY 1;

-- install extension fuzzystrmatch
CREATE EXTENSION fuzzystrmatch SCHEMA public;

-- Check installation
SELECT *
FROM pg_available_extensions
ORDER BY 1;

-- Test extension function
SELECT levenshtein('bigelow', 'bigalo');    -- distance from two similar words

-- Other extension
CREATE EXTENSION earthdistance CASCADE SCHEMA public;

-- distance between patients and the hospital 111000
SELECT
	p.latitude,
	p.longitude,
	h.latitude,
	h.longitude,
	EARTH_DISTANCE(
		LL_TO_EARTH(p.latitude, p.longitude),
		LL_TO_EARTH(h.latitude, h.longitude)
	) / 1000 AS distance_km
FROM patients p
INNER JOIN hospitals h
ON h.hospital_id = 111000;


-- 5) Install another extension that comes pre-packages with Postgres
SELECT *
FROM pg_available_extensions
ORDER BY 1;

CREATE EXTENSION insert_username SCHEMA public;


-- 6) Run EXPLAIN ANALYZE on a DELETE statement
BEGIN;
EXPLAIN ANALYZE
DELETE FROM public.vitals;

ROLLBACK;


-- 7) Build a JSONB object field for the patients table using name and address data
SELECT 
	JSONB_BUILD_OBJECT(
		'name', name,
		'address', address_full,
		'city', city,
		'state', state,
		'zip_code', zip_cd
	) AS address_jsonb
FROM patients;