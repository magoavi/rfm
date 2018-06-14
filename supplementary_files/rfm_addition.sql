-- Creating summary_train
DROP VIEW IF EXISTS summary_train_2b CASCADE;

CREATE VIEW summary_train_2b AS
SELECT
  summary.cust_id,
  scf_code,
  linedollars
FROM lines
INNER JOIN summary
ON lines.cust_id = summary.cust_id
WHERE orderdate BETWEEN '2005/01/01' AND '2006/01/01';


-- Create Zip code
DROP VIEW IF EXISTS zip_code_2b CASCADE;

CREATE VIEW zip_code_2b AS
SELECT
  NTILE(5) OVER (ORDER BY total_purchases_by_zip) AS Z,
  *
FROM
(
SELECT
  summary_train_2b.cust_id,
  scf_code,
  AVG(linedollars) OVER (PARTITION BY scf_code) AS total_purchases_by_zip
FROM summary_train_2b
) AS t2;





-- Creating rfm_pre
DROP VIEW IF EXISTS rfmz CASCADE;

CREATE VIEW rfmz AS
SELECT
  rfm_pre.cust_id,
  CONCAT(r,f,m,z) AS rfmz
FROM rfm_pre
INNER JOIN zip_code_2b
ON rfm_pre.cust_id = zip_code_2b.cust_id
GROUP BY rfm_pre.cust_id, r, f, m, z
ORDER BY r DESC,f DESC,m DESC,z DESC;



-- Creating Response
DROP VIEW IF EXISTS response_2b CASCADE;

CREATE VIEW response_2b AS
SELECT
t.cust_id,
rfmz,
contactdate,
response_period,
orderdate,
CASE WHEN t.orderdate - t.contactdate BETWEEN 0 AND 10 THEN 1
     ELSE 0
END AS response
FROM
(
    SELECT
    t.cust_id,
    rfmz,
    contactdate,
    response_period,
    orders.orderdate
FROM
(
      SELECT
      t.cust_id,
      rfmz,
      contactdate AS contactdate,
      contactdate+10 AS response_period
      FROM
(
        SELECT *
        FROM contacts
        WHERE contactdate BETWEEN '2005/01/01' AND '2006/01/01'
        ORDER BY cust_id
) AS t
      LEFT JOIN rfmz
      ON t.cust_id = rfmz.cust_id
      WHERE contacttype = 'C'
) AS t
    INNER JOIN orders
    ON t.cust_id = orders.cust_id
    WHERE orders.orderdate BETWEEN '2005/01/01' AND '2006/01/01'
) AS t
WHERE orderdate-contactdate>=0;


-- COPY
-- (
-- SELECT *
-- FROM response
-- LIMIT 100
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/response_100_check.csv'
-- With CSV DELIMITER ',';



-- Creating response_rate
DROP VIEW IF EXISTS responses_grouped_2b CASCADE;

CREATE VIEW responses_grouped_2b AS
SELECT
  rfmz,
  --COUNT(response) AS mailed,
  SUM(response) AS responses
FROM response_2b
GROUP BY rfmz
ORDER BY AVG(response) DESC;


-- Creating contacts
DROP VIEW IF EXISTS contacts_grouped_2b CASCADE;

CREATE VIEW contacts_grouped_2b AS
SELECT
  rfmz,
  COUNT(contactdate) as tot_contacts
FROM contacts
INNER JOIN rfmz
ON contacts.cust_id = rfmz.cust_id
WHERE contactdate BETWEEN '2005/01/01' AND '2005/12/20' AND contacttype = 'C'
GROUP BY rfmz
ORDER BY rfmz DESC;




-- Creating response rate
DROP VIEW IF EXISTS response_rate_2b CASCADE;

CREATE VIEW response_rate_2b AS
SELECT
  *,
  ROUND(CAST((responses/tot_contacts) AS NUMERIC),4) AS response_rate
FROM
(
SELECT
  responses_grouped_2b.rfmz,
  --mailed,
  CAST(responses*1.00 AS FLOAT) AS responses,
  CAST(tot_contacts*1.00 AS FLOAT) AS tot_contacts
FROM responses_grouped_2b
INNER JOIN contacts_grouped_2b
ON responses_grouped_2b.rfmz = contacts_grouped_2b.rfmz
) AS t
ORDER BY response_rate DESC;



-- Creating total_people_group
DROP VIEW IF EXISTS total_people_group_2b CASCADE;

CREATE VIEW total_people_group_2b AS
SELECT COUNT(*), rfmz
FROM rfmz
GROUP BY rfmz;




-- Creating optimizing VIEW
DROP VIEW IF EXISTS optimizing_2b CASCADE;

CREATE VIEW optimizing_2b AS
SELECT
  *,
  SUM(expected_responses) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_responses,
  SUM(expected_profits) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_profits
FROM
(
SELECT
  response_rate_2b.rfmz,
  response_rate,
  contacts_grouped_2b.tot_contacts AS total_cost,
  (response_rate*contacts_grouped_2b.tot_contacts) AS expected_responses,
  (response_rate*contacts_grouped_2b.tot_contacts*30) AS expected_revenue,
  ((response_rate*contacts_grouped_2b.tot_contacts*30) - contacts_grouped_2b.tot_contacts) AS expected_profits
FROM response_rate_2b
INNER JOIN contacts_grouped_2b
ON response_rate_2b.rfmz = contacts_grouped_2b.rfmz
ORDER BY response_rate DESC
) AS t;


--Exporting the rfm view
-- COPY
-- (
-- SELECT * FROM optimizing
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/optimizing.csv'
-- With CSV HEADER DELIMITER ',';




--SELECT MAX(cumulative_profits) FROM optimizing;

--SELECT * FROM optimizing
--WHERE cumulative_profits = 48254.2830;

--SELECT * FROM optimizing;

--
-- COPY
-- (
-- SELECT
--   SUM(proportion) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_proportion,
--   cumulative_profits,
--   t.rfmz
-- FROM
-- (
-- SELECT
--   count/SUM(count) OVER () AS proportion,
--   cumulative_profits,
--   total_people_group_2b.rfmz
-- FROM total_people_group_2b
-- INNER JOIN optimizing_2b
-- ON total_people_group_2b.rfmz = optimizing_2b.rfmz
-- ORDER BY response_rate DESC
-- ) AS t
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/gain_chart_2b.csv'
-- With CSV HEADER DELIMITER ',';



--566
--348



--217

DROP VIEW IF EXISTS contacted_2b CASCADE;

CREATE VIEW contacted_2b AS
SELECT
  rfmz,
  CASE WHEN res_quantile > 217 THEN 1
       ELSE 0
  END AS contacted,
  res_quantile
FROM
(
SELECT
  *,
  NTILE(566) OVER (ORDER BY response_rate_2b.response_rate) AS res_quantile
FROM response_rate_2b
ORDER BY res_quantile DESC
) AS t;





DROP VIEW IF EXISTS test_responses_2b CASCADE;

CREATE VIEW test_responses_2b AS
SELECT
  t.rfmz,
  contacted,
  contactdate,
  response_period,
  orderdate,
  response
FROM
(
SELECT
  t.cust_id,
  rfmz,
  contactdate,
  response_period,
  orderdate,
  CASE WHEN orderdate - contactdate BETWEEN 0 AND 10 THEN 1
       ELSE 0
  END AS response
FROM
(
SELECT
  rfmz.cust_id,
  rfmz,
  contactdate,
  (contactdate + 10) AS response_period
FROM
(
SELECT *
FROM contacts
WHERE cust_id IN (SELECT cust_id FROM rfmz) AND contactdate > '2006/01/01' AND contacttype = 'C'
ORDER BY cust_id
) AS t
INNER JOIN rfmz
ON t.cust_id = rfmz.cust_id
) AS t
INNER JOIN orders
ON t.cust_id = orders.cust_id
WHERE orders.cust_id IN (SELECT cust_id FROM rfmz)
) AS t
INNER JOIN contacted_2b
ON t.rfmz = contacted_2b.rfmz
WHERE contacted = 1;




DROP VIEW IF EXISTS test_total_response_by_rfm_group_2b CASCADE;

CREATE VIEW test_total_response_by_rfm_group_2b AS
SELECT
  rfmz,
  SUM(response) AS tot_response
FROM test_responses_2b
GROUP BY rfmz;




DROP VIEW IF EXISTS test_contacts_2b;

CREATE VIEW test_contacts_2b AS
SELECT
  rfmz.rfmz,
  contacted,
  contactdate
FROM contacts
INNER JOIN rfmz
ON contacts.cust_id = rfmz.cust_id
INNER JOIN contacted_2b
ON rfmz.rfmz = contacted_2b.rfmz
WHERE contactdate > '2006/01/01' AND contacttype = 'C' AND contacted = 1;









-- Calculating total contacts
DROP VIEW IF EXISTS test_total_contacts_by_rfm_group_2b CASCADE;

CREATE VIEW test_total_contacts_by_rfm_group_2b AS
SELECT
  rfmz,
  SUM(contacted) AS tot_contacts
FROM test_contacts_2b
GROUP BY rfmz;

--SELECT * FROM test_total_contacts_by_rfm_group;

-- Creating test_contacts_and_responses
DROP VIEW IF EXISTS test_contacts_and_responses_2b CASCADE;

CREATE VIEW test_contacts_and_responses_2b AS
SELECT
  t1.rfmz,
  tot_contacts,
  tot_response
FROM test_total_contacts_by_rfm_group_2b AS t1
INNER JOIN test_total_response_by_rfm_group_2b AS t2
ON t1.rfmz = t2.rfmz;




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
--   *
-- FROM test_contacts_and_responses_2b
-- INNER JOIN contacted_2b
-- ON test_contacts_and_responses_2b.rfmz = contacted_2b.rfmz
-- ORDER BY res_quantile DESC
-- ) AS t
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/lift_2b_avg.csv'
-- With CSV HEADER DELIMITER ',';





--ROI Actual
COPY
(
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
FROM test_contacts_and_responses_2b
) AS t
) AS t
)
TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/roi_rfmz.csv'
With CSV HEADER DELIMITER ',';


-- 197 for sum, 21.73 roi
-- 209 for avg, 23.04

-- 566 total
