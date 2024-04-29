-- ----- General Hospital Database (credit : superdatascience.com)

-- -- WINDOW FUNCTIONS


-- 1) Average length of stay for all surgeries but compared that to the l.o.s. of individual surgeries
SELECT 
	surgery_id,
	surgical_discharge_date - surgical_admission_date AS los,
	AVG(surgical_discharge_date - surgical_admission_date) OVER()
FROM surgical_encounters;


-- 2) Calculate over under comparing to avg length of stay
WITH surgical_los AS(
	SELECT 
		surgery_id,
		surgical_discharge_date - surgical_admission_date AS los,
		AVG(surgical_discharge_date - surgical_admission_date) OVER() AS avg_los
	FROM surgical_encounters
	)
SELECT 
	*,
	ROUND(los - avg_los, 2) AS over_under
FROM surgical_los;


-- 3) Rank account balance by dignosis code(icd)
SELECT *
FROM accounts;

SELECT
	account_id,
	primary_icd,
	total_account_balance,
	RANK() OVER(PARTITION BY primary_icd 
				ORDER BY total_account_balance DESC) AS account_rank_by_icd
FROM accounts;


-- 4) Average total profit, sum total cost of all surgeries by surgeon
SELECT *
FROM surgical_encounters;

SELECT *
FROM physicians;

SELECT 
	s.surgery_id,
	p.full_name,
	s.total_profit,
	AVG(total_profit) OVER w AS avg_total_profit,
	s.total_cost,
	SUM(total_cost) OVER w AS total_surgeon_cost
FROM surgical_encounters s
LEFT OUTER JOIN physicians p
ON s.surgeon_id = p.id
WINDOW w AS (PARTITION BY s.surgeon_id);

-- 5) What percentage each surgery is compared to the total per surgeries by surgeon
SELECT 
	s.surgery_id,
	p.full_name,
	s.total_profit,
	AVG(total_profit) OVER w AS avg_total_profit,
	s.total_cost,
	SUM(total_cost) OVER w AS total_surgeon_cost,
	ROUND((s.total_cost / SUM(total_cost) OVER w) * 100, 2) AS cost_percent
FROM surgical_encounters s
LEFT OUTER JOIN physicians p
ON s.surgeon_id = p.id
WINDOW w AS (PARTITION BY s.surgeon_id);


-- 6) Rank of the surgical cost by surgeon, row number of profitability by surgeon & diagnosis
SELECT *
FROM surgical_encounters;

SELECT
	s.surgery_id,
	p.full_name,
	s.total_cost,
	RANK() OVER (PARTITION BY surgeon_id ORDER BY total_cost ASC) AS cost_rank,
	s.diagnosis_description,
	ROW_NUMBER() OVER (PARTITION BY surgeon_id, diagnosis_description 
					   ORDER BY total_profit DESC) AS profit_row_number,
	s.total_profit
FROM surgical_encounters s
LEFT OUTER JOIN physicians p
ON s.surgeon_id = p.id
ORDER BY s.surgeon_id, s.diagnosis_description;
-- We can see what their least/most costly surgeries are


-- 7) Look at the dates of the last/next visit by patient from the encounters table
SELECT *
FROM encounters;

SELECT
	patient_encounter_id,
	master_patient_id,
	patient_admission_datetime,
	patient_discharge_datetime,
	LAG(patient_discharge_datetime) OVER w AS previous_discharge_date,
	LEAD(patient_admission_datetime) OVER w AS next_admission_date
FROM encounters
WINDOW w AS (PARTITION BY master_patient_id 
			 ORDER BY patient_admission_datetime)
ORDER BY master_patient_id, patient_admission_datetime;


-- 8) Find all surgeries that occurred within 30 days of a previous surgery
WITH surgeries_lagged AS(
	SELECT
		surgery_id,
		master_patient_id,
		surgical_admission_date,
		surgical_discharge_date,
		LAG(surgical_discharge_date) OVER
			(PARTITION BY master_patient_id ORDER BY surgical_admission_date) AS previous_discharge_date
	FROM surgical_encounters
	)
SELECT 
	*,
	(surgical_admission_date - previous_discharge_date) AS days_between_surgeries
FROM surgeries_lagged
WHERE (surgical_admission_date - previous_discharge_date) <= 30;


-- 9) For each department, find the 3 physicians with the most admissions
WITH admission AS(
	SELECT 
		admitting_provider_id,
		department_id,
		COUNT(CASE WHEN patient_admitted_flag = 'Yes' THEN 1 ELSE 0 END) AS admissions
	FROM encounters
	GROUP BY department_id, admitting_provider_id
	),
	rank_admission AS(
	SELECT 
		d.department_name,
		p.full_name, 
		a.admissions,
		ROW_NUMBER() OVER(PARTITION BY a.department_id ORDER BY admissions DESC) AS top3_admissions
	FROM physicians p
	INNER JOIN admission a
	ON p.id = a.admitting_provider_id
	INNER JOIN departments d
	ON d.department_id = a.department_id
	)
SELECT *
FROM rank_admission
WHERE top3_admissions <= 3
ORDER BY department_name, top3_admissions;

-- v2
WITH provider_department AS(
	SELECT
		admitting_provider_id,
		department_id,
		COUNT(*) AS num_encounters
	FROM encounters
	GROUP BY admitting_provider_id, department_id
	),
	pd_ranked AS(
	SELECT 
		*,
		ROW_NUMBER() OVER
			(PARTITION BY department_id ORDER BY num_encounters DESC) AS encounter_rank
	FROM provider_department
	)
SELECT
	d.department_name,
	p.full_name AS physician_name,
	num_encounters,
	encounter_rank
FROM pd_ranked pd
LEFT OUTER JOIN physicians p
ON p.id = pd.admitting_provider_id
LEFT OUTER JOIN departments d
ON d.department_id = pd.department_id
WHERE encounter_rank <= 3;


-- 10) For each surgery, find any resources that accounted for more than 50% of total surgery cost
WITH resources AS(
	SELECT 
		c.surgery_id,
		r.resource_name,
		r.resource_cost,
		c.total_cost
	FROM surgical_encounters c
	INNER JOIN surgical_costs r
	ON c.surgery_id = r.surgery_id
	ORDER BY surgery_id
	)
SELECT *
FROM resources
WHERE resource_cost / total_cost > 0.5;

-- Window function
WITH expensive_resources AS(
	SELECT
		surgery_id,
		resource_name,
		resource_cost,
		SUM(resource_cost) OVER w AS sum_of_cost
	FROM surgical_costs
	WINDOW w AS (PARTITION BY surgery_id)
	)
SELECT
	*,
	(resource_cost / sum_of_cost) * 100 AS percent_cost
FROM expensive_resources
WHERE (resource_cost / sum_of_cost) * 100 > 50;

-- v3
WITH total_cost AS(
	SELECT
		surgery_id,
		resource_name,
		resource_cost,
		SUM(resource_cost) OVER
			(PARTITION BY surgery_id) AS total_surgery_cost
	FROM surgical_costs
	)
SELECT
	*,
	(resource_cost / total_surgery_cost) * 100 AS pct_total_cost
FROM total_cost
WHERE (resource_cost / total_surgery_cost) * 100 > 50;