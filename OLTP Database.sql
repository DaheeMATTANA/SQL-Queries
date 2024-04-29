-- ----- OLTP (Online Transactional Processing) Database (credit : superdatascience.com)


/* 1) Investigate if the transactions table fits into First Normal Form
		: No duplicate rows, each cell contains only one value */
SELECT *
FROM transactions;

SELECT COUNT(*)
FROM transactions;
-- 3455 rows

SELECT COUNT(*)
FROM(
	SELECT DISTINCT *
	FROM transactions
) AS nf_check;
-- 3455 rows
-- table is in 1NF



/* 2) Investigate if the transactions table fits into Second Normal Form
		: 1NF, Every non-prime attribute of the table is dependent on the whole of every candidate key */
SELECT *
FROM transactions;

-- Candidate Key : {transaction id}, {time stamp + customer id}
-- Prime Attribute : transaction id, time stamp, customer id / Non-prime Attribute : the rest
-- table is NOT in 2NF (first name, surname, shipping state, loyalty discount -> solely depend on customer id)


-- STEP 1 : Separate customer-specific columns
CREATE TABLE TMP AS 
SELECT 
	customerid, 
	firstname, 
	surname, 
	shipping_state, 
	loyalty_discount
FROM transactions;
-- 3455 rows
SELECT *
FROM TMP;


-- STEP 2 : Remove duplicates
CREATE TABLE Customer AS
SELECT DISTINCT *
FROM TMP;
--942 rows

SELECT *
FROM customer;
-- 2NF CONFIRMED


-- STEP 3 : From the original table, remove customer-specific columns but leave the customer id column
SELECT *
FROM transactions;

ALTER TABLE transactions 
DROP COLUMN firstname,
DROP COLUMN surname,
DROP COLUMN shipping_state,
DROP COLUMN loyalty_discount;


-- STEP 4 : Drop the temporary table
DROP TABLE TMP;



/* 3) Investigate if these tables fit into Third Normal Form
		: 2NF, Every non-prime attribute is non-transitively dependent on every candidate key */
SELECT *
FROM customer;
-- 3NF CONFIRMED

SELECT *
FROM transactions;
-- table is NOT in 3NF (description and retail price are transitive values from item)

-- Transitive dependencies need to be separated into their own table
-- STEP 1 : Separate transitively dependent columns
CREATE TABLE TMP AS
SELECT 
	item,
	description,
	retail_price
FROM transactions;

SELECT *
FROM TMP;
-- 3455 rows

-- STEP 2 : Create seperate table called item
CREATE TABLE item AS
SELECT DISTINCT *
FROM TMP;

SELECT *
FROM item;
-- 126 rows

-- STEP 3 : Drop these columns in the original table
ALTER TABLE transactions
DROP COLUMN description,
DROP COLUMN retail_price;

-- STEP 4 : Drop the temporary table
DROP TABLE TMP;

SELECT *
FROM transactions;
-- 3NF CONFIRMED