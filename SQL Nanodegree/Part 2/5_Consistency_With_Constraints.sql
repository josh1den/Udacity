### Unique & Primary Key Constraints

/*
For this exercise, you're going to have to explore the data schema in the
Postgres workspace in order to determine which pieces of data require Unique
and Primary Key constraints. Then, you'll have to execute the appropriate
ALTER TABLE statements to add these constraints to the data set.

Hint: There are 6 total constraints to be added.
*/

/*
postgres=# \dt
            List of relations
 Schema |     Name     | Type  |  Owner
--------+--------------+-------+----------
 public | authors      | table | postgres
 public | book_authors | table | postgres
 public | books        | table | postgres
(3 rows)
*/

/*
postgres=# \d authors
                                  Table "public.authors"
    Column     |       Type        |                      Modifiers

---------------+-------------------+-----------------------------------
-------------------
 id            | integer           | not null default nextval('authors_
id_seq'::regclass)
 name          | character varying |
 email_address | character varying |

postgres=# \d book_authors
       Table "public.book_authors"
      Column       |   Type   | Modifiers
-------------------+----------+-----------
 book_id           | integer  |
 author_id         | integer  |
 contribution_rank | smallint |

postgres=# \d books
                              Table "public.books"
 Column |       Type        |                     Modifiers

--------+-------------------+------------------------------------------
----------
 id     | integer           | not null default nextval('books_id_seq'::
regclass)
 title  | character varying |
 isbn   | character varying |
*/

--- Add Primary Keys
ALTER TABLE "authors" ADD PRIMARY KEY ("id");
ALTER TABLE "book_authors" ADD PRIMARY KEY ("book_id", "author_id");
ALTER TABLE "books" ADD PRIMARY KEY ("id");

-- Add Unique constraints
ALTER TABLE "authors" ADD UNIQUE ("email_address");
ALTER TABLE "books" ADD UNIQUE ("isbn");
ALTER TABLE "book_authors" ADD UNIQUE ("book_id", "contriution_rank");

### Foreign Key Constraints

/*
For this exercise, you're going to add some foreign key constraints to an
existing schema, but you'll have to respect some business rules
that were put in place:

    1. As a first step, please explore the currently provided schema and
    understand the relationships between all the tables
    2. Once that's done, please create all the foreign key constraints that
    are necessary to keep the referential integrity of the schema, with
    the following in mind:
      A.  When an employee who's a manager gets deleted from the system,
          we want to keep all the employees that were under him/her. They
          simply won't have a manager assigned to them.
      B.  We can't delete an employee as long as they have projects assigned
          to them
      C.  When a project gets deleted from the system, we won't need to keep
          track of the people who were working on it.

postgres=# \dt

                         List of relations
           Schema |       Name        | Type  |  Owner
          --------+-------------------+-------+----------
           public | employee_projects | table | postgres
           public | employees         | table | postgres
           public | projects          | table | postgres
          (3 rows)

postgres=# \d employee_projects

           Table "public.employee_projects"
             Column    |  Type   | Modifiers
          -------------+---------+-----------
           employee_id | integer | not null
           project_id  | integer | not null
          Indexes:
              "employee_projects_pkey" PRIMARY KEY, btree
              (employee_id, project_id)

postgres=# \d employees
           Table "public.employees"
          Column   |       Type        |                Modifiers
          ------------+-------------------+------------------------------------
           id         | integer           | not null default nextval(
           'employees_i
          d_seq'::regclass)
           name       | character varying |
           manager_id | integer           |
          Indexes:
              "employees_pkey" PRIMARY KEY, btree (id)

          postgres=# \d projects
                                        Table "public.projects"
           Column |       Type        |                       Modifiers

          --------+-------------------+----------------------------------------
          -------------
           id     | integer           | not null default nextval(
           'projects_id_seq
          '::regclass)
           name   | character varying |
          Indexes:
              "projects_pkey" PRIMARY KEY, btree (id)

*/

ALTER TABLE "employees"
  ADD CONSTRAINT "valid_manager"
  FOREIGN KEY("manager_id") REFERENCES "employees" ("id") ON DELETE SET NULL;

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_employee"
  FOREIGN KEY ("employee_id") REFERENCES "employees" ("id");

ALTER TABLE "employee_projects"
  ADD CONSTRAINT "valid_project"
  FOREIGN KEY ("project_id") REFERENCES "projects" ("id") ON DELETE CASCADE;

### Final Review Exercise

/*
In this exercise, you're going to manage a database schema that
contains no constraints, allowing you to practice all the concepts from this
lesson.

After exploring the schema, this is what you'll have to identify the following
for each table, and add the appropriate constraints for them.

1. Identify the primary key for each table
2. Identify the unique constraints for each table.
3. Identify the foreign key constraints necessary for each table.
4. In addition to the three types of constraints above, you'll have to
implement some custom business rules:
  • Usernames need to have a minimum of 5 characters
  • A book's name cannot be empty
  • A book's name must start with a capital letter
  • A user's book preferences have to be distinct
*/
-- Primary and unique Keys
ALTER TABLE "users"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("username"),
  ADD UNIQUE ("email");

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn");

ALTER TABLE "user_book_preferences"
  ADD PRIMARY KEY ("user_id", "book_id")

-- Foreign Keys
ALTER TABLE "user_book_preferences"
  ADD FOREIGN KEY ("user_id") REFERENCES "users",
  ADD FOREIGN KEY ("book_id") REFERENCES "books";

-- Usernames minimum 5 characters
ALTER TABLE "users" ADD CHECK (LENGTH("username") >= 5);

-- A book's name cannot be empty
ALTER TABLE "books" ADD CHECK(LENGTH(TRIM("name")) > 0);

-- A book's name must start with a capital letter
ALTER TABLE "books" ADD CHECK (
  SUBSTR("name", 1, 1) = UPPER(SUBSTR("name", 1, 1))
);

-- A user's book preferences have to be distinct
ALTER TABLE "user_book_preferences" ADD UNIQUE ("user_id", "preferences");
