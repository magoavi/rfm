-- Creating train
DROP VIEW IF EXISTS train CASCADE;

CREATE VIEW train AS
SELECT *
FROM lines
WHERE orderdate BETWEEN '2005/01/01' AND '2006/01/01';




-- Creating Frequency
DROP VIEW IF EXISTS frequency CASCADE;

CREATE VIEW frequency AS
SELECT
  NTILE(5) OVER (ORDER BY tot_purchases) AS F,
  *
FROM
(
SELECT
  cust_id,
  COUNT(DISTINCT ordernum) AS tot_purchases
FROM train
GROUP BY cust_id
) as t;




-- Creating Monetary
DROP VIEW IF EXISTS monetary CASCADE;

CREATE VIEW monetary AS
SELECT
  NTILE(5) OVER (ORDER BY tot_expenditure) AS M,
  *
FROM
(
SELECT
  cust_id,
  AVG(linedollars) AS tot_expenditure
FROM train
GROUP BY cust_id
) AS t1;




-- Creating Recency
DROP VIEW IF EXISTS recency CASCADE;

CREATE VIEW recency AS
SELECT
  NTILE(5) OVER (ORDER BY recent_purchase) AS R,
  *
FROM
(
SELECT
  cust_id,
  MAX(orderdate) AS recent_purchase
FROM train
GROUP BY cust_id
) AS t2;




-- Creating rfm_pre
DROP VIEW IF EXISTS rfm_pre CASCADE;

CREATE VIEW rfm_pre AS
SELECT
  recency.cust_id,
  recency.r,
  frequency.f,
  monetary.m,
  CONCAT(r,f,m) AS rfm
FROM recency
INNER JOIN frequency
ON recency.cust_id = frequency.cust_id
INNER JOIN monetary
ON recency.cust_id = monetary.cust_id
GROUP BY recency.cust_id, r, f, m
ORDER BY r DESC,f DESC,m DESC;




-- Creating rfm
DROP VIEW IF EXISTS rfm CASCADE;

CREATE VIEW rfm AS
SELECT
  cust_id,
  rfm
FROM rfm_pre;




-- Exporting the rfm view
-- COPY
-- (
-- SELECT * FROM rfm
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/rfm.csv'
-- With CSV HEADER DELIMITER ',';
