/*
 * RECONCILIATION
 */

-- this is the initial query to find matching, rounding, and disagreement between
-- institute and office deposits
-- from the first few rows, I am seeing duplicate namefull values for Bank of China, but they
-- have different cert values as well.

SET search_path TO banks_analysis;

-- this is investigating deeper into those that have a great disagreement

WITH reconciliation AS (
	SELECT
	i.cert,
	i.namefull,
	i.depdom AS institution_deposits,
	COALESCE(sum(o.depsumbr), 0) AS office_deposits,
	i.depdom - coalesce(sum(o.depsumbr), 0) AS difference,
	CASE
		WHEN i.depdom = coalesce(sum(o.depsumbr), 0) THEN 'exactly matching'
		WHEN abs(i.depdom - coalesce(sum(o.depsumbr), 0)) < 1000 THEN 'rounding difference'
		ELSE 'genuine disagreement'
	END AS reconciliation_status,
	i.country_code,
	count(o.uninumber) AS office_count,
	i.regagnt
FROM institution i
LEFT JOIN office o
	ON o.cert = i.cert
GROUP BY
	i.cert,
	i.namefull,
	i.depdom
) SELECT
	cert,
	namefull,
	institution_deposits,
	office_deposits,
	institution_deposits - office_deposits AS difference,
	abs(institution_deposits - office_deposits ) AS absolute_difference,
	reconciliation_status,
	country_code,
	office_count,
	regagnt
	FROM reconciliation
	WHERE institution_deposits <> office_deposits AND reconciliation_status = 'genuine disagreement'
	ORDER BY absolute_difference DESC;
	LIMIT 10;





-- So this query is checking what is going on with Bank of China
-- Initially, I thought I had a duplicate value but that was before
-- I performed this query. Under different certifications, the Bank of China didn't actually have a difference
-- as the missing institution deposits of 33,652 were made up in the institution deposits of 33,653

WITH check_china AS (
	SELECT
	i.cert,
	i.namefull,
	i.depdom AS institution_deposits,
	COALESCE(sum(o.depsumbr), 0) AS office_deposits,
	i.depdom - coalesce(sum(o.depsumbr), 0) AS difference,
	CASE
		WHEN i.depdom = coalesce(sum(o.depsumbr), 0) THEN 'exactly matching'
		WHEN abs(i.depdom - coalesce(sum(o.depsumbr), 0)) < 1 THEN 'rounding difference'
		ELSE 'genuine disagreement'
	END AS reconciliation_status
FROM institution i
LEFT JOIN office o
	ON o.cert = i.cert
GROUP BY
	i.cert,
	i.namefull,
	i.depdom
) SELECT cert, namefull, institution_deposits, office_deposits, difference
	FROM check_china
	WHERE cert = 33652 OR cert = 33653;

-- investigating office deposits. This could mean that the offices didn't deposit any money so it could be 0.

SELECT
	count(*) AS offices,
	count(o.depsumbr) AS offices_with_deposit,
	count(*) - count(o.depsumbr) AS missing_deposits
FROM office o
WHERE o.depsumbr = 0;

-- investigating institutions
SELECT count(*) AS institute,
count(i.depdom ) AS i_with_deposit,
count(*) - count(i.depdom ) AS missing_deposits
FROM institution i ;

SELECT
i.depdom, i.namefull
FROM institution i
WHERE i.depdom  = 0;

SELECT i.namefull, o.depsumbr
FROM institution i
LEFT JOIN office o
	ON o.cert = i.cert
WHERE o.depsumbr = 0;

SELECT count(*) AS row_count, o.depsumbr,i.depdom , i.namefull
FROM institution i
LEFT JOIN office o
	ON o.cert = i.cert
WHERE o.depsumbr = 0
GROUP BY i.namefull ,o.depsumbr, i.depdom
HAVING count(*) > 1;


-- Noticing the pattern of having more than one certification at a time
WITH check_instituions AS (
	SELECT
	i.cert,
	i.namefull,
	i.depdom AS institution_deposits,
	COALESCE(sum(o.depsumbr), 0) AS office_deposits,
	i.depdom - coalesce(sum(o.depsumbr), 0) AS difference,
	CASE
		WHEN i.depdom = coalesce(sum(o.depsumbr), 0) THEN 'exactly matching'
		WHEN abs(i.depdom - coalesce(sum(o.depsumbr), 0)) < 1 THEN 'rounding difference'
		ELSE 'genuine disagreement'
	END AS reconciliation_status
FROM institution i
LEFT JOIN office o
	ON o.cert = i.cert
GROUP BY
	i.cert,
	i.namefull,
	i.depdom
) SELECT cert, namefull, institution_deposits, office_deposits, difference, reconciliation_status
	FROM check_instituions
	WHERE reconciliation_status = 'genuine disagreement'
	ORDER BY namefull ;

SELECT
	i.cert,
	i.namefull,
	i.depdom
FROM institution i
LEFT JOIN office o
	ON o.cert = i.cert
GROUP BY
	i.cert,
	i.namefull ,
	i.depdom
HAVING count(o.cert) = 0