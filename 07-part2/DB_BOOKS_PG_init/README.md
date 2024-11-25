

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


# WORK WITH DATABASE

$ psql -U postgres -W

List of databases
\l

$ createdb -U postgres -W  -p 5000 -h host -T template0 -e demo_db
> CREATE DATABASE demo TEMPLATE template0;

First, choose your database
\c database_name

Then, this shows all tables in the current schema:
\dt

Programmatically (or from the psql interface too, of course):
SELECT * FROM pg_catalog.pg_tables;


# show all schemanames tables
SELECT * FROM pg_catalog.pg_tables;


# BACKUP

1. pg_dump — извлечь базу данных PostgreSQL в файл скрипта или другой архивный файл
# Примеры
## 1. Чтобы выгрузить базу данных mydb в файл SQL-скрипта:
``` bash
$ pg_dump mydb > db.sql
```
## 2. Чтобы перезагрузить такой скрипт в (новосозданный) баз данных с именем newdb :
``` bash
$ psql -d newdb -f db.sql
```
## 3.Чтобы сохранить базу данных в архивный файл пользовательского формата:
``` bash
$ pg_dump -Fc mydb > db.dump
```
## 4. Чтобы сохранить базу данных в архив формата каталога:
``` bash
$ pg_dump -Fd mydb -f dumpdir
```
## 5. Чтобы создать дамп базы данных в архиве формата каталога параллельно с 5 рабочими заданиями:
``` bash
$ pg_dump -Fd mydb -j 5 -f dumpdir
```
## 6. Чтобы перезагрузить файл архива в (новую) базу данных с именем newdb :
``` bash
$ pg_restore -d newdb db.dump
```
## 7. Чтобы выгрузить одну таблицу с именем mytab :
``` bash
$ pg_dump -t mytab mydb > db.sql
```
## 8. Чтобы выгрузить все таблицы, имена которых начинаются с emp в схеме Detroit , за исключением таблицы с именем employee_log :
``` bash
$ pg_dump -t 'detroit.emp*' -T detroit.employee_log mydb > db.sql
```
## 9 .Чтобы вывести все схемы, имена которых начинаются с east или west и заканчиваются на gsm , за исключением схем, имена которых содержат слово test :
``` bash
$ pg_dump -n 'east*gsm' -n 'west*gsm' -N '*test*' mydb > db.sql
```

## 10. То же самое, с использованием регулярных выражений для объединения переключателей:
``` bash
$ pg_dump -n '(east|west)*gsm' -N '*test*' mydb > db.sql
```

## 11. Чтобы выгрузить все объекты базы данных, за исключением таблиц, имена которых начинаются с ts_ :
``` bash
$ pg_dump -T 'ts_*' mydb > db.sql
```

## 12. Чтобы указать имя в верхнем или смешанном регистре в -t и связанных ключах, вам нужно заключить имя в двойные кавычки; в противном случае оно будет свернуто в нижний регистр (см. Patterns ). Но двойные кавычки являются специальными для оболочки, поэтому, в свою очередь, их нужно заключать в кавычки. Таким образом, чтобы выгрузить одну таблицу с именем в смешанном регистре, вам нужно что-то вроде
``` bash
$ pg_dump -t "\"MixedCaseName\"" mydb > mytab.sql
```

### Смотрите также    
pg_dumpall , pg_restore , psql



2. pg_restore — это утилита для восстановления базы данных PostgreSQL из архива, созданного pg_dump в одном из форматов, отличных от обычного текста. 

# Примеры
## 1. Предположим, мы выполнили дамп базы данных с именем mydb в файл дампа пользовательского формата:
``` bash
$ pg_dump -Fc mydb > db.dump
```

## 2. Чтобы удалить базу данных и создать ее заново из дампа:
``` bash
$ dropdb mydb
$ pg_restore -C -d postgres db.dump
```
### База данных, указанная в ключе -d, может быть любой базой данных, существующей в кластере; pg_restore использует ее только для выдачи команды CREATE DATABASE для mydb . С -C данные всегда восстанавливаются в имя базы данных, которое отображается в файле дампа.

## 3. Чтобы перезагрузить дамп в новую базу данных с именем newdb :
``` bash
$ createdb -T template0 newdb
$ pg_restore -d newdb db.dump
```
### Обратите внимание, что мы не используем -C , а вместо этого подключаемся напрямую к базе данных, в которую нужно восстановиться. 
### Также обратите внимание, что мы клонируем новую базу данных из template0 , а не template1 , чтобы гарантировать, что она изначально пуста.