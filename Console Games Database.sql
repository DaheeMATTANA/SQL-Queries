-- ----- Console Games Database (credit : superdatascience.com)


-- 1) Order by game ranking
SELECT *
FROM console_games
ORDER BY game_rank ASC;


-- 2) How long were the platforms in service?
SELECT 
	*, 
	AGE(discontinued, first_retail_availability) AS platform_in_service
FROM console_dates
ORDER BY platform_alive;


-- 3) How old are the games in the database?
SELECT to_date(CAST(game_year AS varchar(4)), 'yyyy') AS game_age
FROM console_games
ORDER BY game_rank;


-- 4) Impute null value in North America sales percentage
SELECT *
FROM console_games
WHERE na_sales_percent IS NULL;

UPDATE console_games
SET na_sales_percent = (na_sales / global_sales) * 100
WHERE game_name = 'Brain Age: Train Your Brain in Minutes a Day' AND publisher = 'Nintendo' AND platform = 'DS';