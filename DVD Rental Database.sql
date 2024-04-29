-- ----- DVD Rental Database (credit : Jose Portilla, Pierian Data www.pieriantraining.com)


-- 1) Find out how many payment transactions were greater than $5.00
SELECT COUNT(amount)
FROM payment
WHERE amount > 5;


-- 2) How many actors have a first name that starts with the letter P?
SELECT COUNT(actor_id)
FROM actor
WHERE first_name LIKE 'P%';


-- 3) Customer with the most number of transaction
SELECT customer_id, COUNT(amount)
FROM payment
GROUP BY customer_id
ORDER BY COUNT(amount) DESC;


-- 4) Customer with the most amount purchased
SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC;


-- 5) Amount purchased per staff, per customer
SELECT staff_id, customer_id, SUM(amount)
FROM payment
GROUP BY staff_id, customer_id
ORDER BY staff_id, customer_id;

SELECT staff_id, customer_id, SUM(amount)
FROM payment
GROUP BY staff_id, customer_id
ORDER BY customer_id, staff_id;

SELECT staff_id, customer_id, SUM(amount)
FROM payment
GROUP BY staff_id, customer_id
ORDER BY SUM(amount) DESC;


-- 6) Payments per date
SELECT 
	DATE(payment_date),
	COUNT(*)
FROM payment
GROUP BY DATE(payment_date);


-- 7) Who gets the bonus amongst staffs according to number of transaction not the dollar amount?
SELECT staff_id, COUNT(payment_id)
FROM payment
GROUP BY staff_id;


-- 8) What is the average replacement cost per MPAA rating?
SELECT rating, ROUND(AVG(replacement_cost), 2)
FROM film
GROUP BY rating;


-- 9) Top 5 customer IDs based on total spend?
SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 5;


-- 10) Platinum status : 40 or more transaction payments, what customer ids are eligible?
SELECT customer_id, COUNT(*)
FROM payment
GROUP BY customer_id
HAVING COUNT(*) >= 40;


-- 11) Customer ids who have spent more than $100 with staff member 2?
SELECT customer_id, SUM(amount)
FROM payment
WHERE staff_id = 2
GROUP BY customer_id
HAVING SUM(amount) > 100;


-- 12) Return the customer IDs of customers who have spent at least $110 with the staff member who has an ID of 2
SELECT customer_id, SUM(amount)
FROM payment
WHERE staff_id = 2
GROUP BY customer_id
HAVING SUM(amount) >= 110;


-- 13) How many films begin with the letter J?
SELECT COUNT(*)
FROM film
WHERE title LIKE 'J%';


-- 14) What customer has the highest customer ID number whose name starts with an 'E' and has an address ID lower than 500?
SELECT first_name, last_name
FROM customer
WHERE first_name LIKE 'E%'
AND address_id < 500
ORDER BY customer_id DESC
LIMIT 1;


-- 15) What are the emails of the customers who live in California?
SELECT district, email
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id
WHERE district = 'California';

-- 16) List of all the movies "Nick Wahlberg" has been in
-- 2 seperate queries
SELECT *
FROM actor
WHERE first_name = 'Nick' 
AND last_name = 'Wahlberg';

SELECT title
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
WHERE actor_id = 2;

-- 1 Query Solution
SELECT title
FROM actor
INNER JOIN film_actor
ON actor.actor_id = film_actor.actor_id
INNER JOIN film
ON film_actor.film_id = film.film_id
WHERE first_name = 'Nick'
AND last_name = 'Wahlberg';


-- 17) During which months did payments occur ? (full month name)
SELECT DISTINCT TO_CHAR(payment_date, 'Month')
FROM payment;


-- 18) How many payments occurred on a Monday?
SELECT COUNT(*)
FROM payment
WHERE EXTRACT(DOW FROM payment_date) = 1;


-- 19) films with higher rental rate than the average rental rate
SELECT title, rental_rate
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film);


-- 20) films that have been returned in certain set of dates (May 25th 2005, May 30th 2005)
-- Method subquery
SELECT film_id, title
FROM film
WHERE film_id IN
(SELECT b.film_id
FROM rental AS a
INNER JOIN inventory AS b
ON a.inventory_id = b.inventory_id
WHERE return_date BETWEEN '2005-05-29' AND '2005-05-30')
ORDER BY film_id;

-- Method join
SELECT b.film_id, title
FROM rental AS a
INNER JOIN inventory AS b
ON a.inventory_id = b.inventory_id
INNER JOIN film AS c
ON b.film_id = c.film_id
WHERE return_date BETWEEN '2005-05-29' AND '2005-05-30'


-- 21) First & last name of customers who have at least one payment whose amount is greater than 11
SELECT first_name, last_name
FROM customer AS c
WHERE EXISTS (SELECT * FROM payment AS p 
			  WHERE p.customer_id = c.customer_id
			  AND amount > 11);
			  
-- exclusion with NOT EXISTS operator			  
SELECT first_name, last_name
FROM customer AS c
WHERE NOT EXISTS (SELECT * FROM payment AS p 
			  WHERE p.customer_id = c.customer_id
			  AND amount > 11);
			  
			  
-- 22) Assign : Premium(TOP100) Plus(101-200) Normal(the rest) status to customer list
SELECT customer_id,
	   CASE 
	   		WHEN (customer_id <= 100) THEN 'Premium'
			WHEN (customer_id BETWEEN 100 AND 200) THEN 'Plus'
	   		ELSE 'Normal'
	   END AS customer_class
FROM customer;


-- 23) Raffle : customer_id 2 is a winner, customer_id 5 second place
SELECT customer_id,
	   CASE customer_id 
	   		WHEN 2 THEN 'Winner'
	   		WHEN 5 THEN 'Second Place'
			ELSE 'Normal'
	   END AS raffle_results
FROM customer;


-- 24) Category : for rental_rates, how many we have?
SELECT rental_rate,
	   CASE rental_rate
	   		WHEN 0.99 THEN 1
			ELSE 0
	   END
FROM film;


-- 25) 0.99 rental rate films?
SELECT SUM(CASE rental_rate
	   		WHEN 0.99 THEN 1
			ELSE 0
	   END) AS number_of_bargains
FROM film;


-- 26) Categorization by rental_rate
SELECT SUM(CASE rental_rate
	   		WHEN 0.99 THEN 1
			ELSE 0
	   END) AS bargains,
	   SUM(CASE rental_rate
	   		WHEN 2.99 THEN 1
			ELSE 0
	   END) AS regular,
	   SUM(CASE rental_rate
	   		WHEN 4.99 THEN 1
			ELSE 0
	   END) AS premium
FROM film;


-- 27) Views
CREATE VIEW customer_info AS 
SELECT first_name, last_name, address
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id

-- Call the view
SELECT *
FROM customer_info

-- Alter the view
CREATE OR REPLACE VIEW customer_info AS
SELECT first_name, last_name, address, district
FROM customer
INNER JOIN address
ON customer.address_id = address.address_id

-- Remove the view
DROP VIEW IF EXISTS customer_info

-- Change the name of the view
ALTER VIEW customer_info RENAME TO c_info

SELECT *
FROM c_info