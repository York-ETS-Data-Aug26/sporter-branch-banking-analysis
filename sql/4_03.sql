SET search_path TO banks_analysis;

/*
 * This query is looking at the portion of market deposits in the metropoliatian area (distribution). With the cbsa table I joined the
 * the office table since we're looking at office deposits rather than institutions. The institution_count is there so that
 * we can see how many institutions are operting in that metropoliatian area.
 */
SELECT
	c.cbsa_code ,
	c.cbsa_name ,
	count (o.uninumber ) AS office_count,
	sum(o.depsumbr ) AS total_deposits,
	count(DISTINCT o.cert ) AS institution_count
FROM office o
JOIN cbsa c
	ON c.cbsa_code = o.cbsa_code
WHERE o.cbsa_code IS NOT NULL
GROUP BY
	c.cbsa_code,
	c.cbsa_name
ORDER BY total_deposits desc;

/*
 * HHI calculations: This query is using 100 million
 * Appendix B with 100 million threshold to see which markets come out the most concentrated?
 */
--1000000000 -- billion
--100000000 -- 100 million
--1000000 -- 1 million

WITH market_institute_deposit AS (
	SELECT
		o.cbsa_code ,
		o.cert,
		sum(o.depsumbr ) AS institution_deposits
	FROM office o
	WHERE o.cbsa_code IS NOT NULL
	GROUP BY
		o.cbsa_code,
		o.cert
),
totals AS (
	SELECT
		cbsa_code ,
		sum(institution_deposits ) AS market_deposits
	FROM market_institute_deposit
	GROUP BY
		cbsa_code
),
institution_shares AS (
	SELECT
		mid.cbsa_code ,
		mid.cert ,
		mid.institution_deposits ,
		t.market_deposits ,
		mid.institution_deposits / nullif(t.market_deposits ,0) AS market_share
	FROM market_institute_deposit mid
	JOIN totals t
		ON t.cbsa_code = mid.cbsa_code
)
SELECT
	c.cbsa_code,
	c.cbsa_name ,
	count(*) AS institution_count,
	max(ish.market_deposits ) AS market_deposits,
	10000 * SUM(power(ish.market_share, 2 )) AS hhi,
	CASE
		WHEN 10000 * SUM(power(ish.market_share, 2 )) < 1500 THEN 'Unconcentrated'
		WHEN 10000 * SUM(power(ish.market_share, 2 )) <= 2500 THEN 'Moderately concentrated'
		ELSE 'Highly concentrated'
	END AS concentration_cateogry
FROM institution_shares ish
JOIN cbsa c
ON c.cbsa_code = ish.cbsa_code
GROUP BY
	c.cbsa_code,
	c.cbsa_name
HAVING max(ish.market_deposits ) >= 1000000  -- million
ORDER BY 10000 * SUM(power(ish.market_share, 2 )) DESC;

/*
TAKING THE TOP 10
*/


WITH market_inst_deposits AS (
	SELECT
		o.cbsa_code,
		o.cert,
		sum(o.depsumbr) AS int_deposits
	FROM office o
	WHERE o.cbsa_code IS NOT NULL
	GROUP BY
		o.cbsa_code, o.cert),
market_totals AS (
	SELECT
		cbsa_code ,
		sum(int_deposits ) AS market_deposits
	FROM market_inst_deposits
	GROUP BY cbsa_code ),
ranked AS (
	SELECT
		mid.cbsa_code ,
		mid.cert ,
		mid.int_deposits ,
		mt.market_deposits ,
		mid.int_deposits  / nullif(mt.market_deposits ,0) AS market_share
	FROM market_inst_deposits mid
	JOIN market_totals mt
		ON mt.cbsa_code = mid.cbsa_code )
SELECT
	c.cbsa_name,
	c.cbsa_code,
	r.cert,
	i.namefull,
	r.int_deposits ,
	r.market_share
FROM ranked r
JOIN cbsa c
ON c.cbsa_code = r.cbsa_code
JOIN institution i
	ON i.cert = r.cert
WHERE r.cbsa_code IN (
	SELECT r.cbsa_code
	FROM (
	SELECT
		c.cbsa_code,
		10000 * SUM(power(r.market_share, 2 )) AS hhi
	FROM ranked r
	GROUP BY cbsa_code
	HAVING max(r.market_deposits ) >= 1000000
	ORDER BY 10000 * SUM(power(r.market_share, 2 )) DESC
	LIMIT 10) AS top_markets)
ORDER BY
	c.cbsa_name,
	r.market_share DESC
LIMIT 100;