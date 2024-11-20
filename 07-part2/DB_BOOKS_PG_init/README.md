

# setup the first server
docker exec -it postgres_books1 psql -U postgres -d books -f /scripts/shards.sql -a

# setup the second server
docker exec -it postgres_books2 psql -U postgres -d books -f /scripts/shards.sql -a
docker exec -it postgres_books2 psql -U postgres -d books -c "select * from books;"

# setup the third server
docker exec -it postgres_books3 psql -U postgres -d books -f /scripts/shards.sql -a
docker exec -it postgres_books3 psql -U postgres -d books -c "select * from books;"


# setup the main server
docker exec -it postgres_books psql -U postgres -d books -f /scripts/shards.sql -a
docker exec -it postgres_books psql -U postgres -d books -c "select * from books;"

docker exec -it postgres_books psql -U postgres -d books -c '\timing' -f /scripts/insert-data.sql

# check shards after inserting

