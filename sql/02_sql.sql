--/*
-- * Populating the state table, using the branches states
-- * vs using just the institutions because that wouldn't
-- * bode well for future instances. Count could be off and
-- * wouldn't get accurate number in other case. Trimmed the
-- * leading and trailing whitespaces if any and left the cases
-- * the same for the states full name
-- */

INSERT INTO states (
	state_fip,
	state_code,
	state_name)
	SELECT DISTINCT
		cast(LEFT(lpad(s.stcntybr, 5, '0'), 2) AS integer),
		stalpbr,
		stnamebr
	FROM staging s;

SELECT * FROM states s
ORDER BY s.state_fip ;

SELECT count(*)
FROM states s ;

/*
 * Country table is the same principal as the
 * states table as branches would have more countries
 * than institutions possibly.
 */


INSERT INTO country (
	country_name
	)
	SELECT DISTINCT
		TRIM(s.cntrynab)
FROM staging s;

/*
 * Bank Class: Made sure that that the bkclass column
 * had all uppercase codes, with their descriptions just
 * for helpfulness*/


INSERT INTO bank_class (
	bkclass,
	description)
	SELECT DISTINCT
		UPPER(TRIM(s.bkclass)),
		CASE
			WHEN UPPER(TRIM(s.bkclass)) = 'N' THEN 'National charter, Federal Reserve member, supervised by the OCC'
			WHEN UPPER(TRIM(s.bkclass)) = 'NM' THEN 'State charter, Federal Reserve non-member, supervised by the FDIC'
			WHEN UPPER(TRIM(s.bkclass)) = 'OI' THEN 'Insured US branch of a foreign-chartered institution'
			WHEN UPPER(TRIM(s.bkclass)) = 'SB' THEN 'Federal savings bank'
			WHEN UPPER(TRIM(s.bkclass)) = 'SL' THEN 'State-chartered savings and loan association'
			WHEN UPPER(TRIM(s.bkclass)) = 'SM' THEN 'State charter, Federal Reserve member, supervised by the Federal Reserve'
			ELSE NULL
		END
FROM staging s;

/*
 * regulator_codes: Made sure that that the regagnt column
 * had all uppercase codes, with their descriptions just
 * for helpfulness*/


INSERT INTO regulator_codes (
	regagnt,
	description)
	SELECT DISTINCT
		UPPER(TRIM(s.regagnt)),
		CASE
			WHEN UPPER(TRIM(s.regagnt)) = 'FDIC' THEN 'Federal Deposit Insurance Corporation'
			WHEN UPPER(TRIM(s.regagnt)) = 'FED' THEN 'Federal Reserve System'
			WHEN UPPER(TRIM(s.regagnt)) = 'OCC' THEN 'Office of the Comptroller of the Currency'
			ELSE 'NULL'
		END
FROM staging s;



	/*
	 * branch_service_type: Converting the text type to integer before inserting
	 * into table. Also adding description to what these codes mean
	 * */


INSERT INTO branch_service_type (
	service_type,
	description
	)
SELECT DISTINCT
	s.brsertyp::integer,
	CASE
		WHEN s.brsertyp::integer = 11 THEN 'Full service, brick and mortar'
		WHEN s.brsertyp::integer = 12 THEN 'Full service, retail'
		WHEN s.brsertyp::integer = 13 THEN 'Home banking'
		WHEN s.brsertyp::integer = 21 THEN 'Limited service, administrative'
		WHEN s.brsertyp::integer = 22 THEN 'Limited service, military facility'
		WHEN s.brsertyp::integer = 23 THEN 'Limited service, drive-through'
		WHEN s.brsertyp::integer = 29 THEN 'Limited service, mobile or seasonal'
		WHEN s.brsertyp::integer = 30 THEN 'Limited service, trust'
		ELSE NULL
	END
FROM staging s;

SELECT * FROM branch_service_type bst ;

/*
 * county: Here I split the count and state fips codes and recast them as an integer leaving
 * the original code as is. I liked the display of it better than casting that as an integer as well.*/

SELECT DISTINCT CNTYNAMB, s.stcntybr FROM staging s ;


SELECT DISTINCT s.stcntybr, s.stnamebr ,LEFT(lpad(s.stcntybr, 5, '0'), 2) AS count_fip,
RIGHT(lpad(s.stcntybr, 5, '0'), 3) AS state_fip, s.CNTYNAMB
FROM staging s
ORDER BY count_fip ;

INSERT INTO county (
	stcntyfip,
	state_name,
	county_fip,
	state_fip,
	county_name)
	SELECT DISTINCT
		s.stcntybr,
		s.stnamebr,
		cast(RIGHT(lpad(s.stcntybr, 5, '0'), 3) AS integer),
		cast(LEFT(lpad(s.stcntybr, 5, '0'), 2) AS integer),
		s.cntynamb
FROM staging s;

/*
 * Institution table: */

SELECT * FROM staging s
LIMIT 50;

SELECT s.cert, count(*) AS cert_count
FROM staging s
GROUP BY cert
LIMIT 50;


SELECT s.namehcr, s."index", s.namefull
FROM staging s
LIMIT 100;

SELECT nullif(UPPER(TRIM(s.namehcr ), ''))
FROM staging s
LIMIT 200;

SELECT s.rssdid
FROM staging s
WHERE s.rssdid IS NULL OR TRIM(s.rssdid) = '';


-- THIS NEEDS TO BE RAN TOMORROW
INSERT INTO institution (
	cert,
	namefull,
	asset,
	bkclass,
	country_code,
	denovo,
	depdom,
	namehcr,
	regagnt,
	rssdid,
	state_fip,
	stncnty,
	zip,
	city)
	SELECT DISTINCT
		CAST(cert AS integer),
		TRIM(s.namefull),
		cast(s.asset AS NUMERIC(20,2)),
		UPPER(TRIM(s.bkclass)),
		(SELECT country_code FROM country c WHERE c.country_name = s.cntryna),
		CASE
			WHEN denovo = '1' THEN TRUE
			WHEN denovo = '0' THEN FALSE
		END,
		CAST(depdom AS NUMERIC (20,2)),
		nullif(UPPER(TRIM(s.namehcr ), '')),
		UPPER(TRIM(s.regagnt)),
		TRIM(s.rssdid),
		cast(LEFT(lpad(s.stcntybr, 5, '0'), 2) AS integer),
		CAST(s.stcnty AS integer),
		cast(TRIM(s.zip) AS integer),
		TRIM(s.city)
FROM staging s ;

SELECT * FROM staging s ;

/*
 * OFFICE*/

-- THIS NEEDS TO BE RAN TOMORROW

INSERT INTO office (
	uninumber,
	cert,
	brnum,
	namebr,
	addressbr,
	citybr,
	country_code,
	addressbr,
	citybr,
	country_code,
	depsumbr,
	state_fip,
	zipbr,
	service_type,
	is_main_office)
	SELECT DISTINCT
		CAST(s.uninumbr AS integer),
		CAST(s.cert AS integer),
		CAST(s.brnum AS integer),
		TRIM(s.namebr),
		nullif(TRIM(s.addresbr), ''),
		nullif(TRIM(s.citybr)),
		(SELECT country_code FROM country c WHERE c.country_name = s.cntrynab),
		cast(s.depsumbr  AS NUMERIC(20,2)),
		cast(LEFT(lpad(s.stcntybr, 5, '0'), 2) AS integer),
		cast(TRIM(s.zipbr) AS integer),
		CAST(s.brsertyp AS integer),
		CASE
			WHEN s.bkmo  = '1' THEN TRUE
			WHEN s.bkmo  = '0' THEN FALSE
		END
FROM staging s

SELECT s.citybr
FROM staging s
WHERE s.citybr  IS NULL OR TRIM(s.citybr  ) = '';