### Indexing

/*
For this exercise, you're being asked to modify the table structure provided in
order to answer some business requirements. The tables books, authoers, and
book_authors have had their columns setup, but no constraints nor indexes have
been added.

Given the business requirements below, add the necessary constraints and
indexes to support each use-case:

1. We need to be able to quickly find books and authors by their indexes
2. We need to be able to quickly tell which books an author has written
3. We need to be able to quickly find a book by its ISBN #
4. We need to be able to quickly search for books by their titles in a
case-insensitive way, even if the title is partial. For example, searching
for "the" should return "The Lord Of the Rings"
5. For a given book, we need to be able to quickly find all the topics
associated with it.
6. For a given topic, we need to be able to quickly find all the books tagged
with it.

postgres=# \dt
            List of relations
 Schema |    Name     | Type  |  Owner
--------+-------------+-------+----------
 public | authors     | table | postgres
 public | book_topics | table | postgres
 public | books       | table | postgres
 public | topics      | table | postgres

 postgres=# \d authors
                              Table "public.authors"
 Column |       Type        |                      Modifiers
--------+-------------------+------------------------------------------------------
id     | integer           | not null default nextval('authors_id_seq'::regclass)
name   | character varying |

 postgres=# \d book_topics
   Table "public.book_topics"
  Column  |  Type   | Modifiers
----------+---------+-----------
 book_id  | integer |
 topic_id | integer |

 postgres=# \d books
                                 Table "public.books"
   Column   |       Type        |                     Modifiers
-----------+-------------------+----------------------------------------------------
id        | integer           | not null default nextval('books_id_seq'::regclass)
title     | character varying |
isbn      | character varying |
author_id | integer           |

  postgres=# \d topics
                                Table "public.topics"
   Column |       Type        |                      Modifiers
--------+-------------------+-----------------------------------------------------
id     | integer           | not null default nextval('topics_id_seq'::regclass)
name   | character varying |

*/

-- constraints
ALTER TABLE "authors"
  ADD PRIMARY KEY ("id");

ALTER TABLE "topics"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("name"),
  ALTER COLUMN "name" SET NOT NULL;

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn"),
  ADD FOREIGN KEY ("author_id") REFERENCES "authors" ("id");

ALTER TABLE "book_topics"
  ADD PRIMARY KEY ("book_id", "topic_id");

-- tell which books an author has written
CREATE INDEX "find_books_by_author" ON "books" ("author_id");

-- search by books by their title or partial title in case-insensitive way
CREATE INDEX "find_books_by_partial_title" ON "books" (
  LOWER("title") VARCHAR_PATTERN_OPS
)

-- find all books associated with given topic
CREATE INDEX "find_books_by_topic" ON "book_topics" ("topic_id");

### Creating a Complete Schema

/*
You're being tasked with creating a database of movies with the following
specification:

  • A movie has a title and a description, and zero or more categories
  associated with it
  • A category is just a name, but that name has to be unique
  • Users can register to the system to rate movies:
    • A user's username has to be unique in a case-insensitive way. For
    instance, if a user registers the username "Bob", then nobody can register
    with "bobo" nor "BOB"
    • A user can only rate a movie once, and the rating is an integer between
    0 and 100, inclusive
    • In addition to rating movies, users can also "like" categories.
  • The following queries need to execute quickly and efficiently. The database
  will contain ~6 million movies:
    • Finding a movie by partially searching its name
    • Finding a user by their username
    • For a given user, find all the categories they like and movies they rated
    • For a given movie, find all the users who rated it
    • For a given category, find all the users who like it

*/
-- Create MOVIES table
CREATE TABLE "movies" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(500) NOT NULL,
  "description" TEXT
);

-- CREATE users table
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(100)
);
-- CREATE index on Users
CREATE UNIQUE INDEX ON "users" (LOWER("username"));

-- CREATE categories table
CREATE TABLE "categories" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(50) UNIQUE
);

-- CREATE movie_categories table
CREATE TABLE "movie_categories" (
  "movie_id" INTEGER REFERENCES "movies",
  "category_id" INTEGER REFERENCES "categories",
  PRIMARY KEY ("movie_id", "category_id")
);

-- CREATE user_movie_ratings table
CREATE TABLE "user_movie_ratings" (
  "user_id" INTEGER REFERENCES "users",
  "movie_id" INTEGER REFERENCES "movies",
  "rating" SMALLINT CHECK ("rating" BETWEEN 0 AND 100),
  PRIMARY KEY ("user_id", "movie_id")
);

-- CREATE index on user_movie_ratings table
CREATE INDEX ON "user_movie_ratings" ("movie_id");

-- CREATE user_category_likes table
CREATE TABLE "user_category_likes" (
  "user_id" INTEGER REFERENCES "users",
  "category_id" INTEGER REFERENCES "categories",
  PRIMARY KEY ("user_id", "category_id")
);

-- CREATE index on user_category_likes
CREATE INDEX ON "user_category_likes" ("category_id");
