SELECT
	count(DISTINCT index)
FROM staging s ;

SELECT
count(DISTINCT fid)
FROM staging s;

SELECT count(DISTINCT addresbr)
FROM staging s;

SELECT count(DISTINCT brnum)
FROM staging s;

SELECT count(DISTINCT brsertyp)
FROM staging s;

SELECT count(DISTINCT cbsabr)
FROM staging s ;

SELECT count(DISTINCT cbsanamb)
FROM staging s;

SELECT count(*) AS row_count,
	count(DISTINCT s.repdte ) AS distinct_values,
	min(s.repdte ) AS value,
	max(s.repdte) AS value2
FROM staging s ;

-- find columns that look institutional but actually describes offices

SELECT
	s.cert ,
	count(DISTINCT s.namebr ) AS distinct_branch_name
FROM staging s
GROUP BY cert
HAVING count(DISTINCT namebr) > 1;

SELECT
	s.cert ,
	count(DISTINCT s.addresbr  ) AS distinct_address
FROM staging s
GROUP BY cert
HAVING count(DISTINCT s.addresbr ) > 1;

SELECT
	s.cert,
	count(DISTINCT s.citybr) AS dictinct_cities
FROM staging s
GROUP BY cert
HAVING count(DISTINCT s.citybr ) > 1;

SELECT column_name, data_type
FROM information_schema.COLUMNS
WHERE table_schema = 'banks_analysis'
AND table_name = 'staging'
ORDER BY ordinal_position;

/*
COLUMNS DERIVED
*/

SELECT cbsabr, s.cbsanamb  FROM staging s;
SELECT stnamebr, stalpbr FROM staging s;
SELECT s.cntynamb, s.stalpbr, s.stcntybr  FROM staging s;