### Creating tables

/*
Create a normalized set of tables that can support the following data
*/

CREATE TABLE "employees" (
  "id" SERIAL,
  "emp_name" TEXT,
  "manager_id" INTEGER
);

CREATE TABLE "employee_phones" (
  "emp_id" INTEGER,
  "phone_number" TEXT
);

-- view results

\d employees

\d employee_phones

### DML and Data Types

/*
The ability to store customer data: first and last name, an optional phone
number, and multiple email addresses.
The ability to store the hotel's rooms: the hotel has twenty floors with twenty
rooms on each floor. In addition to the floor and room number, we need to store
the room's livable area in square feet.
The ability to store room reservations: we need to know which guest reserved
which room, and during what period.
*/

CREATE TABLE "customers" (
  "id" SERIAL,
  "first_name" VARCHAR,
  "last_name" VARCHAR,
  "phone_number" VARCHAR
);

CREATE TABLE "customer_emails" (
  "customer_id" INTEGER,
  "email_address" VARCHAR
);

CREATE TABLE "rooms" (
  "id" SERIAL,
  "floor" SMALLINT,
  "room_no" SMALLINT,
  "area_sqft" SMALLINT
);

CREATE TABLE "reservations" (
  "id" SERIAL,
  "customer_id" INTEGER,
  "room_id" INTEGER,
  "check_in" DATE,
  "check_out" DATE
);

### Modifying Table Structure

/*
Explore the structure of the three tables in the provided SQL workspace.

postgres-# \dt
             List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+----------
 public | courses       | table | postgres
 public | registrations | table | postgres
 public | students      | table | postgres
(3 rows)

We'd like to make the following changes:

It was found out that email addresses can be longer than 50 characters.
We decided to remove the limit on email address lengths to keep things simple.

We'd like the course ratings to be more granular than just integers 0 to 10,
also allowing values such as 6.45 or 9.5

We discovered a potential issue with the registrations table that will manifest
itself as the number of new students and new courses keeps increasing. Identify
the issue and fix it.

postgres=# \d "courses"
                                Table "public.courses"
 Column |         Type          |                      Modifiers

--------+-----------------------+---------------------------------------
---------------
 id     | smallint              | not null default nextval('courses_id_s
eq'::regclass)
 code   | character varying(10) |
 rating | smallint              |

postgres=# \d "registrations"
   Table "public.registrations"
   Column   |   Type   | Modifiers
------------+----------+-----------
 student_id | smallint |
 course_id  | smallint |

postgres=# \d "students"
                                    Table "public.students"
    Column     |         Type          |                       Modifiers

---------------+-----------------------+--------------------------------
-----------------------
 id            | integer               | not null default nextval('stude
nts_id_seq'::regclass)
 first_name    | character varying     |
 last_name     | character varying     |
 email_address | character varying(50) |

 */

 /*
 Remove Limit on Email address
 */

 ALTER TABLE "students" ALTER COLUMN "email_address" SET DATA TYPE VARCHAR;

 /*
 Adjust Course ratings to allow decimals
 */

 ALTER TABLE "courses" ALTER COLUMN "rating" SET DATA TYPE REAL;

 /*
 Adjust registrations table columns from smallint to bigint
 */

 ALTER TABLE "registrations" ALTER COLUMN "student_id" SET DATA TYPE INTEGER;

 ALTER TABLE "registrations" ALTER COLUMN "course_id" SET DATA TYPE INTEGER;
