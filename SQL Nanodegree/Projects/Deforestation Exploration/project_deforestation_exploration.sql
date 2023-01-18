### Steps to Complete:
/*
1. Create a View called "forestation" by joining all three tables - forest_area,
land_area, and regions in the workspace.
*/

CREATE VIEW forestation AS

(SELECT f.country_code,
 		f.country_name,
 		r.region,
 		r.income_group,
 		f.year,
 		CAST(f.forest_area_sqkm AS NUMERIC),
 		CAST(l.total_area_sq_mi AS NUMERIC),
        CAST((f.forest_area_sqkm / 2.59 / l.total_area_sq_mi)
        AS NUMERIC)*100 AS pct_forest
FROM forest_area AS f
JOIN land_area AS l
ON f.country_code = l.country_code AND f.year = l.year
JOIN regions AS r
ON l.country_code = r.country_code);

SELECT *
FROM forestation;


### 1. Global Situation

/*
a) What was the total forest area (in sq km) of the world in 1990? Please
keep in mind that you can use the country record denoted as “World" in the
region table.
*/

SELECT SUM(f.forest_area_sqkm) AS total_forest_area_sqkm
FROM forest_area AS f
JOIN regions AS r
ON f.country_code = r.country_code
WHERE r.country_name = 'World' AND f.year = 1990;

-- Answer: 41282694.9

-- Using View

SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
FROM forestation
WHERE country_name = 'World' AND year = 1990;

/*
b) What was the total forest area (in sq km) of the world in 2016? Please keep
in mind that you can use the country record in the table is denoted as “World.”
*/

SELECT SUM(f.forest_area_sqkm) AS total_forest_area_sqkm
FROM forest_area AS f
JOIN regions AS r
ON f.country_code = r.country_code
WHERE r.country_name = 'World' AND f.year = 2016;

-- Answer: 39958245.9

-- Using VIEW

SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
FROM forestation
WHERE country_name = 'World' AND year = 2016;


-- Using SELF JOIN

SELECT
	   f1.region,
     f1.year AS year1,
     f2.year AS year2,
     ROUND(SUM(f1.forest_area_sqkm),2) AS forest_1990,
	   ROUND(SUM(f2.forest_area_sqkm),2) AS forest_2016,
     ROUND(((SUM(f2.forest_area_sqkm) - SUM(f1.forest_area_sqkm)) /
     SUM(f1.forest_area_sqkm))*100,2) AS pct_change
FROM forestation AS f1
JOIN forestation AS f2
ON f1.region = f2.region
GROUP BY 1,2,3
HAVING f1.region = 'World' AND f1.year = 1990 AND f2.year = 2016;


/*
c) What was the change (in sq km) in the forest area of the world
from 1990 to 2016?
*/

with q1 AS (
  			SELECT SUM(f.forest_area_sqkm) AS total_forest_area_sqkm
			FROM forest_area AS f
			JOIN regions AS r
			ON f.country_code = r.country_code
			WHERE r.country_name = 'World' AND f.year = 1990
  			),
     q2 AS (
  			SELECT SUM(f.forest_area_sqkm) AS total_forest_area_sqkm
			FROM forest_area AS f
			JOIN regions AS r
			ON f.country_code = r.country_code
			WHERE r.country_name = 'World' AND f.year = 2016
       		)
SELECT q1.total_forest_area_sqkm - q2.total_forest_area_sqkm AS change
FROM q1, q2;

-- Answer: 1324449

-- Using VIEW

with q1 AS (
  SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
  FROM forestation
  WHERE country_name = 'World' AND year = 1990
),
q2 AS (
  SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm
  FROM forestation
  WHERE country_name = 'World' AND year = 2016
)
SELECT q1.total_forest_area_sqkm - q2.total_forest_area_sqkm AS change
FROM q1, q2;

/*
d) What was the percent change in forest area of the world
between 1990 and 2016?
*/

with q1 AS (
  		SELECT SUM(f.forest_area_sqkm) AS total_forest_area_sqkm_1990
			FROM forest_area AS f
			JOIN regions AS r
			ON f.country_code = r.country_code
			WHERE r.country_name = 'World' AND f.year = 1990
  			),
     q2 AS (
  			SELECT SUM(f.forest_area_sqkm) AS total_forest_area_sqkm_2016
			FROM forest_area AS f
			JOIN regions AS r
			ON f.country_code = r.country_code
			WHERE r.country_name = 'World' AND f.year = 2016
       		)
SELECT ((q2.total_forest_area_sqkm - q1.total_forest_area_sqkm) /
      q1.total_forest_area_sqkm) * 100 AS pct_change
FROM q1, q2;

-- Answer: -3.21

-- Using View
with q1 AS (
  SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm_1990
  FROM forestation
  WHERE country_name = 'World' AND year = 1990
),
q2 AS (
  SELECT SUM(forest_area_sqkm) AS total_forest_area_sqkm_2016
  FROM forestation
  WHERE country_name = 'World' AND year = 2016
)
SELECT ROUND(((q2.total_forest_area_sqkm_2016 - q1.total_forest_area_sqkm_1990) /
      q1.total_forest_area_sqkm_1990) * 100,2) AS pct_change
FROM q1, q2;

/*
e) If you compare the amount of forest area lost between 1990 and 2016,
to which country's total area in 2016 is it closest to?
*/
SELECT country_name,
	     total_area_sq_mi * 2.59 AS land_area_km,
       ABS((total_area_sq_mi * 2.59) - 1324449) AS diff
FROM forestation
WHERE year = 2016 AND year IS NOT NULL
ORDER BY 3
LIMIT 1;




### 2. Regional Outlook

/*
Create a Table that shows the regions and their percent forest area
(sum of forest area divided by sum of land area) in 1990 and 2016.
(Note that 1 sq mi = 2.59 sq km).
*/


/*
a) What was the percent forest of the entire world in 2016? Which region had
the HIGHEST percent forest in 2016, and which had the LOWEST,
to 2 decimal places?
*/

with s AS (
      SELECT r.region,
      CAST(SUM(f.forest_area_sqkm / 2.59) / SUM(l.total_area_sq_mi) AS NUMERIC)
      *100
      AS pct_forest
      FROM regions AS r
      JOIN forest_area AS f
      USING (country_code)
      JOIN land_area AS l
      USING (country_code)
  	  WHERE l.year = 2016 AND f.year = 2016
      GROUP BY 1
      ORDER BY 2 DESC
      )

SELECT region,
       ROUND(pct_forest,2) AS pct_forest
FROM s;

-- ANSWER: World: 31%, Highest: Latin America & Caribbean, 46%,
-- Lowest: Middle East & North Africa, 2%

-- Using View
SELECT region,
        ROUND(CAST(SUM(forest_area_sqkm / 2.59) / SUM(total_area_sq_mi)
        AS NUMERIC),2)*100 AS pct_forest
FROM forestation
WHERE year = 2016
GROUP BY 1
ORDER BY 2 DESC;

/*
b) What was the percent forest of the entire world in 1990? Which region had
the HIGHEST percent forest in 1990, and which had the LOWEST,
to 2 decimal places?
*/

with s AS (
      SELECT r.region,
      CAST(SUM(f.forest_area_sqkm / 2.59) / SUM(l.total_area_sq_mi) AS NUMERIC)
      *100
      AS pct_forest
      FROM regions AS r
      JOIN forest_area AS f
      USING (country_code)
      JOIN land_area AS l
      USING (country_code)
  	  WHERE l.year = 1990 AND f.year = 1990
      GROUP BY 1
      ORDER BY 2 DESC
      )

SELECT region,
       ROUND(pct_forest,2) AS pct_forest
FROM s;


-- Answer: World 32%, Highest: Latin America/Caribbean 51%,
-- Lowest: Middle East/North Africa 2%

-- Using View

SELECT region,
        ROUND(CAST(SUM(forest_area_sqkm / 2.59) / SUM(total_area_sq_mi)
        AS NUMERIC),2)*100 AS pct_forest
FROM forestation
WHERE year = 1990
GROUP BY 1
ORDER BY 2 DESC;


/*
c) Based on the table you created, which regions of the world DECREASED
in forest area from 1990 to 2016?
*/

with s1 AS (
        SELECT r.region,
        CAST(SUM(f.forest_area_sqkm / 2.59) / SUM(l.total_area_sq_mi)
        AS NUMERIC)*100
        AS pct_forest
        FROM regions AS r
        JOIN forest_area AS f
        USING (country_code)
        JOIN land_area AS l
        USING (country_code)
    	  WHERE l.year = 2016 AND f.year = 2016
        GROUP BY 1
        ORDER BY 2 DESC
      ),
     s2 AS (
       SELECT r.region,
       CAST(SUM(f.forest_area_sqkm / 2.59) / SUM(l.total_area_sq_mi)
       AS NUMERIC)*100
       AS pct_forest
       FROM regions AS r
       JOIN forest_area AS f
       USING (country_code)
       JOIN land_area AS l
       USING (country_code)
       WHERE l.year = 1990 AND f.year = 1990
       GROUP BY 1
       ORDER BY 2 DESC
     )
SELECT s1.region,
       ROUND(s2.pct_forest,2) AS pct_forest_1990,
       ROUND(s1.pct_forest,2) AS pct_forest_2016,
       ROUND((s1.pct_forest - s2.pct_forest),2) AS pct_change
FROM s1
JOIN s2
ON s1.region = s2.region
WHERE (s1.pct_forest - s2.pct_forest) < 0
ORDER BY 4;

-- Answer: Latin America & Caribbean 5%, Sub-Saharan Africa 2%

-- USING VIEW

with s1 AS (
        SELECT region,
        CAST(SUM(forest_area_sqkm / 2.59) / SUM(total_area_sq_mi)
        AS NUMERIC)*100
        AS pct_forest
        FROM forestation
    	  WHERE year = 2016
        GROUP BY 1
        ORDER BY 2 DESC
      ),
     s2 AS (
       SELECT region,
       CAST(SUM(forest_area_sqkm / 2.59) / SUM(total_area_sq_mi)
       AS NUMERIC)*100
       AS pct_forest
       FROM forestation
       WHERE year = 1990
       GROUP BY 1
       ORDER BY 2 DESC
     )
SELECT s1.region,
       ROUND(s2.pct_forest,2) AS pct_forest_1990,
       ROUND(s1.pct_forest,2) AS pct_forest_2016,
       ROUND((s1.pct_forest - s2.pct_forest),2) AS pct_change
FROM s1
JOIN s2
ON s1.region = s2.region
WHERE (s1.pct_forest - s2.pct_forest) < 0
ORDER BY 4;


### 3. Country-Level Detail

/*
a) Which 5 countries saw the largest amount decrease in forest area from 1990
to 2016? What was the difference in forest area for each?
*/

with s1 AS (
  SELECT country_name,
         ROUND(forest_area_sqkm,2) AS forest_1990
  FROM forestation
  WHERE year = 1990
),
s2 AS (
  SELECT country_name,
         ROUND(forest_area_sqkm,2) AS forest_2016
  FROM forestation
  WHERE year = 2016
)

SELECT s1.country_name,
       s1.forest_1990,
       s2.forest_2016,
       (s2.forest_2016 - s1.forest_1990) AS change
FROM s1
JOIN s2
USING (country_name)
WHERE (s1.forest_1990 - s2.forest_2016) IS NOT NULL AND country_name != 'World'
ORDER BY 4
LIMIT 5;

-- Answer:
-- 1. Brazil, -541510.00 sq_km
-- 2. Indonesia, -282193.98 sq_km
-- 3. Myanmar, -107234.00 sq_km
-- 4. Nigeria, -106506.00 sq_km
-- 5. Tanazania, -102320.00 sq_km




/*
b) Which 5 countries saw the largest percent decrease in forest area from 1990
to 2016? What was the percent change to 2 decimal places for each?
*/

with s1 AS (
            SELECT country_name,
            region,
            forest_area_sqkm,
            CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
            AS NUMERIC)*100 AS pct_forest_1990
            FROM forestation
        	  WHERE year = 1990
),

s2 AS (
            SELECT country_name,
            forest_area_sqkm,
            CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
            AS NUMERIC)*100 AS pct_forest_2016
            FROM forestation
            WHERE year = 2016
)

SELECT s1.country_name,
       s1.region,
       ROUND(s1.pct_forest_1990,2) AS pct_forest_1990,
       ROUND(s2.pct_forest_2016,2) AS pct_forest_2016,
       ROUND((s2.pct_forest_2016 - s1.pct_forest_1990),2) AS pct_change
FROM s1
JOIN s2
USING (country_name)
WHERE (s2.pct_forest_2016 - s1.pct_forest_1990) IS NOT NULL
ORDER BY 5
LIMIT 5;


--- Answer:
--- Honduras, -32.75%
--- North Korea, -27.38%
--- Zimbabwe, -21.75%
--- Cambodia, -20.48%
--- Timor-Leste, -19.58%



/*
c) If countries were grouped by percent forestation in quartiles, which group
had the most countries in it in 2016?
*/

with s1 AS (
  		SELECT country_name,
       forest_area_sqkm,
       ROUND(CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
       AS NUMERIC)*100,2) AS pct_forest_2016
       FROM forestation
       WHERE CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
       AS NUMERIC) IS NOT NULL AND year = 2016
       ORDER BY 3 DESC),
s2 AS (
       SELECT CASE WHEN pct_forest_2016 > 75 THEN 4
  			  WHEN pct_forest_2016 BETWEEN 50.01 AND 75
  			  THEN 3
  			  WHEN pct_forest_2016 BETWEEN 25.01 AND 50
  			  THEN 2
  			  ELSE 1 END AS quartile
       FROM s1)

SELECT quartile, COUNT(*)
FROM s2
GROUP BY 1
ORDER BY 2 DESC;


--- Answer:
-- Q1 - 85
-- Q2 - 73
-- Q3 - 38
-- Q4 - 9



/*
d) List all of the countries that were in the 4th quartile
(percent forest > 75%) in 2016, including region and percentage of forest.
*/

with s1 AS (
  	   SELECT country_name,
  	   region,
       forest_area_sqkm,
       ROUND(CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
       AS NUMERIC)*100,2) AS pct_forest_2016
       FROM forestation
       WHERE CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
       AS NUMERIC) IS NOT NULL AND year = 2016
       ORDER BY 3 DESC),
s2 AS (
       SELECT country_name,
              CASE WHEN pct_forest_2016 > 75 THEN 4
  			      WHEN pct_forest_2016 BETWEEN 50.01 AND 75 THEN 3
  			      WHEN pct_forest_2016 BETWEEN 25.01 AND 50 THEN 2
  			      ELSE 1 END AS quartile
       FROM s1)

SELECT s2.country_name, s1.region, s1.pct_forest_2016
FROM s2
JOIN s1
ON s2.country_name = s1.country_name
WHERE quartile = 4
ORDER BY 3 DESC;

-- Answer
/*
American Samoa
Gabon
Guyana
Lao PDR
Micronesia, Fed. Sts.
Palau
Seychelles
Solomon Islands
Suriname
*/




/*
e) How many countries had a percent forestation higher than the United States
in 2016?
*/

with s1 AS (
            SELECT ROUND(CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
            AS NUMERIC)*100,2) AS pct_forest_2016
            FROM forestation
            WHERE CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
            AS NUMERIC) IS NOT NULL AND year = 2016
			),
  s2 AS (
     	 SELECT ROUND(CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
                AS NUMERIC)*100,2) AS pct_forest_2016
         FROM forestation
         WHERE CAST(((forest_area_sqkm / 2.59) / total_area_sq_mi)
         AS NUMERIC) IS NOT NULL AND year = 2016
         AND country_name = 'United States')

SELECT COUNT(*)
FROM s1
WHERE pct_forest_2016 > (SELECT * FROM s2);

/*
Which countries had an increase in total forest area from 1990 to 2016?
*/

with s1 AS (
  		  SELECT country_name,
        region,
        forest_area_sqkm
		    FROM forestation
		    WHERE year = 2016 AND forest_area_sqkm IS NOT NULL
  	    AND year IS NOT NULL
		),
     s2 AS (
        SELECT country_name, forest_area_sqkm
       	FROM forestation
       	WHERE year = 1990 AND forest_area_sqkm IS NOT NULL
  	    AND year IS NOT NULL
     	)
SELECT s1.country_name,
       s1.region,
	     s2.forest_area_sqkm AS forest_1990,
       s1.forest_area_sqkm AS forest_2016,
       ROUND(s1.forest_area_sqkm - s2.forest_area_sqkm,2)
       AS change_area,
       ROUND(((s1.forest_area_sqkm - s2.forest_area_sqkm) / s2.forest_area_sqkm)
       * 100, 2) AS pct_change
FROM s1
JOIN s2
ON s1.country_name = s2.country_name
ORDER BY 5 DESC;

/*
Which countries had the largest percentage change of forest area per land area?
*/

with s1 AS (
  		SELECT country_name, ROUND(pct_forest, 2) AS pct_forest
		FROM forestation
		WHERE year = 2016 AND pct_forest IS NOT NULL
  	    AND year IS NOT NULL
		),
     s2 AS (
        SELECT country_name, ROUND(pct_forest, 2) AS pct_forest
       	FROM forestation
       	WHERE year = 1990 AND pct_forest IS NOT NULL
  	    AND year IS NOT NULL
     	)
SELECT s1.country_name,
	   s2.pct_forest AS pct_forest_1990,
       s1.pct_forest AS pct_forest_2016,
       ROUND(s1.pct_forest - s2.pct_forest,2)
       AS pct_change
FROM s1
JOIN s2
ON s1.country_name = s2.country_name
ORDER BY 4 DESC;

/*
Identify the total change in forest area by region between 1990 and 2016
*/

with s1 AS (
  			SELECT region,
  				   year,
	   			   SUM(forest_area_sqkm) AS forest_area_sqkm_2016
			FROM forestation
			GROUP BY 1,2
  			HAVING year = 2016
  			),
  s2 AS (
    		SELECT region,
    			   year,
    			   SUM(forest_area_sqkm) AS forest_area_sqkm_1990
    		FROM forestation
    		GROUP BY 1,2
    		HAVING year = 1990
    	 )
SELECT s1.region,
	   s2.forest_area_sqkm_1990,
       s1.forest_area_sqkm_2016,
       ROUND(s1.forest_area_sqkm_2016 - s2.forest_area_sqkm_1990,2) AS
       change
FROM s1
JOIN s2
USING (region)
ORDER BY 4 DESC;

/*
Which country had the largest percentage increase of forest area between forest
area between 1990 and 2016?
*/

with s1 AS (
  		  SELECT country_name,
        region,
        forest_area_sqkm
		    FROM forestation
		    WHERE year = 2016 AND forest_area_sqkm IS NOT NULL
  	    AND year IS NOT NULL
		),
     s2 AS (
        SELECT country_name, forest_area_sqkm
       	FROM forestation
       	WHERE year = 1990 AND forest_area_sqkm IS NOT NULL
  	    AND year IS NOT NULL
     	)
SELECT s1.country_name,
       s1.region,
	     s2.forest_area_sqkm AS forest_1990,
       s1.forest_area_sqkm AS forest_2016,
       ROUND(s1.forest_area_sqkm - s2.forest_area_sqkm,2)
       AS change_area,
       ROUND(((s1.forest_area_sqkm - s2.forest_area_sqkm) / s2.forest_area_sqkm)
       * 100, 2) AS pct_change
FROM s1
JOIN s2
ON s1.country_name = s2.country_name
ORDER BY 6 DESC;
