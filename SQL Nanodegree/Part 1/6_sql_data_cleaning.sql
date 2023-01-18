### LEFT and RIGHT quizzes
/*
In the accounts table, there is a column holding the website for each company.
The last three digits specify what type of web address they are using.
Pull these extensions and provide how many of each website type
exist in the accounts table.
*/
SELECT RIGHT(website, 3) AS extension, COUNT(*)
FROM accounts
GROUP BY 1;

/*
There is much debate about how much the name (or even the first letter of a
company name) matters. Use the accounts table to pull the first letter of
each company name to see the distribution of company names that begin with
each letter (or number).
*/
SELECT LEFT(UPPER(name, 1)) AS first_letter, COUNT(*)
FROM accounts
GROUP BY 1
ORDER BY 1;

/*
Use the accounts table and a CASE statement to create two groups: one group of
company names that start with a number and the second group of those company
names that start with a letter. What proportion of company names start with
a letter?
*/
SELECT SUM(num) AS numbers, SUM(letter) AS letters
FROM (
  SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6',
    '7','8','9') THEN 1 ELSE 0 END AS num,
    CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6',
      '7','8','9') THEN 0 ELSE 1 END AS letter
  FROM accounts
) AS sub;

/*
Consider vowels as a, e, i, o, and u. What proportion of company names start
with a vowel, and what percent start with anything else?
*/
SELECT SUM(vowel) AS vowels, SUM(other) AS other
FROM (
  SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') THEN 1
  ELSE 0 END AS vowel,
  CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') THEN 0 ELSE 1
  END AS other
  FROM accounts
) AS sub;

### CONCAT, LEFT, RIGHT, and SUBSTR

/*
Suppose the company wants to assess the performance of all the sales
representatives. Each sales representative is assigned to work in a particular
region. To make it easier to understand for the HR team, display the
concatenated sales_reps.id, ‘_’ (underscore), and region.name as EMP_ID_REGION
for each sales representative.
*/

SELECT CONCAT(s.id,'_',r.name) AS EMP_ID_REGION
FROM sales_reps AS s
JOIN region AS r
ON s.region_id = r.id;

/*
From the accounts table, display the name of the client, the coordinate as
concatenated (latitude, longitude), email id of the primary point of contact as
<first letter of the primary_poc><last letter of the primary_poc>@<extracted
name and domain from the website>
*/

SELECT name, CONCAT(lat,',',long) AS coordinate,
CONCAT(LEFT(primary_poc,1), RIGHT(primary_poc,1),'@',
SUBSTR(website,5)) AS email_id
FROM accounts;

/*
From the web_events table, display the concatenated value of account_id, '_' ,
channel, '_', count of web events of the particular channel
*/

SELECT CONCAT(w.account_id,'_',w.channel,'_',w1.channel_count)
AS concatenated_value
FROM web_events as w
JOIN (
  SELECT channel, COUNT(*) AS channel_count
  FROM web_events
  GROUP BY channel
) AS w1
ON w.channel = w1.channel;

### CAST queries

/*
Write a query to look at the top 10 rows to understand the columns and the raw
data in the dataset called sf_crime_data
*/

SELECT *
FROM sf_crime_data
LIMIT 10;

/*
Write a query to change the date into the correct SQL date format. You will
need to use at least SUBSTR and CONCAT to perform this operation
*/

SELECT CONCAT(SUBSTR(date, 7,4),'-',LEFT(date,2),'-',SUBSTR(date,4,2),' ',RIGHT(date,17)) AS datetime
FROM sf_crime_data
LIMIT 10;

/*
Once you have created a column in the correct format, convert it to a date
*/

with s AS (SELECT CONCAT(SUBSTR(date, 7,4),'-',LEFT(date,2),'-',SUBSTR(date,4,2),' ',RIGHT(date,17)) AS datetime
FROM sf_crime_data)

SELECT datetime :: date
FROM s;

-- OR

with s AS (SELECT CONCAT(SUBSTR(date, 7,4),'-',LEFT(date,2),'-',SUBSTR(date,4,2),' ',RIGHT(date,17)) AS datetime
FROM sf_crime_data)

SELECT CAST(datetime AS date)
FROM s;


-- OR

SELECT (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))
:: DATE AS date
FROM sf_crime_data
LIMIT 10;

### POS, STRPOS

/*
Use the accounts table to create first and last name columns that hold the
first and last name of the primary_poc
*/
SELECT primary_poc, LEFT(primary_poc, POSITION(' ' IN primary_poc))
AS first_name,
RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))
AS last_name
FROM accounts;

/*
Now see if you can do the same thing for every rep name in the sales_reps
table. Again provide first and last name columns
*/
SELECT name, LEFT(name, POSITION(' ' IN name)) AS first_name,
RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) AS last_name
FROM sales_reps;

### CONCAT & STRPOS

/*
Each company in the accounts table wants to create an email address for each
primary_poc. The email address should be the first name of the primary_poc .
last name primary_poc @ company name .com.
*/
SELECT name, primary_poc, LOWER(LEFT(primary_poc, POSITION(' ' IN
  primary_poc)-1) || '.' || RIGHT(primary_poc, LENGTH(primary_poc) -
  POSITION(' ' IN primary_poc)) || '@' || CONCAT(name) || '.com') AS email
FROM accounts
LIMIT 10;

/*
You may have noticed that in the previous solution some of the company names
include spaces, which will certainly not work in an email address.
See if you can create an email address that will work by removing all of
the spaces in the account name, but otherwise, your solution should be just
as in question 1. Some helpful documentation is here.
*/
SELECT name, primary_poc,
LOWER(LEFT(primary_poc, POSITION(' ' IN primary_poc)-1) || '.' ||
RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))
|| '@' || REPLACE(name,' ','') || '.com') AS email
FROM accounts
LIMIT 10;

/*
We would also like to create an initial password, which they will change
after their first log in. The first password will be the first letter of
the primary_poc's first name (lowercase), then the last letter of their
first name (lowercase), the first letter of their last name (lowercase),
the last letter of their last name (lowercase), the number of letters in
their first name, the number of letters in their last name, and then the
name of the company they are working with, all capitalized with no spaces.
*/

with s AS (
  SELECT name, primary_poc, LEFT(primary_poc, POSITION(' ' IN primary_poc)-1)
  AS first_name, RIGHT(primary_poc, LENGTH(primary_poc) -
  POSITION(' ' IN primary_poc)) AS last_name
FROM accounts                                                                                                )
SELECT *, (LOWER(LEFT(first_name, 1)) || LOWER(RIGHT(first_name, 1)) ||
LOWER(LEFT(last_name, 1)) || LOWER(RIGHT(last_name,1)) || LENGTH(first_name) ||
LENGTH(last_name) || UPPER(REPLACE(name, ' ', ''))) AS password
FROM s
LIMIT 5;

/*
Use COALESCE to fill in the accounts.id column with account_id for the NULL
value in the table
*/

SELECT *, COALESCE(a.id, o.account_id) AS id
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
Use COALESCE to fill in the orders.account_id column with the account_id for
the NULL value
*/

SELECT *, COALESCE(o.account_id, a.id) AS account_id
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*
Use COALESCE to fill in each of the qty and usd columns with 0 for the table
*/

SELECT *, COALESCE(paper_qty, 0), COALESCE(standard_qty, 0)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
