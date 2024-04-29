-- ----- General Hospital Database (credit : superdatascience.com)

-- -- TRANSACTION


-- 1) Update data in vitals table 
SELECT *
FROM vitals
WHERE patient_encounter_id = 1854663;

-- Update bp_diastolic of patient 1854663 (original data : bp_diastolic = 52)
UPDATE vitals
SET bp_diastolic = 100
WHERE patient_encounter_id = 1854663;

-- Update account balance of account id 11417340 (original data : total_account_balance = 15077.90)
SELECT *
FROM accounts
WHERE account_id = 11417340;

UPDATE accounts
SET total_account_balance = 0
WHERE account_id = 11417340;


-- 2) Transaction

BEGIN TRANSACTION;

SELECT NOW();

SELECT *
FROM physicians
ORDER BY id;

-- Original data : first_name = 'Gage'
UPDATE physicians
SET first_name = 'Bill',
	full_name = CONCAT(last_name, ', Bill')
WHERE id = 1;

END TRANSACTION;

SELECT *
FROM physicians
WHERE id = 1;

-- 3) ROLLBACK
BEGIN;

SELECT NOW();

UPDATE physicians
SET first_name = 'Gage',
	full_name = CONCAT(last_name, ', Gage')
WHERE id = 1;

ROLLBACK;

-- 4) Error case
BEGIN;

SELECT 
FROM physicias;
-- Syntax error : all the transaction commands will fail

SELECT *
FROM physicians;

END;  -- It's been rolled back (abandoned)

SELECT *
FROM physicians
WHERE id = 1;


-- 5) SAVEPOINTS  (original data : 2570046, bp_diastolic = 91)
BEGIN;

UPDATE vitals
SET bp_diastolic = 120
WHERE patient_encounter_id = 2570046;

SAVEPOINT vitals_updated;

UPDATE accounts
SET total_account_balance = 1000
WHERE account_id = 11417340;

ROLLBACK TO vitals_updated;
COMMIT;

SELECT *
FROM vitals
WHERE patient_encounter_id = 2570046;

SELECT *
FROM accounts
WHERE account_id = 11417340;

--
BEGIN;

UPDATE vitals
SET bp_diastolic = 52
WHERE patient_encounter_id = 1854663;

SAVEPOINT vitals_updated;

UPDATE accounts
SET total_account_balance = 1000
WHERE account_id = 11417340;

RELEASE SAVEPOINT vitals_updated;
COMMIT;

SELECT *
FROM vitals
WHERE patient_encounter_id = 1854663;

SELECT *
FROM accounts
WHERE account_id = 11417340;


-- 6) Locking (using second query panel)
SELECT *
FROM physicians;

BEGIN;

SELECT NOW();

LOCK TABLE physicians;

ROLLBACK;


-- 7) Revert our update to the physicians table inside a transaction using LOCK TABLE (Krollman Gage)
BEGIN;

LOCK TABLE physicians;

UPDATE physicians
SET first_name = 'Gage',
	full_name = CONCAT(last_name, ', Gage') 
WHERE id = 1;

COMMIT;

SELECT *
FROM physicians
WHERE id = 1;

-- 8) Try dropping a table inside a transaction with ROLLBACK & confirm the table was not dripped
BEGIN;

DROP TABLE practices;

ROLLBACK;

SELECT *
FROM accounts;


/* Inside one transaction :
1/ update the account balance for account_id 11417340 to be $15,077.90
2/ Create a savepoint
3/ Drop any table
4/ Rollback to the savepoint
5/ Commit the transaction
6/ Verify the changes made/not made */

BEGIN;

LOCK TABLE accounts;

UPDATE accounts
SET total_account_balance = 15077.9
WHERE account_id = 11417340;

SAVEPOINT balance_change;

DROP TABLE vitals;

ROLLBACK TO balance_change;

COMMIT;

SELECT *
FROM accounts
WHERE account_id = 11417340;

SELECT *
FROM vitals;