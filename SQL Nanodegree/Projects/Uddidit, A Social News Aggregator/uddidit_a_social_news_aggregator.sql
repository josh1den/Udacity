/*
Inspect the tables
*/

\dt
\d+ bad_comments
\d+ bad_posts

SELECT MAX(LENGTH(url))
FROM bad_posts;

SELECT MAX(LENGTH(url))
FROM bad_posts;

SELECT url
FROM bad_posts
WHERE LENGTH(url) = (
  SELECT MAX(LENGTH(url))
  FROM bad_posts);

### Schema Features and Specifications
/*
Guideline #1
*/

-- a) Allow new users to register
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(25) UNIQUE NOT NULL, -- (ii), (iii)
  "last_login" TIMESTAMP
);

-- b) Allow registered users to create new topics
CREATE TABLE "topics" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(30) UNIQUE NOT NULL, -- (i), (ii), (iii)
  "description" VARCHAR(500), -- (iv) optional 500 limit description
  "user_id" INTEGER,
  "created_at" TIMESTAMP,
  FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);

-- c) Allow registered users to create new posts on existing topics
CREATE TABLE "posts" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(100) NOT NULL, -- (i) 100 character limit (ii) not empty
  "url" TEXT,
  "content" TEXT,
  "user_id" INTEGER,
  "topic_id" INTEGER NOT NULL,
  "created_at" TIMESTAMP,
  FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL, -- (iv)
  FOREIGN KEY ("topic_id") REFERENCES "topics" ("id") ON DELETE CASCADE, --(iii)
  CONSTRAINT "url_or_content" CHECK(("url" IS NULL AND "content" IS NOT NULL)
  OR ("url" IS NOT NULL AND "content" IS NULL)) -- (iii) url or content
);

-- d) Allow registered users to comment on existing posts
CREATE TABLE "comments" (
  "id" SERIAL PRIMARY KEY,
  "comment" TEXT NOT NULL, -- (i)
  "user_id" INTEGER,
  "post_id" INTEGER NOT NULL,
  "parent_id" INTEGER DEFAULT NULL,
  "created_at" TIMESTAMP,
  FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL, -- (iv)
  FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE, -- (iii)
  FOREIGN KEY ("parent_id") REFERENCES "comments" ("id") ON DELETE CASCADE -- v
);

-- e) Make sure that a given user can only vote once on a given post
CREATE TABLE "votes" (
  "id" SERIAL PRIMARY KEY,
  "vote" INTEGER NOT NULL,
  "user_id" INTEGER,
  "post_id" INTEGER NOT NULL,
  FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL, -- (ii)
  FOREIGN KEY ("post_id") REFERENCES "posts" ("id") ON DELETE CASCADE, -- (iii)
  CONSTRAINT "vote_values" CHECK ("vote" = 1 OR "vote" = -1), -- (i)
  CONSTRAINT "no_duplicate_votes" UNIQUE ("user_id", "post_id")
);

/*
Guideline #2
*/

-- a) List all users who haven't logged in in the last year
CREATE INDEX "users_by_last_login" ON "users" ("username", "last_login");

-- b) List all users who haven't created any post
CREATE INDEX "user_posts" ON "posts" ("user_id");
-- Satisfied by PRIMARY KEY "users" ("id")

-- c) Find a user by their username
-- Satisfied by unique constraint on "users" ("username")

-- d) List all topics that don't have any posts
CREATE INDEX "topic_posts" ON "topics" ("id", "name");
CREATE INDEX "topic_posts" ON "posts" ("topic_id");

-- e) Find a topic by its name
-- Satisfied by unique constraint on "topics" ("name")

-- f) List the latest 20 posts for a given topic
CREATE INDEX "latest_posts_by_topic" ON "posts" ("topic_id", "created_at");

-- g) List the latest 20 posts made by a given user
CREATE INDEX "latest_posts_by_user" ON "posts" ("user_id", "created_at");

-- h) Find all posts that link to a specific URL
CREATE INDEX "posts_to_url" ON "posts" ("url");

-- i) List all the top-level comments for a given post
CREATE INDEX "top_level_comments"
ON "comments" ("comment", "post_id", "parent_id")
WHERE "parent_id" = NULL;

-- j) List all the direct children of a parent comment
CREATE INDEX "direct_children" ON "comments" ("comment", "parent_id");

-- k) List the latest 20 comments made by a given user
CREATE INDEX "latest_comments_by_user"
ON "comments" ("comment", "user_id");

-- l) Compute the score of a post, defined as the difference between the
-- number of upvotes and the number of downvotes
CREATE INDEX "post_score" ON "votes" ("vote", "post_id");

### Migrate the Data

INSERT INTO "users" ("username")
  SELECT username
  FROM bad_posts
  UNION
  SELECT username
  FROM bad_comments
  UNION
  SELECT REGEXP_SPLIT_TO_TABLE(upvotes, ',') AS username
  FROM bad_posts
  UNION
  SELECT REGEXP_SPLIT_TO_TABLE(downvotes, ',') AS username
  FROM bad_posts;

INSERT INTO "topics" ("name")
  SELECT DISTINCT topic
  FROM bad_posts;

INSERT INTO "posts" ("user_id", "topic_id", "title", "url", "content")
  SELECT u.id,
         t.id,
         LEFT(b.title, 100),
         b.url,
         b.text_content
  FROM users AS u
  JOIN bad_posts AS b
  ON u.username = b.username
  JOIN topics AS t
  ON b.topic = t.name;

INSERT INTO "comments" ("user_id", "post_id", "comment")
  SELECT u.id,
         p.id,
         b.text_content
  FROM bad_comments AS b
  JOIN users AS u
  ON b.username = u.username
  JOIN posts AS p
  ON b.post_id = p.id;

INSERT INTO "votes" ("post_id", "user_id", "vote")
  SELECT b.id,
         u.id,
         1 AS vote
  FROM (
    SELECT id,
           regexp_split_to_table(upvotes, ',') AS username
    FROM bad_posts
  ) AS b
  JOIN users AS u
  ON b.username = u.username;

  INSERT INTO "votes" ("post_id", "user_id", "vote")
    SELECT b.id,
           u.id,
           -1 AS vote
    FROM (
      SELECT id,
             regexp_split_to_table(downvotes, ',') AS username
      FROM bad_posts
    ) AS b
    JOIN users AS u
    ON b.username = u.username;
