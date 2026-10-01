SET search_path TO banks_analysis;
SELECT
	o.service_type,
	count(*) AS office_counts,
	count(DISTINCT o.cert) AS i_count,
	count(DISTINCT o.cbsa_code ) FILTER (WHERE o.cbsa_code IS NOT NULL ) AS cbsa_count,
	sum(coalesce(o.depsumbr,0)) AS t_deposits,
	avg(o.depsumbr ) AS avg_dep_office,
	min(o.depsumbr ) AS min_depo,
	max(o.depsumbr ) AS max_depo
FROM office o
GROUP BY o.service_type
ORDER BY o.service_type;

-- which institute
SELECT
	o.service_type,
	o.cert ,
	i.namefull,
	count(*) AS office_count,
	avg(o.depsumbr ) AS avg_dep_office,
	sum(coalesce(o.depsumbr,0)) AS t_deposits
FROM office o
JOIN institution i
	ON i.cert = o.cert
	GROUP BY
	o.service_type ,
	o.cert ,
	i.namefull
ORDER BY o.service_type, office_count DESC, t_deposits DESC;