-- ----- General Hospital Database (credit : superdatascience.com)

-- -- STORED PROCEDURES


-- 1) Create procedure
CREATE PROCEDURE sp_test_procedure()
	LANGUAGE plpgsql
	AS $$
	BEGIN
		DROP TABLE IF EXISTS public.test_table;
		CREATE TABLE public.test_table (
			id INT
		);
		COMMIT;
	END;$$
	
-- Check
SELECT *
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'PROCEDURE';
	
-- Call procedure
CALL sp_test_procedure();

-- Modify procedure
CREATE OR REPLACE PROCEDURE sp_test_procedure()
	LANGUAGE plpgsql
	AS $$
	BEGIN
		DROP TABLE IF EXISTS public.test_table_new;
		CREATE TABLE public.test_table_new (
			id INT
		);
		COMMIT;
	END;$$
	
CALL sp_test_procedure();

-- DO NOT RUN BUT AN EXAMPLE OF ALTERING
ALTER PROCEDURE sp_test_procedure
SET SCHEMA PUBLIC;

-- DROP the procedure
DROP PROCEDURE IF EXISTS public.sp_test_procedure;


-- 2) Create a stored procedure to update the cost of a surgery in both the surgical_encounters and surgical_costs table
CREATE PROCEDURE sp_update_surgery_cost(surgery_id_to_update INT, cost_change NUMERIC)
	LANGUAGE plpgsql
	AS $$
	DECLARE
		num_resources INT;
	BEGIN
		-- Update surgical encounters table
		UPDATE public.surgical_encounters
		SET total_cost = total_cost + cost_change
		WHERE surgery_id = surgery_id_to_update;
		COMMIT;
		-- Get number of resources
		SELECT COUNT(*) INTO num_resources
		FROM public.surgical_costs
		WHERE surgery_id = surgery_id_to_update;
		-- Update costs table
		UPDATE public.surgical_costs
		SET resource_cost = resource_cost + (cost_change / num_resources)
		WHERE surgery_id = surgery_id_to_update;
		COMMIT;
	END;
	$$;

-- Total cost of surgery 6518 (5954.842261)
SELECT *
FROM surgical_encounters
WHERE surgery_id = 6518;

-- Aggregated total cost from surgical costs table for surgery 6518
SELECT SUM(resource_cost)
FROM surgical_costs
WHERE surgery_id = 6518;

-- Call the procedure
CALL sp_update_surgery_cost(6518, 1000);

-- recheck (now 6954.842261)
SELECT *
FROM surgical_encounters
WHERE surgery_id = 6518;

SELECT *
FROM surgical_costs
WHERE surgery_id = 6518;

-- Undo the procedure
CALL sp_update_surgery_cost(6518, -1000);

-- Rename
ALTER PROCEDURE sp_update_surgery_cost
RENAME TO sp_update_surgical_cost;