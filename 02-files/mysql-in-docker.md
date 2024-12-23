Как использовать это изображение
Запустить mysqlэкземпляр сервера
Запустить экземпляр MySQL просто:

``` bash
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
```
... где some-mysql— имя, которое вы хотите назначить вашему контейнеру, my-secret-pw— пароль, который нужно задать для пользователя MySQL root, и tag— тег, указывающий нужную вам версию MySQL. Смотрите список выше для соответствующих тегов.

Подключитесь к MySQL из клиента командной строки MySQL
Следующая команда запускает другой mysqlэкземпляр контейнера и запускает mysqlклиент командной строки для вашего исходного mysqlконтейнера, позволяя вам выполнять операторы SQL для вашего экземпляра базы данных:

``` bash
$ docker run -it --network some-network --rm mysql mysql -hsome-mysql -uexample-user -p
```
... где some-mysqlнаходится имя вашего исходного mysqlконтейнера (подключенного к some-networkсети Docker).

Этот образ также можно использовать в качестве клиента для не-Docker или удаленных экземпляров:

``` bash
$ docker run -it --rm mysql mysql -hsome.mysql.host -usome-mysql-user -p
```
Более подробную информацию о клиенте командной строки MySQL можно найти в документации MySQL ⁠

... через docker-compose⁠ или docker stack deploy⁠
Пример docker-compose.ymlдля mysql:
``` bash
# Use root/example as user/password credentials
version: '3.1'

services:

  db:
    image: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
    # (this is just an example, not intended to be a production configuration)
```
Попробуйте в PWD

Запустите 
``` bash
docker stack deploy -c stack.yml mysql
```
(или docker-compose -f stack.yml up), дождитесь полной инициализации и посетите http://swarm-ip:8080, http://localhost:8080, или http://host-ip:8080(в зависимости от ситуации).

Доступ к оболочке контейнера и просмотр журналов MySQL
Команда docker execпозволяет вам запускать команды внутри контейнера Docker. Следующая командная строка даст вам оболочку bash внутри вашего mysqlконтейнера:
``` bash
$ docker exec -it some-mysql bash
```
Журнал доступен через журнал контейнера Docker:
``` bash
$ docker logs some-mysql
```
Использование пользовательского файла конфигурации MySQL
Конфигурацию MySQL по умолчанию можно найти в /etc/mysql/my.cnf, которая может содержать !includedirдополнительные каталоги, такие как /etc/mysql/conf.dили /etc/mysql/mysql.conf.d. Пожалуйста, проверьте соответствующие файлы и каталоги в mysqlсамом образе для получения более подробной информации.

Если /my/custom/config-file.cnf— это путь и имя вашего пользовательского файла конфигурации, вы можете запустить свой mysqlконтейнер следующим образом (обратите внимание, что в этой команде используется только путь к каталогу пользовательского файла конфигурации):
``` bash
$ docker run --name some-mysql -v /my/custom:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
```
Это запустит новый контейнер some-mysql, в котором экземпляр MySQL будет использовать объединенные параметры запуска из /etc/mysql/my.cnf и /etc/mysql/conf.d/config-file.cnf, причем параметры из последнего будут иметь приоритет.

Конфигурация без cnfфайла
Многие параметры конфигурации могут быть переданы как флаги в mysqld. Это даст вам гибкость в настройке контейнера без необходимости в cnfфайле. Например, если вы хотите изменить кодировку и сортировку по умолчанию для всех таблиц на использование UTF-8 ( utf8mb4), просто выполните следующее:
``` bash
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```
Если вы хотите увидеть полный список доступных опций, просто выполните:
``` bash
$ docker run -it --rm mysql:tag --verbose --help
```
Переменные среды
При запуске mysqlобраза вы можете настроить конфигурацию экземпляра MySQL, передав одну или несколько переменных среды в docker runкомандной строке. Обратите внимание, что ни одна из переменных ниже не будет иметь никакого эффекта, если вы запустите контейнер с каталогом данных, который уже содержит базу данных: любая существующая база данных всегда останется нетронутой при запуске контейнера.

См. также https://dev.mysql.com/doc/refman/5.7/en/environment-variables.html ⁠ для получения документации по переменным среды, которые учитывает сам MySQL (особенно такие переменные, как MYSQL_HOST, которые, как известно, вызывают проблемы при использовании с этим образом).

MYSQL_ROOT_PASSWORD
Эта переменная является обязательной и указывает пароль, который будет установлен для rootучетной записи суперпользователя MySQL. В приведенном выше примере он был установлен на my-secret-pw.

MYSQL_DATABASE
Эта переменная необязательна и позволяет указать имя базы данных, которая будет создана при запуске образа. Если были предоставлены имя пользователя/пароль (см. ниже), то этому пользователю будет предоставлен доступ суперпользователя ( соответствующий GRANT ALL⁠ ) к этой базе данных.

MYSQL_USER,MYSQL_PASSWORD
Эти переменные являются необязательными, используются совместно для создания нового пользователя и установки пароля этого пользователя. Этому пользователю будут предоставлены права суперпользователя (см. выше) для базы данных, указанной переменной MYSQL_DATABASE. Обе переменные необходимы для создания пользователя.

Обратите внимание, что нет необходимости использовать этот механизм для создания суперпользователя root, этот пользователь создается по умолчанию с паролем, указанным в MYSQL_ROOT_PASSWORDпеременной.

MYSQL_ALLOW_EMPTY_PASSWORD
Это необязательная переменная. Установите непустое значение, например yes, чтобы разрешить запуск контейнера с пустым паролем для пользователя root. ПРИМЕЧАНИЕ . Установка этой переменной в yesне рекомендуется, если вы не знаете, что делаете, поскольку это оставит ваш экземпляр MySQL полностью незащищенным, позволяя любому получить полный доступ суперпользователя.

MYSQL_RANDOM_ROOT_PASSWORD
Это необязательная переменная. Установите непустое значение, например yes, чтобы сгенерировать случайный начальный пароль для пользователя root (используя pwgen). Сгенерированный пароль root будет выведен на stdout ( GENERATED ROOT PASSWORD: .....).

MYSQL_ONETIME_PASSWORD
Устанавливает пользователя root ( не пользователя, указанного в MYSQL_USER!) как устаревшего после завершения init, принудительно меняя пароль при первом входе в систему. Любое непустое значение активирует эту настройку. ПРИМЕЧАНИЕ : эта функция поддерживается только в MySQL 5.6+. Использование этой опции в MySQL 5.5 вызовет соответствующую ошибку во время инициализации.

MYSQL_INITDB_SKIP_TZINFO
По умолчанию скрипт точки входа автоматически загружает данные часового пояса, необходимые для CONVERT_TZ()функции. Если они не нужны, любое непустое значение отключает загрузку часового пояса.

Секреты Докера
В качестве альтернативы передаче конфиденциальной информации через переменные среды _FILEможет быть добавлен к ранее перечисленным переменным среды, заставляя скрипт инициализации загружать значения для этих переменных из файлов, присутствующих в контейнере. В частности, это может быть использовано для загрузки паролей из секретов Docker, хранящихся в /run/secrets/<secret_name>файлах. 

Например:
``` bash
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql-root -d mysql:tag
```
В настоящее время это поддерживается только для MYSQL_ROOT_PASSWORD, MYSQL_ROOT_HOST, MYSQL_DATABASE, MYSQL_USERи MYSQL_PASSWORD.

Инициализация нового экземпляра
При первом запуске контейнера будет создана новая база данных с указанным именем, которая будет инициализирована с предоставленными переменными конфигурации. Кроме того, он выполнит файлы с расширениями .sh, .sqlи .sql.gz, которые находятся в /docker-entrypoint-initdb.d. Файлы будут выполнены в алфавитном порядке. Вы можете легко заполнить свои mysqlслужбы, смонтировав дамп SQL в этот каталог ⁠ и предоставив пользовательские образы ⁠ с предоставленными данными. Файлы SQL будут импортированы по умолчанию в базу данных, указанную MYSQL_DATABASEпеременной.

Предостережения
Где хранить данные
Важное примечание: существует несколько способов хранения данных, используемых приложениями, работающими в контейнерах Docker. Мы призываем пользователей образов mysqlознакомиться с доступными вариантами, включая:

Позвольте Docker управлять хранением данных вашей базы данных , записывая файлы базы данных на диск в хост-системе, используя собственное внутреннее управление томами ⁠ . Это значение по умолчанию, оно простое и довольно прозрачное для пользователя. Недостатком является то, что файлы может быть трудно найти для инструментов и приложений, которые работают непосредственно в хост-системе, т. е. вне контейнеров.
Создайте каталог данных на хост-системе (вне контейнера) и смонтируйте его в каталог, видимый изнутри контейнера ⁠ . Это помещает файлы базы данных в известное место на хост-системе и упрощает доступ инструментов и приложений на хост-системе к файлам. Недостатком является то, что пользователю необходимо убедиться, что каталог существует, и что, например, разрешения каталога и другие механизмы безопасности на хост-системе настроены правильно.
Документация Docker является хорошей отправной точкой для понимания различных вариантов и вариаций хранения, и есть множество блогов и сообщений на форумах, которые обсуждают и дают советы в этой области. Мы просто покажем здесь базовую процедуру для последнего варианта выше:

Создайте каталог данных на подходящем томе вашей хост-системы, например /my/own/datadir.

Начните свой mysqlконтейнер следующим образом:
``` bash
$ docker run --name some-mysql -v /my/own/datadir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
```
Часть -v /my/own/datadir:/var/lib/mysqlкоманды монтирует /my/own/datadirкаталог из базовой хост-системы как /var/lib/mysqlвнутри контейнера, куда MySQL по умолчанию будет записывать свои файлы данных.

Никаких подключений до завершения инициализации MySQL
Если при запуске контейнера не инициализирована база данных, то будет создана база данных по умолчанию. Хотя это ожидаемое поведение, это означает, что он не будет принимать входящие соединения, пока такая инициализация не завершится. Это может вызвать проблемы при использовании инструментов автоматизации, таких как docker-compose, которые запускают несколько контейнеров одновременно.

Если приложение, к которому вы пытаетесь подключиться, не обрабатывает время простоя MySQL или не ожидает корректного запуска MySQL, то может потребоваться установка цикла повторного подключения перед запуском службы. Пример такой реализации в официальных образах см. в WordPress ⁠ или Bonita ⁠ .

Использование существующей базы данных
Если вы запускаете mysqlэкземпляр контейнера с каталогом данных, который уже содержит базу данных (в частности, mysqlподкаталог), $MYSQL_ROOT_PASSWORDпеременную следует исключить из командной строки запуска; она в любом случае будет проигнорирована, а существующая база данных не будет изменена каким-либо образом.

Запуск от имени произвольного пользователя
Если вы знаете, что разрешения вашего каталога уже установлены соответствующим образом (например, для работы с существующей базой данных, как описано выше) или вам необходимо запустить его mysqldс определенным UID/GID, можно вызвать этот образ, задав --user любое значение (кроме root/ 0), чтобы получить желаемый доступ/конфигурацию:
``` bash
$ mkdir data
$ ls -lnd data
drwxr-xr-x 2 1000 1000 4096 Aug 27 15:54 data
$ docker run -v "$PWD/data":/var/lib/mysql --user 1000:1000 --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
```

Создание дампов баз данных
Большинство обычных инструментов будут работать, хотя их использование может быть немного запутанным в некоторых случаях, чтобы гарантировать, что у них есть доступ к серверу mysqld. Простой способ гарантировать это — использовать docker execи запускать инструмент из того же контейнера, примерно так:
``` bash
$ docker exec some-mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
```

Восстановление данных из файлов дампа
Для восстановления данных можно использовать docker execкоманду с -iфлагом, подобную следующей:
``` bash
$ docker exec -i some-mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < /some/path/on/your/host/all-databases.sql
```