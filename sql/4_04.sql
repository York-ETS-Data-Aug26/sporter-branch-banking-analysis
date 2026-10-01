SET search_path TO bank_analysis;

SELECT *
FROM geocode_result gr;

SELECT DISTINCT status FROM geocode_result gr ; -- T, M, and NULL
SELECT DISTINCT count(geocode_ce) FROM geocode_result gr; -- 94,723 duplicates

SELECT gr.uninumbr, gr.score, gr.status, gr.geocodesou    FROM geocode_result gr
WHERE score = 0; -- where the score is 0, the status is NULL, DATAFLUX WAS FAILING THAT DAY I SUPPOSE

SELECT namebr, addressbr FROM office WHERE uninumber = 35228;

SELECT
	gr.uninumbr,
	gr.score,
	gr.status,
	gr.geocodesou,
	o.namebr,
	o.addressbr,
	o.country_code
FROM geocode_result gr
LEFT JOIN
office o
ON gr.uninumbr = o.uninumber
WHERE score = 0;

SELECT gr.uninumbr , gr.latitude , gr.longitude , gr.score
FROM geocode_result gr;

SELECT DISTINCT length(gr.latitude::text ) AS lat_length, length(gr.longitude::text ) AS log_length
FROM geocode_result gr;

SELECT DISTINCT
	CASE
		WHEN gr.latitude::text LIKE '%-%' THEN (length(abs(gr.latitude)::text) - 1)
		ELSE length(gr.latitude::text)
	END AS lat_length,
	CASE
		WHEN gr.longitude::text LIKE '%-%' THEN (length(abs(gr.longitude)::text) - 1)
		ELSE length(gr.longitude::text)
	END AS longitude_length
FROM geocode_result gr ;

SELECT min(gr.latitude ) AS min_lat, max(gr.latitude ) AS max_lat, min(gr.longitude ) AS min_long, max(gr.longitude ) AS max_long
FROM geocode_result gr

-- Coordinates are between the normal degrees.
--  Vary in precision as some have 3 numbers behind the decimal, while some have 7.


/*
 * How many offices were matched at a precisin far coarser than a street address
 */

SELECT DISTINCT gr.loc_name
FROM geocode_result gr ; -- Street_Address, StreetAddress

SELECT count(*) AS num_of_offices
FROM (
	SELECT
	 gr.uninumbr  , o.namebr, gr.loc_name , gr.status
	FROM geocode_result gr
	LEFT JOIN office o
		ON gr.uninumbr = o.uninumber
	WHERE gr.loc_name NOT IN ('Street_Address', 'StreetAddress', 'US_Streets') AND gr.status = 'M'
) AS selected;

-- There were 58,162

/*
 * How many offices are sharing the same space (Have the same coordinates)
 */

WITH duplicates AS (
	SELECT
		gr.latitude,
		gr.longitude,
		count(*) AS office_count
	FROM geocode_result gr
	WHERE gr.latitude IS NOT NULL AND gr.longitude IS NOT NULL
	GROUP BY gr.latitude, gr.longitude
	HAVING count(*) > 1
)
SELECT
	count(*) AS duplicate_pairs,
	sum(office_count ) AS offices_sharing_coordinate,
	max(office_count) AS most_in_same_coordinate,
	min(office_count) AS least_in_same_coordinate
	FROM duplicates ;

-- duplicate pairs 1,4768
-- offices_sharing 3,423
-- most_in_same 19
-- least in same 2

/*
Personal: Are their addresses similiar?
*/

SELECT
	gr.latitude ,
	gr.longitude,
	count(*) AS office_count,
	count(DISTINCT o.addressbr ) AS dis_address,
	count(DISTINCT o.cert) AS dis_institute,
	count(DISTINCT o.namebr ) AS dis_branch_name
FROM geocode_result gr
LEFT JOIN office o
ON gr.uninumbr = o.uninumber
WHERE gr.latitude IS NOT NULL AND gr.longitude IS NOT NULL
GROUP BY
	gr.latitude, gr.longitude
HAVING count(*) > 1
ORDER BY office_count DESC;

WHERE gr.latitude = 18.231812 AND gr.longitude = -66.031481

SELECT * FROM(
SELECT
	gr.latitude,
	gr.longitude,
	o.namebr ,
	o.cert ,
	o.addressbr,
	gr.status ,
	gr.geocodesou,
	gr.loc_name ,
	o.country_code
FROM office
o
INNER JOIN geocode_result gr
ON o.uninumber = gr.uninumbr
) AS suspcious
ORDER BY latitude , longitude ;

/*
 * How many carry no match at all
*/

SELECT count(*) AS matches, gr.status
FROM geocode_result gr
GROUP BY gr.status ;