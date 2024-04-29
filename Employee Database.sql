-- ----- Employee Database (credit : Jose Portilla, Pierian Data www.pieriantraining.com)


-- 1) CREATE TABLE called account
CREATE TABLE account(
	user_id SERIAL PRIMARY KEY,
	username VARCHAR(50) UNIQUE NOT NULL,
	password VARCHAR(50) NOT NULL,
	email VARCHAR(250) UNIQUE NOT NULL,
	created_on TIMESTAMP NOT NULL,
	last_login TIMESTAMP
);


-- 2) CREATE TABLE called job
CREATE TABLE job(
	job_id SERIAL PRIMARY KEY,
	job_name VARCHAR(200) UNIQUE NOT NULL
);


-- 3) Referencing Foreign Key
CREATE TABLE account_job(
	user_id INTEGER REFERENCES account(user_id),
	job_id INTEGER REFERENCES job(job_id),
	hired_date TIMESTAMP
);


-- 4) INSERT values
INSERT INTO account(username, password, email, created_on)
VALUES
('Jose', 'password', 'jose@mail.com', CURRENT_TIMESTAMP);

SELECT *
FROM account;

INSERT INTO job(job_name)
VALUES
('Astronaut');

SELECT *
FROM job;

INSERT INTO job(job_name)
VALUES
('President');

INSERT INTO account_job(user_id, job_id, hired_date)
VALUES
(1, 1, CURRENT_TIMESTAMP);

SELECT *
FROM account_job;

-- What happens if we insert user_id which doesn't exist
INSERT INTO account_job(user_id, job_id, hired_date)
VALUES
(10, 10, CURRENT_TIMESTAMP);
-- "Violates foreign key constraint"


-- 5) UPDATE table
SELECT *
FROM account;

UPDATE account
SET last_login = created_on;


-- 6) UPDATE join
SELECT *
FROM account_job;

UPDATE account_job
SET hired_date = account.created_on
FROM account
WHERE account_job.user_id = account.user_id;


-- 7) RETURNING values at the same time
UPDATE account
SET last_login = CURRENT_TIMESTAMP
RETURNING email, created_on, last_login;


-- 8) DELETE rows
INSERT INTO job(job_name)
VALUES
('Cowboy');

SELECT *
FROM job;

DELETE FROM job
WHERE job_name = 'Cowboy'
RETURNING job_id, job_name;


CREATE TABLE information(
	info_id SERIAL PRIMARY KEY,
	title VARCHAR(500) NOT NULL,
	person VARCHAR(50) NOT NULL UNIQUE
);


SELECT *
FROM information;


-- 9) RENAME the table
ALTER TABLE information
RENAME TO new_info;

SELECT *
FROM new_info;


-- 10) RENAME COLUMN
ALTER TABLE new_info
RENAME COLUMN person TO people;


-- 11) ALTER constraints
INSERT INTO new_info(title)
VALUES
('some new title');
-- Violate NOT NULL constraint, let's remove the constraint
ALTER TABLE new_info
ALTER COLUMN people 
DROP NOT NULL;


-- 12) DROP COLUMN
ALTER TABLE new_info
DROP COLUMN people;
-- After dropping, you get an error

-- But if you add in IF EXIST command, 
-- you get a notice that SQL will ignore this command since the column already do not exist
ALTER TABLE new_info
DROP COLUMN IF EXISTS people;


-- 13) CHECK constraints
CREATE TABLE employees(
	emp_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	birthdate DATE CHECK (birthdate > '1900-01-01'),
	hire_date DATE CHECK (hire_date > birthdate),
	salary INTEGER CHECK (salary > 0)
);

SELECT *
FROM employees;

INSERT INTO employees(
first_name,
last_name,
birthdate,
hire_date,
salary
)
VALUES
('Jose',
'Portilla',
'1899-11-03',
'2010-01-01',
100
);
-- Violation of the check constraint


INSERT INTO employees(
first_name,
last_name,
birthdate,
hire_date,
salary
)
VALUES
('Jose',
'Portilla',
'1990-11-03',
'2010-01-01',
100
);


INSERT INTO employees(
first_name,
last_name,
birthdate,
hire_date,
salary
)
VALUES
('Sammy',
'Smith',
'1990-11-03',
'2010-01-01',
100
);
-- NOTICE the SERIAL has counted the failed attempts


-- 14) NULLIF
SELECT *
FROM depts

SELECT (
	SUM(CASE WHEN department = 'A' THEN 1 ELSE 0 END) /
	SUM(CASE WHEN department = 'B' THEN 1 ELSE 0 END)
) AS department_ratio
FROM depts

DELETE FROM depts
WHERE department = 'B'

-- To avoid dividing by zero
SELECT (
	SUM(CASE WHEN department = 'A' THEN 1 ELSE 0 END) /
	NULLIF(SUM(CASE WHEN department = 'B' THEN 1 ELSE 0 END), 0)
) AS department_ratio
FROM depts