SET search_path TO banks_analysis;
/*
 * Created a view of office-level deposits:
 * Didn't want to copy information as it could affect performance,
 * but is generally want information someone would want to look at from an analysis standpoint.
 * Doesn't seem expensive enough to justify a materialized view.
 */
CREATE OR REPLACE VIEW office_deposits AS
SELECT
	o.cert AS certificate,
	o.brnum AS branch_office,
	o.namebr AS branch_name,
	o.addressbr AS branch_address,
	o.citybr AS branch_city,
	o.country_code AS branch_country,
	o.depsumbr AS branch_deposits,
	o.state_fip AS branch_state,
	o.cbsa_code AS cbsa_code,
	o.zipbr AS sbranch_zip,
	o.service_type AS branch_service,
	o.is_main_office AS main_office,
	i.namefull AS i_name,
	i.namehcr AS i_topholder,
	i.asset AS i_asset,
	i.depdom AS i_deposit,
	i.bkclass AS i_charter
FROM office AS o
JOIN institution i
	ON o.cert = i.cert;


/*
 * Created a view for an Institution Summary :
 */


CREATE OR REPLACE VIEW institution_summary AS
SELECT
	i.cert AS certificate,
	i.namefull AS i_name,
	count(o.uninumber) AS office_count,
	coalesce(sum(o.depsumbr),0) AS office_deposits,
	count(DISTINCT o.state_fip) AS state_count,
	count(DISTINCT o.county_fip) AS county_count,
	count(DISTINCT o.cbsa_code) AS metropolitan_count,
	CASE
		WHEN count(o.uninumber) = 0 THEN 0
		ELSE sum(o.depsumbr) / count(o.uninumber)
	END AS deposits_per_office
FROM institution i
LEFT JOIN office o
	ON i.cert = o.cert
GROUP BY i.cert, i.namefull;

/*
Deposit market share per institution per metropolitan area - institution_market_share
*/

CREATE OR REPLACE VIEW institution_market_share AS
WITH institution_metro AS (
	SELECT
		cbsa_code,
		certificate,
		i_name,
		sum(i_deposit) AS institutions_total_deposits
	FROM office_deposits od
	WHERE cbsa_code IS NOT NULL
	GROUP BY
		cbsa_code, certificate, i_name
)SELECT
	cbsa_code,
	certificate,
	i_name,
	institutions_total_deposits,
	sum(institutions_total_deposits) OVER (
		PARTITION BY cbsa_code
		) AS metro_total_deposit,
		institutions_total_deposits
			/ nullif(sum(institutions_total_deposits) OVER (
				PARTITION BY cbsa_code), 0 ) AS market_share
FROM institution_metro;

/*
 * Data Quality Summary
 */
DROP TABLE data_quality_summary;

CREATE TABLE data_quality_summary (
	table_name text NOT NULL,
	column_name text NOT NULL,
	null_count bigint NOT NULL,
	distinct_count bigint NOT NULL,
	rule_name text,
	rule_failure_count bigint NOT NULL,
	checked_at timestamp NOT NULL DEFAULT current_timestamp
);

SELECT DISTINCT s.brsertyp
FROM staging s
ORDER BY s.brsertyp     ASC;

--INSERT INTO data_quality_summary (
--	table_name,
--	column_name,
--	null_count,
--	distinct_count,
--	rule_name,
--	rule_failure_count)
--	SELECT
--		'institution',
--		'namefull',
--		count(*) FILTER (WHERE namefull IS null),
--		count(DISTINCT namefull),