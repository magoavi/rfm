-- Creating contacted
DROP VIEW IF EXISTS contacted CASCADE;

CREATE VIEW contacted AS
SELECT
  rfm,
  CASE WHEN res_quantile > 51 THEN 1
       ELSE 0
  END AS contacted,
  res_quantile
FROM
(
SELECT
  *,
  NTILE(125) OVER (ORDER BY response_rate.response_rate) AS res_quantile
FROM response_rate
ORDER BY res_quantile DESC
) AS t;

--51
--SELECT * FROM contacted


-- Creating test_response
DROP VIEW IF EXISTS test_responses CASCADE;

CREATE VIEW test_responses AS
SELECT
  t.rfm,
  contacted,
  contactdate,
  response_period,
  orderdate,
  response
FROM
(
SELECT
  t.cust_id,
  rfm,
  contactdate,
  response_period,
  orderdate,
  CASE WHEN orderdate - contactdate BETWEEN 0 AND 10 THEN 1
       ELSE 0
  END AS response
FROM
(
SELECT
  rfm.cust_id,
  rfm,
  contactdate,
  (contactdate + 10) AS response_period
FROM
(
SELECT *
FROM contacts
WHERE cust_id IN (SELECT cust_id FROM rfm) AND contactdate > '2006/01/01' AND contacttype = 'C'
ORDER BY cust_id
) AS t
INNER JOIN rfm
ON t.cust_id = rfm.cust_id
) AS t
INNER JOIN orders
ON t.cust_id = orders.cust_id
WHERE orders.cust_id IN (SELECT cust_id FROM rfm)
) AS t
INNER JOIN contacted
ON t.rfm = contacted.rfm
WHERE contacted = 1;



-- Calculating total responses by group
DROP VIEW IF EXISTS test_total_response_by_rfm_group CASCADE;

CREATE VIEW test_total_response_by_rfm_group AS
SELECT
  rfm,
  SUM(response) AS tot_response
FROM test_responses
GROUP BY rfm;


--SELECT * FROM test_total_response_by_rfm_group;


-- Creating test_contacts
DROP VIEW IF EXISTS test_contacts;

CREATE VIEW test_contacts AS
SELECT
  rfm.rfm,
  contacted,
  contactdate
FROM contacts
INNER JOIN rfm
ON contacts.cust_id = rfm.cust_id
INNER JOIN contacted
ON rfm.rfm = contacted.rfm
WHERE contactdate > '2006/01/01' AND contacttype = 'C' AND contacted = 1;


-- Calculating total contacts
DROP VIEW IF EXISTS test_total_contacts_by_rfm_group CASCADE;

CREATE VIEW test_total_contacts_by_rfm_group AS
SELECT
  rfm,
  SUM(contacted) AS tot_contacts
FROM test_contacts
GROUP BY rfm;

--SELECT * FROM test_total_contacts_by_rfm_group;

-- Creating test_contacts_and_responses
DROP VIEW IF EXISTS test_contacts_and_responses CASCADE;

CREATE VIEW test_contacts_and_responses AS
SELECT
  t1.rfm,
  tot_contacts,
  tot_response
FROM test_total_contacts_by_rfm_group AS t1
INNER JOIN test_total_response_by_rfm_group AS t2
ON t1.rfm = t2.rfm;



--Creating Lift Chart
-- COPY
-- (
-- SELECT
--   SUM(proportion) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_proportion,
--   SUM(tot_response) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_responses,
--   response_rate,
--   tot_contacts
-- FROM
-- (
-- SELECT
--   (tot_response*1.0/tot_contacts*1.0) AS response_rate,
--   tot_contacts/SUM(tot_contacts) OVER () AS proportion,
--
--   *
-- FROM test_contacts_and_responses
-- INNER JOIN contacted
-- ON test_contacts_and_responses.rfm = contacted.rfm
-- ORDER BY res_quantile DESC
-- ) AS t
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/lift.csv'
-- With CSV HEADER DELIMITER ',';



-- ROI Actual
-- COPY
-- (
SELECT
  *,
  ROUND(CAST((total_profit/total_contacts)*100 AS NUMERIC),2) AS roi
FROM
(
SELECT
  *,
  (total_responses*30) AS total_reveue,
  ((total_responses*30) - total_contacts) AS total_profit
FROM
(
SELECT
  SUM(tot_contacts) AS total_contacts,
  SUM(tot_response) AS total_responses
FROM test_contacts_and_responses
) AS t
) AS t;
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/roi.csv'
-- With CSV HEADER DELIMITER ',';
