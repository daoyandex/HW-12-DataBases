CREATE EXTENSION postgres_fdw;

/* SHARD 1 */
/* регистрируем сервер с шардом*/
CREATE SERVER books_1_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_books1', port '5432', dbname 'books');
/* настраиваем маппинг*/
CREATE USER MAPPING FOR "postgres"
SERVER books_1_server
OPTIONS (user 'postgres', password 'postgres');
/* создаём таблицу*/
CREATE FOREIGN TABLE books_1 (
    id bigint not null,
    category_id int not null,
    author character varying not null,
    title character varying not null,
    year int not null
) SERVER books_1_server
OPTIONS (schema_name 'public', table_name 'books');

/* SHARD 2 */
/* регистрируем сервер с шардом*/
CREATE SERVER books_2_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_books2', port '5432', dbname 'books');
/* настраиваем маппинг*/
CREATE USER MAPPING FOR "postgres"
SERVER books_2_server
OPTIONS (user 'postgres', password 'postgres');
/* создаём таблицу*/
CREATE FOREIGN TABLE books_2 (
    id bigint not null,
    category_id int not null,
    author character varying not null,
    title character varying not null,
    year int not null
) SERVER books_2_server
OPTIONS (schema_name 'public', table_name 'books');

/* SHARD 3 */
/* регистрируем сервер с шардом*/
CREATE SERVER books_3_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_books3', port '5432', dbname 'books');
/* настраиваем маппинг*/
CREATE USER MAPPING FOR "postgres"
SERVER books_3_server
OPTIONS (user 'postgres', password 'postgres');
/* создаём таблицу*/
CREATE FOREIGN TABLE books_3 (
    id bigint not null,
    category_id int not null,
    author character varying not null,
    title character varying not null,
    year int not null
) SERVER books_3_server
OPTIONS (schema_name 'public', table_name 'books');

/* добавляем представления */
CREATE VIEW books AS
SELECT *
FROM books_1
UNION ALL
SELECT *
FROM books_2
UNION ALL
SELECT *
FROM books_3;


/* добавляем критерии заполнения */
CREATE RULE books_insert AS ON INSERT TO books
DO INSTEAD NOTHING;
CREATE RULE books_update AS ON UPDATE TO books
DO INSTEAD NOTHING;
CREATE RULE books_delete AS ON DELETE TO books
DO INSTEAD NOTHING;

CREATE RULE books_insert_to_1 AS ON INSERT TO books
WHERE (category_id <= 2)
DO INSTEAD INSERT INTO books_1
VALUES (NEW.*);

CREATE RULE books_insert_to_2 AS ON INSERT TO books
WHERE (category_id > 2 and category_id <= 4)
DO INSTEAD INSERT INTO books_2
VALUES (NEW.*);

CREATE RULE books_insert_to_3 AS ON INSERT TO books
WHERE (category_id > 5)
DO INSTEAD INSERT INTO books_3
VALUES (NEW.*);