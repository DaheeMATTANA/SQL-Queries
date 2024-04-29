-- ----- General Hospital Database (credit : superdatascience.com)

-- -- TABLE INHERITANCE


-- 1) Relationship definition
-- Parent : General visits
CREATE TABLE visit (
	id SERIAL NOT NULL PRIMARY KEY,
	start_datetime TIMESTAMP,
	end_datetime TIMESTAMP
);
-- Child : Emergency visits
CREATE TABLE emergency_visit (
	emergency_department_id INT NOT NULL,
	triage_level INT,
	triage_datetime TIMESTAMP
) INHERITS (visit);


-- 2) INSERT Values into CHILD table
INSERT INTO emergency_visit VALUES
	(DEFAULT, '2022-01-01 12:00:00', null, 12, 3, null);
	
SELECT *
FROM emergency_visit;

SELECT *
FROM visit;


-- 3)INSERT Values into PARENT table
INSERT INTO visit VALUES
	(DEFAULT, '2022-03-01 11:00:00', '2022-03-03 12:00:00');
	
SELECT *
FROM emergency_visit;

SELECT *
FROM visit;

SELECT *
FROM ONLY visit;


-- 4) Primary keys breakdown
INSERT INTO emergency_visit VALUES
	(2, '2022-03-01 11:00:00', '2022-03-03 12:00:00', 1, 1, null);
	
SELECT *
FROM emergency_visit;

SELECT *
FROM visit;

SELECT *
FROM ONLY visit;