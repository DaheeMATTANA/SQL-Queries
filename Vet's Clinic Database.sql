-- ----- Vet's Clinic Database (credit : superdatascience.com)

-- CREATE TABLES & LOAD DATA
-- 1) Create 'pets' tables & load data from csv files
CREATE TABLE pets (
    petid VARCHAR,
    name VARCHAR,
    kind VARCHAR,
    gender VARCHAR,
    age INT,
    ownerid VARCHAR
);

COPY pets FROM '\P9-Pets.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM Pets;


-- 2) Create 'owners' tables & load data from csv files
CREATE TABLE owners (
    ownerid varchar,
    name varchar,
    surname varchar,
    streetaddress varchar,
    city varchar,
    state varchar(2),
    statefull varchar,
    zipcode varchar
);

COPY owners FROM '\P9-Owners.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM owners;


-- 3) Create 'proceduredetails' tables & load data from csv files
CREATE TABLE proceduredetails (
    proceduretype varchar,
    proceduresubcode varchar,
    description varchar,
    price float
);

COPY proceduredetails FROM '\P9-ProceduresDetails.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM proceduredetails;

 
-- 4) Create 'procedurehistory' tables & load data from csv files
CREATE TABLE procedurehistory (
    petid varchar,
    proceduredate date,
    proceduretype varchar,
    proceduresubcode varchar
);

COPY procedurehistory FROM '\P9-ProceduresHistory.csv' DELIMITER ',' CSV HEADER;

SELECT *
FROM procedurehistory;


-- JOINS
-- 1) Link pet information and owner information together
SELECT *
FROM pets
LEFT JOIN owners
ON pets.ownerid = owners.ownerid;


-- 2) Find owners and their pets whose first initials are the same
SELECT 
	p.name AS pet_name, 
	o.name AS owner_name
FROM pets AS p
LEFT JOIN owners AS o
ON p.ownerid = o.ownerid
WHERE LEFT(p.name, 1) = LEFT(o.name, 1);


-- 3) Retrieve pet information who had at least one procedure in this clinic
SELECT *
FROM pets AS p
INNER JOIN procedurehistory AS pc
ON p.petid = pc.petid;


-- 4) Find all the procedures with or without pet information
SELECT *
FROM pets AS p
FULL OUTER JOIN procedurehistory AS pc
ON p.petid = pc.petid;


-- 5) Find out details of procedures executed for all procedures
SELECT *
FROM procedurehistory;

SELECT *
FROM proceduredetails;

SELECT *
FROM procedurehistory AS a
LEFT JOIN proceduredetails AS b
ON a.proceduretype = b. proceduretype 
AND a.proceduresubcode = b.proceduresubcode;


-- 6) Retrieve pets who had procedures in this clinic and details of the procedures
SELECT  
	p.petid, 
	p.ownerid, 
	h.proceduredate, 
	h.proceduretype, 
	h.proceduresubcode, 
	d.description, 
	d.price
FROM pets AS p
INNER JOIN procedurehistory AS h
ON p.petid = h.petid
LEFT JOIN proceduredetails AS d
ON h.proceduretype = d.proceduretype
AND h.proceduresubcode = d.proceduresubcode;


-- 7) All possible combination of owners and pets
SELECT *
FROM pets
CROSS JOIN owners;