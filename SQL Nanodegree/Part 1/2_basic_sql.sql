### Limits
/*
Try it yourself below by writing a query that limits the response to only the
  first 15 rows and includes the date, account_id, and channel fields in the
  web_events table.
*/
SELECT occurred_at, account_id, channel
FROM web_events
LIMIT 15;

### Order By
/*
Order by clause comes after FROM
*/
SELECT *
FROM orders
ORDER BY occurred_at
LIMIT 1000;

### practice using ORDER BY
/*
Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and total_amt_usd.
*/
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10;

/*
Write a query to return the top 5 orders in terms of the largest total_amt_usd. Include the id, account_id, and total_amt_usd
*/
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

/*
Write a query to return the lowest 20 orders in terms of the smallest total_amt_usd. Include the id, account_id, and total_amt_usd
*/
SELECT id, account_id, total_amt_usd
FROM orders
WHERE total_amt_usd > 0
ORDER BY total_amt_usd
LIMIT 20;

### Order By pt 2
/*
Write a query that displays the order ID, account ID, and total dollar amount for all the orders, sorted first by the account ID (in ascending order), and then by the total dollar amount (in descending order).
*/
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;

/*
write a query that again displays order ID, account ID, and total dollar amount for each order, but this time sorted first by total dollar amount (in descending order), and then by account ID (in ascending order).
*/
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;

### where clause

/*
write a query that Pulls the first 5 rows and all columns from the orders table that have a dollar amount of gloss_amt_usd greater than or equal to 1000.
*/
SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000;

/*
Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd less than 500.
*/
SELECT *
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;

### Questions using Arithmetic Operations
/*
Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order. Limit the results to the first 10 orders, and include the id and account_id fields.
*/
SELECT standard_amt_usd / standard_qty AS unit_price, id, account_id
FROM orders
LIMIT 10

/*
Write a query that finds the percentage of revenue that comes from poster paper for each order. You will need to use only the columns that end with _usd. (Try to do this without using the total column.) Display the id and account_id fields also
*/
SELECT id, account_id, poster_amt_usd / (standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS poster_pct
FROM orders
LIMIT 10

### LIKE operator
/*
All the companies whose names start with 'C'.
*/
SELECT *
FROM accounts
WHERE name LIKE 'C%'

/*
All companies whose names contain the string 'one' somewhere in the name.
*/
SELECT *
FROM accounts
WHERE name LIKE '%one%'

/*
All companies whose names end with 's'.
*/
SELECT *
FROM accounts
WHERE name LIKE '%s'

### Using IN operator
/*
Use the accounts table to find the account name, primary_poc, and sales_rep_id for Walmart, Target, and Nordstrom.
*/
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart','Target','Nordstrom');

/*
Use the web_events table to find all information regarding individuals who were contacted via the channel of organic or adwords.
*/
SELECT *
FROM web_events
WHERE channel IN ('organic','adwords');

### Using NOT operator
/*
Use the accounts table to find the account name, primary poc, and sales rep id for all stores except Walmart, Target, and Nordstrom.
*/
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom');

/*
Use the web_events table to find all information regarding individuals who were contacted via any method except using organic or adwords methods.
*/
SELECT *
FROM web_events
WHERE channel NOT IN ('organic', 'adwords');

/*
Use the accounts table to find:
All the companies whose names do not start with
*/
SELECT *
FROM accounts
WHERE name NOT LIKE 'C%'
ORDER BY name;

/*
All companies whose names do not contain the string 'one' somewhere in the name.
*/
SELECT *
FROM accounts
WHERE name NOT LIKE '%one%'
ORDER BY name;

/*
All companies whose names do not end with 's'.
*/
SELECT *
FROM accounts
WHERE name NOT LIKE '%s'
ORDER BY name;

### Questions using OR operator
/*
Find all the company names that start with a 'C' or 'W', and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.
*/
SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND primary_poc NOT LIKE '%eana%');
