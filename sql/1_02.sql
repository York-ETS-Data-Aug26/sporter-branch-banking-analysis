SET search_name TO banks_analysis;

EXPLAIN ANALYZE
SELECT *
FROM office
WHERE is_main_office = TRUE AND cert = 3510;
	-- Seq Scan| Planning Time: 0.358 ms| Execution Time 47.451 ms

CREATE UNIQUE INDEX one_main_per_institution
ON office(cert)
WHERE is_main_office = TRUE;

EXPLAIN ANALYZE
SELECT *
FROM office
WHERE is_main_office = TRUE AND cert = 3510;
	-- Index Scan | Planning Time; 0.329 ms | Execution Time 0.081 ms

-- This where I thought it was going to go. Since the cert is unique in the table, I assumed it was going
-- to be faster with a Index Scan

EXPLAIN ANALYZE
SELECT i.namefull, i.asset
FROM institution i
WHERE i.asset >= 1000000000;
	-- Seq Scan | Planning Time 0.073 ms | 0.8918 ms
	-- Figuring it wont be faster with index

CREATE INDEX examining_assets
ON institution(asset)

EXPLAIN ANALYZE
SELECT i.namefull, i.asset
FROM institution i
WHERE i.asset >= 1000000000;

	-- Bitmap Index Scan | Planning Time: 0.303 ms | Execution Time: 0.130 ms

-- This isn't where I thought it was going to go. I thought it was going to be a seq scan
-- but this makes sense since its still going through thousands of rows.
WHERE asset >= 1000000000;