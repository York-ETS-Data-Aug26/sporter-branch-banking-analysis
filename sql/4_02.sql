SET search_path TO banks_analysis;

/*
 * From the below query the ranking of the office_count, total_office_deposits,
 * and total_assets do not match up, but the top 3 in each cateogry are
 * 	- Wells Fargo Bank, National Association
 * 	- JpMorgan Chase Bank, National Association
 * 	- Bank of America, National Association
 */

WITH institutions_r AS (
	SELECT
		i.cert,
		i.namefull ,
		count(o.uninumber) AS office_count,
		coalesce(SUM(o.depsumbr ), 0) AS total_office_deposits,
		i.asset AS total_assets
	FROM institution i
	LEFT JOIN office o
		ON o.cert = i.cert
	GROUP BY
		i.cert,
		i.namefull,
		i.asset
)
SELECT
	cert,
	namefull,
	office_count,
	total_office_deposits,
	total_assets,
	RANK() OVER (
		ORDER BY office_count DESC) AS office_count_rank,
	rank() OVER (
		ORDER BY total_office_deposits DESC ) AS deposit_rank,
	rank() OVER (
		ORDER BY total_assets DESC ) AS asset_rank
FROM institutions_r
ORDER BY office_count_rank;

/*
 * The query below shows the gaps between the ranks, showing where institutions are lacking are slightly different
 * from their counterparts. WF, Chase, and BOA, are all still closely rank to each other
 */


WITH institutions_r AS (
	SELECT
		i.cert,
		i.namefull ,
		count(o.uninumber) AS office_count,
		coalesce(SUM(o.depsumbr ), 0) AS total_office_deposits,
		i.asset AS total_assets
	FROM institution i
	LEFT JOIN office o
		ON o.cert = i.cert
	GROUP BY
		i.cert,
		i.namefull,
		i.asset
),
ranked AS (
	SELECT
		*,
		RANK() OVER (
		ORDER BY office_count DESC) AS office_count_rank,
		rank() OVER (
		ORDER BY total_office_deposits DESC ) AS deposit_rank,
		rank() OVER (
		ORDER BY total_assets DESC ) AS asset_rank
	FROM institutions_r )
SELECT
	cert,
	namefull,
	office_count,
	total_office_deposits ,
	total_assets ,
	office_count_rank ,
	deposit_rank ,
	asset_rank ,
	abs(office_count_rank - deposit_rank ) AS office_deposit_rank_gap,
	abs(deposit_rank - asset_rank) AS deposit_asset_rank_gap
FROM ranked
WHERE office_count_rank <> deposit_rank
	OR deposit_rank <> asset_rank
ORDER BY office_count_rank ;

WITH institutions_r AS (
	SELECT
		i.cert,
		i.namefull ,
		count(o.uninumber) AS office_count,
		coalesce(SUM(o.depsumbr ), 0) AS total_office_deposits,
		i.asset AS total_assets
	FROM institution i
	LEFT JOIN office o
		ON o.cert = i.cert
	GROUP BY
		i.cert,
		i.namefull,
		i.asset
),
ranked AS (
	SELECT
		*,
		row_number() OVER (ORDER BY total_assets   DESC, cert ) AS asset_rank
	FROM institutions_r
),
system_totals AS (
	SELECT
		sum(office_count ) AS all_offices,
		sum(total_office_deposits) AS all_deposits
		FROM institutions_r
)
SELECT
	r.asset_rank ,
	r.cert ,
	r.namefull ,
	r.office_count ,
	r.total_office_deposits ,
	r.total_assets ,
	r.office_count / s.all_offices AS office_share,
	r.total_office_deposits  / s.all_deposits AS deposit_share
FROM ranked r
CROSS JOIN system_totals AS s
WHERE r.asset_rank <= 100
ORDER BY r.asset_rank;


/*
 * TOP 10 and top 100
 */
WITH institutions_r AS (
	SELECT
		i.cert,
		i.namefull ,
		count(o.uninumber) AS office_count,
		coalesce(SUM(o.depsumbr ), 0) AS total_office_deposits,
		i.asset AS total_assets
	FROM institution i
	LEFT JOIN office o
		ON o.cert = i.cert
	GROUP BY
		i.cert,
		i.namefull,
		i.asset
),
ranked AS (
	SELECT
		*,
		row_number() OVER (ORDER BY total_assets   DESC, cert ) AS asset_rank
	FROM institutions_r
),
system_totals AS (
	SELECT
		sum(office_count ) AS all_offices,
		sum(total_office_deposits) AS all_deposits
		FROM institutions_r
)
SELECT
	CASE
		WHEN r.asset_rank <= 10 THEN 'top 10'
		WHEN r.asset_rank <= 100 THEN 'top 100'
	END AS group_name,
	count(*) AS institutions,
	sum(r.office_count ) AS offices,
	sum(r.office_count ) / MAX(t.all_offices ) * 100 AS office_share,
	sum(r.total_office_deposits ) AS deposits,
	sum(r.total_office_deposits ) / MAX(t.all_deposits ) * 100 AS deposit_share
FROM ranked r
CROSS JOIN system_totals t
WHERE r.asset_rank <= 100
GROUP BY
	CASE
		WHEN r.asset_rank <= 10 THEN 'top 10'
		WHEN r.asset_rank <= 100 THEN 'top 100'
	END
ORDER BY
	CASE
		WHEN (CASE WHEN r.asset_rank <= 10 THEN 'top 10' WHEN r.asset_rank <= 100 THEN 'top 100' END) = 'top 10' THEN 1
    ELSE 2
	END;

/*
 * single office institutions:
 */

WITH institution_r AS (
	SELECT
		i.cert ,
		i.namefull ,
		count(o.uninumber ) AS office_count,
		coalesce(SUM(o.depsumbr ), 0) AS total_office_deposits
	FROM institution i
	LEFT JOIN office o
		ON o.cert = i.cert
	GROUP BY
		i.cert,
		i.namefull
),
totals AS (
	SELECT
		SUM(total_office_deposits ) AS all_deposits
	FROM institution_r
)
SELECT
	count(*) AS single_office_ins,
	sum(ir.total_office_deposits ) AS single_office_deposits,
	(sum(ir.total_office_deposits ) / NULLIF(MAX(t.all_deposits ), 0)) * 100 AS deposit_share
FROM institution_r ir
CROSS JOIN totals t
WHERE ir.office_count = 1;
