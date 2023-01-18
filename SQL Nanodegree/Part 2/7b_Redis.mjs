### Redis Exercises

/*
Explore all the data in the Redis instance. Then answer the following:
*/

// 1. How is the system currently storing the primary keys used for users and
// books?
KEYS *

TYPE books:2

// 2. What is the name of the user with ID 3?
HGET users:3 name

// 3. What would be the ID of the next book?
HGETALL ids

// 4. Notice that books have authors in common. Fix that by creating a new
// entity called authors. Add the authors to the system, and then modify the
// books to refer to authors by their ID instead of their name.
HINCRBY id authors 1
HMSET authors:1 name "George Orwell"
HSET books:1 author_id 1
HDEL books:1 author

// 5. Devise a strategy that would allow user to search for books in a partial
// match, case-insensitive way.
SADD book_search:a 2
SADD book_search:an 2
SADD book_search:ani 2
SADD book_search:anim 2
SADD book_search:anima 2
SADD book_search:animal 2
SADD book_search:"animal " 2
SADD book_search:"animal f" 2
SADD book_search:"animal fa" 2
SADD book_search:"animal far" 2
SADD book_search:"animal farm" 2
