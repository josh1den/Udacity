### FIRST SUBQUERY
/*
Find the number of events that occur for each day for each channel
*/
SELECT DATE_TRUNC('day',occurred_at) AS day, channel, COUNT(*) as num_events
FROM web_events
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
Create a subquery that provides all of the data from your first SUBQUERY*/

SELECT *
FROM
(
  SELECT DATE_TRUNC('day',occurred_at) AS day, channel, COUNT(*) as num_events
  FROM web_events
  GROUP BY 1, 2
  ORDER BY 3 DESC
) AS sub;

/*
Find the average number of events for each channel.
*/

SELECT channel, AVG(num_events) AS avg_events
FROM
(
  SELECT DATE_TRUNC('day',occurred_at) AS day, channel, COUNT(*) as num_events
  FROM web_events
  GROUP BY 1, 2
  ORDER BY 3 DESC
) AS sub
GROUP BY 1
ORDER BY 2 DESC;

### CTE (Common Table Expressions) aka WITH statements

/*
Provide the name of the sales_rep in each region with the largest amount
of total_amt_usd sales.
*/
with t1 AS
(SELECT s.name AS sales_rep, r.name AS region,
SUM(o.total_amt_usd) AS sales
FROM sales_reps AS s
JOIN region AS r
ON s.region_id = r.id
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1, 2
ORDER BY 3 DESC),

t2 AS
(SELECT region, MAX(sales) AS sales
FROM t1
GROUP BY 1
ORDER BY 2 DESC)

SELECT t1.sales_rep, t2.region, t2.sales AS sales
FROM t1
JOIN t2
ON t1.region = t2.region AND t1.sales = t2.sales
ORDER BY sales DESC;

/*
For the region with the largest sales total_amt_usd, how many total
orders were placed?
*/

with t1 AS
(SELECT r.name AS region, SUM(o.total_amt_usd) AS total_amt_usd,
COUNT(*) AS orders
FROM region AS r
JOIN sales_reps AS s
ON r.id = s.region_id
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1),

t2 AS
(SELECT region, MAX(total_amt_usd) AS total_amt_usd
FROM t1
GROUP BY 1)

SELECT t1.region, t2.total_amt_usd, t1.orders
FROM t1
JOIN t2
ON t1.region = t2.region AND t1.total_amt_usd = t2.total_amt_usd
ORDER BY 2 DESC
LIMIT 1;

/*
How many accounts had more total purchases than the account name which
has bought the most standard_qty paper throughout their lifetime as a
customer?
*/
with t1 AS (
  SELECT a.name AS acct_name, MAX(o.standard_qty) AS total_std,
  SUM(o.total) AS total
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1),

t2 AS (
  SELECT a.name
  FROM accounts AS A
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))

SELECT COUNT(*)
FROM t2;

/*
For the customer that spent the most (in total over their lifetime
as a customer) total_amt_usd, how many web_events did they have
for each channel?
*/

with t1 AS (
  SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 1)

SELECT a.name, w.channel, COUNT(*) AS web_events
FROM accounts AS a
JOIN web_events AS w
ON a.id = w.account_id AND a.id = (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*
What is the lifetime average amount spent in terms of total_amt_usd
for the top 10 total spending accounts?
*/

with t1 AS (
  SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 10
)

SELECT AVG(total_spent)
FROM t1;

/*
What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average,
than the average of all orders.
*/
with t1 AS (
  SELECT AVG(o.total_amt_usd) AS avg_all
  FROM orders AS o
  JOIN accounts AS a
  ON o.account_id = a.id),
t2 AS (
  SELECT o.account_id, AVG(o.total_amt_usd) AS avg_amt
  FROM orders AS o
  GROUP BY 1
  HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;

### Subquery Examples
/*
Use DATE_TRUNC to pull month level information about the
first order ever placed in the orders Table
*/

SELECT account_id, DATE_TRUNC('month', occurred_at) AS month
FROM orders
ORDER BY month
LIMIT 1;

/*
Use the result of the previous query to find only the orders that took
place in the same month and year as the first order, and then pull the
average for each type of paper qty in this month
*/

SELECT DATE_TRUNC('month', occurred_at) AS month, AVG(standard_qty)
AS avg_standard, AVG(poster_qty) AS avg_poster, AVG(gloss_qty) AS avg_glossy,
SUM(total_amt_usd) AS total_amt_usd
FROM orders
GROUP BY 1
HAVING DATE_TRUNC('month', occurred_at) = (SELECT
                                          DATE_TRUNC('month', occurred_at)
                                          AS month
                                          FROM orders
                                          ORDER BY month
                                          LIMIT 1);

/*
What is the top channel used by each account to market products?
*/
SELECT t1.id, t1.name, t1.channel, t1.count AS count
FROM (
  SELECT a.id, a.name, w.channel, COUNT(*) AS count
  FROM accounts AS a
  JOIN web_events AS w
  ON a.id = w.account_id
  GROUP BY 1, 2, 3
  ORDER BY 3 DESC) AS t1
JOIN (
  SELECT t2.id, t2.name, MAX(count) AS max_count
  FROM (
    SELECT a.id, a.name, COUNT(*) AS count
    FROM accounts AS a
    JOIN web_events AS w
    ON a.id = w.account_id
    GROUP BY 1, 2
    ORDER BY 3 DESC) AS t2
   GROUP BY 1, 2) AS t3
ON t1.id = t3.id AND t1.count = t3.max_count
ORDER BY 1;

/*
Provide the name of the sales_rep in each region with the
largest amount of total_amt_usd sales.
*/
SELECT t3.name, t3.region, t2.max_sales
FROM (
  SELECT region, MAX(total_sales) AS max_sales
  FROM (
    SELECT s.name AS name, r.name AS region, SUM(o.total_amt_usd) AS total_sales
    FROM sales_reps AS s
    JOIN region AS r
    ON s.region_id = r.id
    JOIN accounts AS a
    ON s.id = a.sales_rep_id
    JOIN orders AS o
    ON a.id = o.account_id
    GROUP BY 1, 2
  ) as t1
  GROUP BY 1
) AS t2
JOIN (
  SELECT s.name AS name, r.name AS region, SUM(o.total_amt_usd) AS total_sales
  FROM sales_reps AS s
  JOIN region AS r
  ON s.region_id = r.id
  JOIN accounts AS a
  ON s.id = a.sales_rep_id
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
) AS t3
ON t2.region = t3.region AND t2.max_sales = t3.total_sales;

/*
For the region with the largest (sum) of sales total_amt_usd,
how many total (count) orders were placed?
*/
SELECT t3.region, t3.total_orders
FROM (
  SELECT region, MAX(total_sales) AS max_sales
  FROM (
    SELECT r.name AS region, SUM(o.total_amt_usd) AS total_sales
    FROM region AS r
    JOIN sales_reps AS s
    ON r.id = s.region_id
    JOIN accounts AS a
    ON s.id = a.sales_rep_id
    JOIN orders AS o
    ON a.id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC) AS t1
  GROUP BY 1) AS t2
JOIN (
  SELECT r.name AS region, COUNT(*) AS total_orders
  FROM region AS r
  JOIN sales_reps AS s
  ON r.id = s.region_id
  JOIN accounts AS a
  ON s.id = a.sales_rep_id
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
) AS t3
ON t2.region = t3.region
ORDER BY 2 DESC
LIMIT 1;

/*
How many accounts had more total purchases than the account
name which has bought the most standard_qty paper throughout
their lifetime as a customer?
*/

-- First, identify the account which has bought the most standard_qty paper:
SELECT name, MAX(total_std) AS max_std
FROM (
  SELECT a.name AS name, SUM(o.standard_qty) AS total_std
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
) AS t1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) AS t2

-- Next, identify how many total purchases by that account

SELECT t2.name, t3.total_orders
FROM (
  SELECT name, MAX(total_std) AS max_std
  FROM (
    SELECT a.name AS name, SUM(o.standard_qty) AS total_std
    FROM accounts AS a
    JOIN orders AS o
    ON a.id = o.account_id
    GROUP BY 1
  ) AS t1
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1) AS t2
JOIN (
  SELECT a.name, COUNT(*) AS total_orders
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1) AS t3
ON t2.name = t3.name;

-- Identify the number of orders for each account

SELECT a.name AS name, COUNT(*) AS total_orders
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;

-- Select the number of accounts from the above query which have total_orders >
-- the original query

SELECT COUNT(t1.name) AS num_of_accts
FROM (
  SELECT a.name AS name, COUNT(*) AS total_orders
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
) AS t1
WHERE t1.total_orders > (SELECT t3.total_orders
FROM (
  SELECT name, MAX(total_std) AS max_std
  FROM (
    SELECT a.name AS name, SUM(o.standard_qty) AS total_std
    FROM accounts AS a
    JOIN orders AS o
    ON a.id = o.account_id
    GROUP BY 1
  ) AS t1
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1) AS t2
JOIN (
  SELECT a.name, COUNT(*) AS total_orders
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1) AS t3
ON t2.name = t3.name);

/*
For the customer that spent the most (in total over their lifetime as
a customer) total_amt_usd, how many web_events did they have for each
channel?
*/

-- 1) isolate customer with most total spent
SELECT a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 2) identify customer web events by channel
SELECT a.name, w.channel, COUNT(*) AS web_events
FROM accounts AS a
JOIN web_events AS w
ON a.id = w.account_id
GROUP BY 1, 2
ORDER BY 1;

-- 3) join the two queries to produce the desired result
SELECT t1.name, t2.channel, t2.web_events
FROM (
  SELECT a.name, SUM(o.total_amt_usd) AS total_spent
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1
) AS t1
JOIN (
  SELECT a.name, w.channel, COUNT(*) AS web_events
  FROM accounts AS a
  JOIN web_events AS w
  ON a.id = w.account_id
  GROUP BY 1, 2
  ORDER BY 1
) AS t2
ON t1.name = t2.name;

/*
What is the lifetime average amount spent in terms of total_amt_usd for
the top 10 total spending accounts?
*/
-- Identify the top 10 total spending accounts
SELECT a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Select the average of these
SELECT AVG(total_spent) AS lifetime_avg_spent
FROM (
  SELECT a.name, SUM(o.total_amt_usd) AS total_spent
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 10
) AS sub;

/*
What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average,
than the average of all orders?
*/
-- Calculate average per order of all orders
SELECT AVG(total_amt_usd) AS avg_per_order
FROM orders;

-- Select companies whose avg_per_order > avg_per_order
SELECT a.name, ROUND(AVG(o.total_amt_usd),2) AS avg_per_order
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (
  SELECT AVG(total_amt_usd)
  FROM orders)
ORDER BY 2 DESC;

-- Calculate average lifetime amount spent of the above companies
SELECT AVG(t1.total_spent) AS avg_total_spent
FROM (
  SELECT a.name, SUM(o.total_amt_usd) AS total_spent
  FROM accounts AS a
  JOIN orders AS o
  ON a.id = o.account_id
  GROUP BY 1
) AS t1
JOIN (
  SELECT t2.name AS name
  FROM (
    SELECT a.name, ROUND(AVG(o.total_amt_usd),2) AS avg_per_order
    FROM accounts AS a
    JOIN orders AS o
    ON a.id = o.account_id
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (
      SELECT AVG(total_amt_usd)
      FROM orders)
    ORDER BY 2 DESC
  ) t2
) AS t3
ON t1.name = t3.name;
