-- Creating View Cut_off_decision
DROP VIEW IF EXISTS cut_off_decision CASCADE;

CREATE VIEW cut_off_decision AS
SELECT cust_id, lead_time
FROM
(
SELECT
  t.cust_id,
  orderdate - (MAX(contactdate) OVER (PARTITION BY cust_id, )) AS lead_time
FROM
(
    SELECT
    t.cust_id,
    rfm,
    contactdate,
    response_period,
    orders.orderdate,
    ordernum
FROM
(
      SELECT
      t.cust_id,
      rfm,
      contactdate AS contactdate,
      contactdate+10 AS response_period
      FROM
(
        SELECT *
        FROM contacts
        WHERE contactdate BETWEEN '2005/01/01' AND '2006/01/01'
        ORDER BY cust_id
) AS t
      LEFT JOIN rfm
      ON t.cust_id = rfm.cust_id
      WHERE contacttype = 'C'
) AS t
    INNER JOIN orders
    ON t.cust_id = orders.cust_id
    WHERE orders.orderdate BETWEEN '2005/01/01' AND '2006/01/01'
) AS t
) AS t
WHERE lead_time>=0;

SELECT * FROM cut_off_decision ORDER BY lead_time DESC, cust_id LIMIT 1000;

-- COPY
-- (
-- SELECT lead_time
-- FROM cut_off_decision
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/cut_off_decision.csv'
-- With CSV HEADER DELIMITER ',';




-- Creating View Response
DROP VIEW IF EXISTS response CASCADE;

CREATE VIEW response AS
SELECT
  t.cust_id,
  rfm,
  contactdate,
  response_period,
  orderdate,
  CASE WHEN t.orderdate - t.contactdate BETWEEN 0 AND 10
   THEN 1
       ELSE 0
  END AS response
FROM
(
    SELECT
    t.cust_id,
    rfm,
    contactdate,
    response_period,
    orders.orderdate
FROM
(
      SELECT
      t.cust_id,
      rfm,
      contactdate AS contactdate,
      contactdate+45 AS response_period
      FROM
(
        SELECT *
        FROM contacts
        WHERE contactdate BETWEEN '2005/01/01' AND '2006/01/01'
        ORDER BY cust_id
) AS t
      LEFT JOIN rfm
      ON t.cust_id = rfm.cust_id
      WHERE contacttype = 'C'
) AS t
    INNER JOIN orders
    ON t.cust_id = orders.cust_id
    WHERE orders.orderdate BETWEEN '2005/01/01' AND '2006/01/01'
) AS t;





-- COPY
-- (
-- SELECT *
-- FROM response
-- LIMIT 100
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/response_100_check.csv'
-- With CSV DELIMITER ',';

-- Creating response_rate
DROP VIEW IF EXISTS responses_grouped CASCADE;

CREATE VIEW responses_grouped AS
SELECT
  rfm,
  --COUNT(response) AS mailed,
  SUM(response) AS responses
FROM response
GROUP BY rfm
ORDER BY AVG(response) DESC;


-- Creating contacts
DROP VIEW IF EXISTS contacts_grouped CASCADE;

CREATE VIEW contacts_grouped AS
SELECT
  rfm,
  COUNT(contactdate) as tot_contacts
FROM contacts
INNER JOIN rfm
ON contacts.cust_id = rfm.cust_id
WHERE contactdate BETWEEN '2005/01/01' AND '2005/12/20' AND contacttype = 'C'
GROUP BY rfm
ORDER BY rfm DESC;




-- Creating response rate
DROP VIEW IF EXISTS response_rate CASCADE;

CREATE VIEW response_rate AS
SELECT
  *,
  ROUND(CAST((responses/tot_contacts) AS NUMERIC),4) AS response_rate
FROM
(
SELECT
  responses_grouped.rfm,
  --mailed,
  CAST(responses*1.00 AS FLOAT) AS responses,
  CAST(tot_contacts*1.00 AS FLOAT) AS tot_contacts
FROM responses_grouped
INNER JOIN contacts_grouped
ON responses_grouped.rfm = contacts_grouped.rfm
) AS t
ORDER BY response_rate DESC;



-- Creating total_people_group
DROP VIEW IF EXISTS total_people_group CASCADE;

CREATE VIEW total_people_group AS
SELECT COUNT(*), rfm
FROM rfm
GROUP BY rfm;




-- Creating optimizing VIEW
-- DROP VIEW IF EXISTS optimizing CASCADE;
--
-- CREATE VIEW optimizing AS
-- SELECT
--   *,
--   SUM(expected_responses) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_responses,
--   SUM(expected_profits) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_profits
-- FROM
-- (
-- SELECT
--   response_rate.rfm,
--   response_rate,
--   total_people_group.count AS total_cost,
--   (response_rate*count) AS expected_responses,
--   (response_rate*count*30) AS expected_revenue,
--   ((response_rate*count*30) - count) AS expected_profits
-- FROM response_rate
-- INNER JOIN total_people_group
-- ON response_rate.rfm = total_people_group.rfm
-- ORDER BY response_rate DESC
-- ) AS t;


DROP VIEW IF EXISTS optimizing CASCADE;

CREATE VIEW optimizing AS
SELECT
  *,
  SUM(expected_responses) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_responses,
  SUM(expected_profits) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_profits
FROM
(
SELECT
  response_rate.rfm,
  response_rate,
  contacts_grouped.tot_contacts AS total_cost,
  (response_rate*contacts_grouped.tot_contacts) AS expected_responses,
  (response_rate*contacts_grouped.tot_contacts*30) AS expected_revenue,
  ((response_rate*contacts_grouped.tot_contacts*30) - contacts_grouped.tot_contacts) AS expected_profits
FROM response_rate
INNER JOIN contacts_grouped
ON response_rate.rfm = contacts_grouped.rfm
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


-- COPY
-- (
-- SELECT
--   SUM(proportion) OVER (rows BETWEEN unbounded preceding AND current row) AS cumulative_proportion,
--   cumulative_profits,
--   t.rfm
-- FROM
-- (
-- SELECT
--   count/SUM(count) OVER () AS proportion,
--   cumulative_profits,
--   total_people_group.rfm
-- FROM total_people_group
-- INNER JOIN optimizing
-- ON total_people_group.rfm = optimizing.rfm
-- ORDER BY response_rate DESC
-- ) AS t
-- )
-- TO '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/gain_chart.csv'
-- With CSV HEADER DELIMITER ',';
