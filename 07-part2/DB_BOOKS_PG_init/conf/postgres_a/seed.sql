INSERT INTO books (id, category_id, author, title, year)
SELECT generate_series(1, 101) as id,
        round(random()*9 + 1) ::int AS category_id,
        md5(random()::text) as author,
        md5(random()::text) as title,
        floor(random() * 100 + 1950) ::int AS year;
