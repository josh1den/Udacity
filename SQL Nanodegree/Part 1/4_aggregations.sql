### Aggregation questions

/*
Find the total amount of poster_qty paper ordered in the orders table.
*/

SELECT SUM(poster_qty)
FROM orders;

/*
Find the total amount of standard_qty paper ordered in the orders table.
*/

SELECT SUM(standard_qty)
FROM orders;

/*
Find the total dollar amount of sales using the total_amt_usd
in the orders table.
*/

SELECT SUM(total_amt_usd)
FROM orders;

/*
Find the total amount spent on standard_amt_usd and
gloss_amt_usd paper for each order in the orders table.
This should give a dollar amount for each order in the table.
*/

SELECT id, SUM(standard_amt_usd) AS standard_sum, SUM(gloss_amt_usd) AS gloss_sum
FROM orders
GROUP BY id;

/*
Find the standard_amt_usd per unit of standard_qty paper. Your solution should
use both aggregation and a mathematical operator.
*/

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

### MIN, MAX, and AVERAGE

/*
When was the earliest order ever placed?
You only need to return the date.
*/

SELECT MIN(occurred_at)
FROM orders;

/*
Try performing the same query as in question 1 without using
an aggregation function.
*/

SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

/*
When did the most recent (latest) web_event occur?
*/

SELECT MAX(occurred_at)
FROM web_events;

/*
Try to perform the result of the previous query without using an
aggregation function.
*/

SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

/*
Find the mean (AVERAGE) amount spent per order on each paper type,
as well as the mean amount of each paper type purchased per order.
Your final answer should have 6 values - one for each paper type
for the average number of sales, as well as the average amount.
*/

SELECT AVG(standard_qty) AS standard_qty_avg,
AVG(standard_amt_usd) AS standard_amt_avg,
AVG(gloss_qty) AS gloss_qty_avg, AVG(gloss_amt_usd) AS gloss_amt_avg,
AVG(poster_qty) AS poster_qty_avg, AVG(poster_amt_usd) AS poster_amt_avg
FROM orders;

/*
Via the video, you might be interested in how to calculate the MEDIAN.
Though this is more advanced than what we have covered so far try finding -
what is the MEDIAN total_usd spent on all orders?
*/

SELECT total_amt_usd, DENSE_RANK() OVER(ORDER BY total_amt_usd) AS ranking
FROM orders;

### GROUP BY

/*
Which account (by name) placed the earliest order? Your solution should
have the account name and the date of the order.
*/
SELECT a.name AS account_name, o.occurred_at AS earliest_order
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
ORDER BY earliest_order
LIMIT 1;

/*
Find the total sales in usd for each account. You should include two columns -
the total sales for each company's orders in usd and the company name.
*/

SELECT a.name AS account_name, SUM(o.total_amt_usd) AS gross_sales_usd
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account_name;

/*
Via what channel did the most recent (latest) web_event occur, which account
was associated with this web_event? Your query should return only three values
- the date, channel, and account name.
*/

SELECT w.occurred_at AS date, w.channel, a.name AS account_name
FROM web_events AS w
JOIN accounts AS a
ON w.account_id = a.id
ORDER BY date DESC
LIMIT 1;

/*
Find the total number of times each type of channel from the web_events was
used. Your final table should have two columns - the channel and the number
of times the channel was used.
*/

SELECT channel, COUNT(channel)
FROM web_events
GROUP BY channel;

/*
Who was the primary contact associated with the earliest web_event?
*/

SELECT w.occurred_at AS date, a.primary_poc
FROM web_events AS w
JOIN accounts AS a
ON w.account_id = a.id
ORDER BY date
LIMIT 1;

/*
What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd.
Order from smallest dollar amounts to largest.
*/

SELECT a.name AS account_name, MIN(o.total_amt_usd) AS smallest_order
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
WHERE o.total_amt_usd > 0
GROUP BY account_name
ORDER BY smallest_order;

/*
Find the number of sales reps in each region. Your final table should
have two columns - the region and the number of sales_reps. Order from the
fewest reps to most reps.
*/

SELECT r.name AS region , COUNT(s.*) AS number_of_reps
FROM region AS r
JOIN sales_reps AS s
ON r.id = s.region_id
GROUP BY region
ORDER BY number_of_reps;

### GROUP BY PART TWO

/*
For each account, determine the average amount of each type of paper they
purchased across their orders. Your result should have four columns - one
for the account name and one for the average quantity purchased for each of
the paper types for each account.
*/

SELECT a.name AS account_name, ROUND(AVG(o.standard_qty),2) AS standard_avg,
ROUND(AVG(o.poster_qty),2) AS poster_avg, ROUND(AVG(o.gloss_qty),2) AS gloss_qty_avg
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account_name
ORDER BY account_name;

/*
For each account, determine the average amount spent per order on each
paper type. Your result should have four columns - one for the account
name and one for the average amount spent on each paper type.
*/

SELECT a.name AS account_name, ROUND(AVG(o.standard_amt_usd),2)
AS standard_amt_avg, ROUND(AVG(o.poster_amt_usd),2) AS poster_amt_avg,
ROUND(AVG(o.gloss_amt_usd),2) AS gloss_amt_avg
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account_name
ORDER BY account_name;

/*
Determine the number of times a particular channel was used in the
web_events table for each sales rep. Your final table should have
three columns - the name of the sales rep, the channel, and the
number of occurrences. Order your table with the highest number
of occurrences first.
*/

SELECT s.name AS sales_rep, w.channel, COUNT(w.channel) AS occurrences
FROM sales_reps AS s
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN web_events AS w
ON a.id = w.account_id
GROUP BY sales_rep, w.channel
ORDER BY occurrences DESC;

/*
Determine the number of times a particular channel was used in the
web_events table for each region. Your final table should have three
columns - the region name, the channel, and the number of occurrences.
Order your table with the highest number of occurrences first.
*/

SELECT r.name AS region, w.channel, COUNT(w.channel) AS occurrences
FROM region AS r
JOIN sales_reps AS s
ON r.id = s.region_id
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN web_events AS w
ON a.id = w.account_id
GROUP BY region, w.channel
ORDER BY occurrences DESC;

### DISTINCT

/*
Use DISTINCT to test if there are any accounts associated with more
than one region.
*/

SELECT DISTINCT a.name AS account, COUNT(r.name) AS regions
FROM accounts AS a
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS r
ON s.region_id = r.id
GROUP BY account
ORDER BY regions DESC;

/*
Have any sales reps worked on more than one account?
*/

SELECT DISTINCT s.name AS sales_reps, COUNT(a.name) AS accounts
FROM sales_reps AS s
JOIN accounts AS a
ON s.id = a.sales_rep_id
GROUP BY sales_reps
ORDER BY accounts DESC;


### HAVING clause

/*
How many of the sales reps have more than 5 accounts that they manage?
*/

SELECT s.name AS rep_name, COUNT(a.id) AS accts
FROM sales_reps AS s
JOIN accounts AS a
ON s.id = a.sales_rep_id
GROUP BY rep_name
HAVING COUNT(a.id) > 5
ORDER BY accts DESC;

/*
How many accounts have more than 20 orders?
*/

SELECT a.name AS account, COUNT(o.*) AS orders
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
HAVING COUNT(o.*) > 20
ORDER BY orders DESC;

/*
Which account has the most orders?
*/

SELECT a.name AS account, COUNT(o.*) AS orders
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
ORDER BY orders DESC
LIMIT 1;

/*
Which accounts spent more than 30,000 usd total across all orders?
*/
SELECT a.name AS account, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent DESC;

/*
Which accounts spent less than 1,000 usd total across all orders?
*/

SELECT a.name AS account, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent DESC;

/*
Which account has spent the most with us?
*/
SELECT a.name AS account, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
ORDER BY total_spent DESC
LIMIT 1;

/*
Which account has spent the least with us?
*/
SELECT a.name AS account, SUM(o.total_amt_usd) AS total_spent
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
ORDER BY total_spent
LIMIT 1;

/*
Which accounts used facebook as a channel to contact customers more
than 6 times?
*/

SELECT a.name AS account, w.channel AS channel, COUNT(w.*) AS occurrences
FROM accounts AS a
JOIN web_events AS w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY account, w.channel
HAVING COUNT(w.*) > 6
ORDER BY occurrences DESC;

/*
Which account used facebook most as a channel?
*/

SELECT a.name AS account, w.channel AS channel, COUNT(w.*) AS occurrences
FROM accounts AS a
JOIN web_events AS w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY account, channel
ORDER BY occurrences DESC
LIMIT 1;

/*
Which channel was most frequently used by most accounts?
*/

SELECT w.channel AS channel, COUNT(a.id) AS accounts
FROM web_events AS w
JOIN accounts AS a
ON w.account_id = a.id
GROUP BY channel
ORDER BY accounts DESC
LIMIT 1;

### DATE functions

/*
Find the sales in terms of total dollars for all orders in each year,
ordered from greatest to least. Do you notice any trends in the yearly
sales totals?
*/

SELECT DATE_PART('year',occurred_at) AS year, SUM(total_amt_usd) AS gross_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/*
Which month did Parch & Posey have the greatest sales in terms of total
dollars? Are all months evenly represented by the dataset?
*/

SELECT DATE_PART('month',occurred_at) AS month,
SUM(total_amt_usd) AS gross_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/*
Which year did Parch & Posey have the greatest sales in terms of the
total number of orders? Are all years evenly represented by the dataset?
*/

SELECT DATE_PART('year', occurred_at) AS year, COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/*
Which month did Parch & Posey have the greatest sales in terms of
the total number of orders? Are all months evenly represented by
the dataset?
*/

SELECT DATE_PART('month', occurred_at) AS month, COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/*
In which month of which year did Walmart spend the most on gloss
paper in terms of dollars?
*/

SELECT a.name AS account, DATE_PART('month', o.occurred_at) AS month, DATE_PART('year', occurred_at)
AS year, SUM(o.gloss_amt_usd) AS gloss_sum
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY 1, 2, 3
HAVING a.name = 'Walmart'
ORDER BY 4 DESC;

### CASE STATEMENTS

/*
Write a query to display for each order, the account ID, the total amount
of the order, and the level of the order - ‘Large’ or ’Small’ - depending
on if the order is $3000 or more, or smaller than $3000.
*/

SELECT a.id AS account_id, o.total_amt_usd AS total_amt,
CASE WHEN o.total_amt_usd >= 3000 THEN 'Large' ELSE 'Small' END AS 'Level'
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id;

/*
Write a query to display the number of orders in each of three categories,
based on the total number of items in each order. The three categories
are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
*/

SELECT COUNT(*) AS orders,
CASE WHEN standard_qty >= 2000 THEN 'At Least 2000'
     WHEN standard_qty BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
     ELSE 'Less than 1000' END AS num_of_items
FROM orders
GROUP BY 2
ORDER BY 1 DESC;

/*
We would like to understand 3 different levels of customers based on the
amount associated with their purchases. The top-level includes anyone
with a Lifetime Value (total sales of all orders) greater than 200,000 usd.
The second level is between 200,000 and 100,000 usd.
The lowest level is anyone under 100,000 usd.
Provide a table that includes the level associated with each account.
You should provide the account name, the total sales of all orders for
the customer, and the level. Order with the top spending customers
listed first
*/

SELECT a.name AS account_name, SUM(o.total_amt_usd) AS total_sales,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
     WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'mid'
     ELSE 'low' END AS level
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;

/*
We would now like to perform a similar calculation to the first,
but we want to obtain the total amount spent by customers only in
2016 and 2017. Keep the same levels as in the previous question.
Order with the top spending customers listed first.
*/

SELECT a.name AS account_name, SUM(o.total_amt_usd) AS total_sales,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
     WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000 THEN 'mid'
     ELSE 'low' END AS level
FROM accounts AS a
JOIN orders AS o
ON a.id = o.account_id
WHERE o.occurred_at BETWEEN '2016-01-01' AND '2018-01-01'
GROUP BY 1
ORDER BY 2 DESC;

/*
We would like to identify top-performing sales reps, which are sales
reps associated with more than 200 orders. Create a table with the
sales rep name, the total number of orders, and a column with top or
not depending on if they have more than 200 orders. Place the top
salespeople first in your final table.
*/

SELECT s.name AS sales_rep, COUNT(*) AS total_orders,
CASE WHEN COUNT(*) > 200 THEN 'top'
ELSE NULL END AS top
FROM sales_reps AS s
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;

/*
The previous didn't account for the middle, nor the dollar amount
associated with the sales. Management decides they want to see these
characteristics represented as well. We would like to identify
top-performing sales reps, which are sales reps associated with
more than 200 orders or more than 750000 in total sales. The middle
group has any rep with more than 150 orders or 500000 in sales.
Create a table with the sales rep name, the total number of orders,
total sales across all orders, and a column with top, middle, or
low depending on these criteria. Place the top salespeople based
on the dollar amount of sales first in your final table. You might
see a few upset salespeople by this criteria!
*/

SELECT s.name AS sales_rep, COUNT(*) AS total_orders, SUM(o.total_amt_usd) AS
total_sales,
CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'mid'
     ELSE 'low' END AS level
FROM sales_reps AS s
JOIN accounts AS a
ON s.id = a.sales_rep_id
JOIN orders AS o
ON a.id = o.account_id
GROUP BY 1
ORDER BY total_sales DESC;
