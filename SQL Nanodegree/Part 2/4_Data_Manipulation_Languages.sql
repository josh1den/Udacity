/*
Exercise Instructions

In this exercise, you'll be asked to migrate a table of denormalized data into
two normalized tables. The table called denormalized_people contains a list of
people, but there is one problem with it: the emails column can contain multiple
emails, violating one of the rules of first normal form. What more, the primary
key of the denormalized_people table is the combination of the first_name and
last_name columns. Good thing they're unique for that data set!

In a first step, you'll have to migrate the list of people without their emails
into the normalized people table, which contains an id SERIAL column in addition
to first_name and last_name.

Once that is done, you'll have to craft an appropriate query to migrate the
email addresses of each person to the normalized people_emails table. Note that
this table has columns person_id and email, so you'll have to find a way to get
the person_id corresponding to the first_name + last_name combination of the
denormalized_people table.
*/

/*
Step 1: Migrate the list of people without their emails into the normalized
people table.
*/

INSERT INTO "people" ("first_name", "last_name")
SELECT "first_name", "last_name" FROM "denormalized_people";

/*
Step 2: craft an appropriate query to migrate the email addresses of each
person to the normalized people_emails table.
*/

SELECT
  "first_name",
  "last_name",
  REGEXP_SPLIT_TO_TABLE("emails", ',')
FROM "denormalized_people";

-- INSERT INTO "people_emails"
SELECT
  "p"."id",
  REGEXP_SPLIT_TO_TABLE("dn"."emails", ',')
FROM "denormalized_people" AS "dn"
JOIN "people" AS "p"
ON (
  "dn"."first_name" = "p"."first_name"
  AND "dn"."last_name" = "p"."last_name"
);

### Updating DATA

/*
For this exercise, you're being asked to fix a people table that contains some
data annoyances due to the way the data was imported:

    All values of the last_name column are currently in upper-case.
    We'd like to change them from e.g. "SMITH" to "Smith".
    Using an UPDATE query and the right string function(s), make that happen.

    Instead of dates of birth, the table has a column born_ago, a TEXT field
    of the form e.g. '34 years 5 months 3 days'. We'd like to convert this to
    an actual date of birth. In a first step, use the appropriate DDL command
    to add a date_of_birth column of the appropriate data type.
    Then, using an UPDATE query, set the date_of_birth column to the correct
    value based on the value of the born_ago column.

    Finally, using another DDL command, remove the born_ago column
    from the table.
*/

/*
Step 1: Change last-name column to Title CASE
*/

UPDATE people SET last_name =
  SUBSTR(last_name, 1, 1) ||
  LOWER(SUBSTR(lastn_name, 2));

/*
Step 2: Add a date_of_birth column based on born_ago column
*/

ALTER TABLE "people" ADD COLUMN "date_of_birth" DATE;

UPDATE "people" SET "date_of_birth" =
  (CURRENT_TIMESTAMP - born_ago::INTERVAL)::DATE;

/*
Step 3: Remove the born_ago column
*/

ALTER TABLE "people" DROP COLUMN "born_ago";


### Database Manipulation

/*
you'll be given a table called user_data, and asked to make some changes to it.
In order to make sure that your changes happen coherently, you're asked to turn
off auto-commit, and create your own transaction around all the queries you will
 run.

Here are the changes you will need to make:

Due to some obscure privacy regulations, all users from California and
New York must be removed from the data set.
For the remaining users, we want to split up the name column into two new
columns: first_name and last_name.
Finally, we want to simplify the data by changing the state column to a
state_id column.
First create a states table with an automatically generated id and state
abbreviation.
Then, migrate all the states from the dataset to that table, taking care
to not have duplicates.
Once all the states are migrated and have their unique ID, add a state_id
column to the user_data table.
Use the appropriate query to make the state_id of the user_data column
match the appropriate ID from the new states table.
Remove the now redundant state column from the user_data table.

*/

\set AUTOCOMMIT off
BEGIN;

/*
Step 1: Remove users from CA and NY
*/

DELETE FROM "user_data" WHERE "state" IN ('NY', 'CA');

/*
Step 2: Split up name column into two new columns: first_name and last_name
*/

ALTER TABLE "user_data"
  ADD COLUMN "first_name" VARCHAR,
  ADD COLUMN "last_name" VARCHAR;

UPDATE "user_data" SET
  "first_name" = SPLIT_PART("name", ' ', 1),
  "last_name" = SPLIT_PART("name", ' ', 2);

ALTER TABLE "user_data" DROP COLUMN "name";

/*
Create a states table with an automatically generated id and state abbreviation
*/

CREATE TABLE "states" (
  "id" SMALLSERIAL,
  "state" CHAR(2)
);

INSERT INTO "states" ("state")
  SELECT DISTINCT "state" FROM "user_data";

ALTER TABLE "user_data"
  ADD COLUMN "state_id" SMALLINT;

UPDATE "user_data" SET
  "state_id" = (
    SELECT "s"."id"
    FROM "states" AS "s"
    WHERE "s"."state" = "user_data"."state"
  );

ALTER TABLE "user_data"
  DROP COLUMN "state";

COMMIT;
