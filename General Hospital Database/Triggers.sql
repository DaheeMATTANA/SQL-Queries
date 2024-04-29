-- ----- General Hospital Database (credit : superdatascience.com)

-- -- TRIGGERS


-- 1) Create a trigger function to clean physicians name data
CREATE FUNCTION f_clean_physician_name()
	RETURNS TRIGGER
	LANGUAGE plpgsql
	AS $$
	BEGIN
		IF NEW.last_name IS NULL OR NEW.first_name IS NULL THEN
			RAISE EXCEPTION 'Name cannot be null';
		ELSE
			NEW.first_name = TRIM(NEW.first_name);
			NEW.last_name = TRIM(NEW.last_name);
			NEW.full_name = CONCAT(NEW.last_name, ', ', NEW.first_name);
			RETURN NEW;
		END IF;
	END;
	$$
	
	
-- 2) Attach to the physicians table
CREATE TRIGGER tr_clean_physician_name
	BEFORE INSERT
	ON physicians
	FOR EACH ROW
	EXECUTE PROCEDURE f_clean_physician_name();
	
	
-- 3) Insert new data
SELECT *
FROM physicians;

INSERT INTO physicians VALUES
	(' John ', ' Doe ', 'Something', 123456);


-- 4) Trigger function has fixed the badly typed data
SELECT *
FROM physicians
WHERE id = 123456;

-- disable
ALTER TABLE physicians
DISABLE TRIGGER tr_clean_physician_name;

-- Test
INSERT INTO physicians VALUES
	(' John ', null, 'Something', 12346);

-- hasn't been fixed
SELECT *
FROM physicians
WHERE id = 12346;

-- Enable
ALTER TABLE physicians
ENABLE TRIGGER ALL;

-- Test
INSERT INTO physicians VALUES
	(' John ', null, 'Something', 12347);
-- we get error msg due to the checking null funciton inside the trigger


-- 5) Rename trigger
ALTER TRIGGER tr_clean_physician_name ON physicians
RENAME TO tr_clean_name;


-- 6) Drop trigger
DROP TRIGGER IF EXISTS tr_clean_name ON physicians;


-- 7) Create a trigger named my_trigger that runs after an update to
-- surgical_encounters to update surgical_costs if the total cost changes
CREATE FUNCTION f_update_surgical_costs()
	RETURNS TRIGGER
	LANGUAGE plpgsql
	AS $$
	DECLARE num_resources INT;
	BEGIN
		-- Get resource count
		SELECT COUNT(*) INTO num_resources
		FROM public.surgical_costs
		WHERE surgery_id = NEW.surgery_id;
		-- Update costs table
		IF NEW.total_cost != OLD.total_cost THEN
			UPDATE public.surgical_costs
			SET resource_cost = NEW.total_cost / num_resources
			WHERE surgery_id = NEW.surgery_id;
		END IF;
		RETURN NEW;
	END;
	$$
	

CREATE TRIGGER my_trigger
	AFTER UPDATE
	ON public.surgical_encounters
	FOR EACH ROW
	EXECUTE PROCEDURE f_update_surgical_costs();

-- Rename the trigger to tr_update_surgical_costs
ALTER TRIGGER my_trigger ON surgical_encounters
RENAME TO tr_update_surgical_costs;


-- Check that the trigger works by updating the cost of one surgery
UPDATE surgical_encounters
SET total_cost = total_cost + 1000
WHERE surgery_id = 14615;

SELECT *
FROM surgical_encounters
WHERE surgery_id = 14615;

SELECT SUM(resource_cost)
FROM surgical_costs
WHERE surgery_id = 14615;


-- Drop the trigger
DROP TRIGGER IF EXISTS tr_update_surgical_costs ON surgical_encounters;