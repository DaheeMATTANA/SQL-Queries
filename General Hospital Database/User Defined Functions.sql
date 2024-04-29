-- ----- General Hospital Database (credit : superdatascience.com)

-- -- USER DEFINED FUNCTIONS


-- 1) Test Function
CREATE FUNCTION f_test_function(a INT, b INT)
	RETURNS INT
	LANGUAGE SQL
	AS
	'SELECT $1 + $2;';
-- Test this function
SELECT f_test_function(1, 2);
SELECT f_test_function(2, 2);

-- Translate it into plpgsql language
CREATE FUNCTION f_plpgsql_function(a INT, b INT)
	RETURNS INT
	AS $$
	BEGIN
		RETURN a + b;
	END;
	$$ LANGUAGE plpgsql;
-- Test this function with
-- Positional notation :
SELECT f_plpgsql_function(1, 2);
-- Named notation :
SELECT f_plpgsql_function(a => 1, b => 2);
-- Mixed :
SELECT f_plpgsql_function(1, b => 2);


-- 2) Calculate length of stay of patient
CREATE FUNCTION f_calculate_los(start_time TIMESTAMP, end_time TIMESTAMP)
	RETURNS NUMERIC
	AS $$
	BEGIN
		RETURN ROUND((EXTRACT(EPOCH FROM (end_time - start_time))/3600)::NUMERIC, 2);
	END;
	$$ LANGUAGE plpgsql;
	
-- Call the function in a query
SELECT
	 patient_admission_datetime,
	 patient_discharge_datetime,
	 f_calculate_los(patient_admission_datetime, patient_discharge_datetime) AS los
FROM encounters;

-- Find the function in the information schema
SELECT *
FROM information_schema.routines
WHERE ROUTINE_SCHEMA = 'public';

-- Modify function
CREATE OR REPLACE FUNCTION f_calculate_los(start_time TIMESTAMP, end_time TIMESTAMP)
	RETURNS NUMERIC
	AS $$
	BEGIN
		RETURN ROUND((EXTRACT(EPOCH FROM (end_time - start_time))/3600)::NUMERIC, 4);
	END;
	$$ LANGUAGE plpgsql;
	
-- Drop function
DROP FUNCTION IF EXISTS f_test_function;

-- Rename function
ALTER FUNCTION f_calculate_los
RENAME TO f_calculate_los_hours;


-- 3) Create a function to mask text fields using the md5() function
CREATE FUNCTION f_mask_field(field TEXT)
	RETURNS TEXT
	LANGUAGE plpgsql
	AS $$
	BEGIN
		RETURN MD5(field);
	END;
	$$;
	
SELECT 
	name,
	f_mask_field(name) AS masked_name
FROM patients;


-- 4) Update the function so that it returns a string with 'patient' + the first 8 digits of the hash
-- Extra : add handling for null names
CREATE OR REPLACE FUNCTION f_mask_field(field TEXT)
	RETURNS TEXT
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF field IS NULL THEN RETURN null;
		ELSE RETURN CONCAT('Patient ', LEFT(md5(field), 8));
		END IF;
	END;
	$$;

SELECT f_mask_field(null);


-- 5) Change the name of the function so it more explicitly refers to masking a patient's name
ALTER FUNCTION f_mask_field
RENAME TO f_mask_patient_name;