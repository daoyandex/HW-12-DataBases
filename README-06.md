# Домашнее задание к занятию "`Репликация и масштабирование. Часть 1`" - `Алексеев Александр`


### Инструкция по выполнению домашнего задания

   1. Сделайте `fork` данного репозитория к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/git-hw или  https://github.com/имя-вашего-репозитория/7-1-ansible-hw).
   2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
   3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
      - впишите вверху название занятия и вашу фамилию и имя
      - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
      - для корректного добавления скриншотов воспользуйтесь [инструкцией "Как вставить скриншот в шаблон с решением](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
      - при оформлении используйте возможности языка разметки md (коротко об этом можно посмотреть в [инструкции  по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md))
   4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
   5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
   6. Любые вопросы по выполнению заданий спрашивайте в чате учебной группы и/или в разделе “Вопросы по заданию” в личном кабинете.
   
Желаем успехов в выполнении домашнего задания!
   
### Дополнительные материалы, которые могут быть полезны для выполнения задания

1. [Руководство по оформлению Markdown файлов](https://gist.github.com/Jekins/2bf2d0638163f1294637#Code)

---

### Задание 1  
На лекции рассматривались режимы репликации master-slave, master-master, опишите их различия.  
Ответить в свободной форме.  
#### Ответ:
**1. Репликация Master-Slave**  
* В этом режиме существует один основной сервер (master), на котором производятся все изменения данных. Затем все изменения реплицируются на прочие серверы (slaves). Все прочие серверы предоставляют данные только для чтения. Соответственно, назначение прочих серверов - помощь в распределении нагрузки при выполнении запросов на чтение, а также исполнение роли резервных копии на случай восстановления после сбоев.
* Преимущества: Простота настройки и управления. Снижение нагрузки на основной сервер и улучшение производительности базы данных в целом при запросах на чтение.
* Недостатки: slave-серверы могут отставать от master при недостаточно быстром процессе репликации. При отказе master-сервера необходим механизм (или вмешательство администратора) для повышения slave до статуса master.

**2. Репликация Master-Master**
* Два или более серверов работают как основные. Каждый сервер реплицирует свои изменения в данных на другие серверы, что позволяет производить запись и чтение на всех серверах.  
* Преимущества:  Базы данных с таким режимом репликации обладают повышенной отказоустойчивостью, отказ одного сервера не приводит к потере доступности системы в целом.  Несколько master-серверов обеспечивают хорошее распределении нагрузки на базу данных в целом.  
* Недостатки:  систему с тким режимом репликации сложнее настроить и ей сложнее управлять, ввиду возможных коллизий при синхронизации данных, когда одновременно изменяются одни и те же данные на разных серверах. Это влечет больше накладных расходов на организацию работы серверов.


Для обоих режимов репликация может выполняться синхронно или асинхронно.  
Синхронный подход гарантирует, что все серверы будут содержать одини и те же данные в любой момент времени, но при нём ухудшается производительность базы данных в целом ввиду организации процессов синхронизации данных.  
Асинхронный подход обеспечивает более высокую производительность базы данных в целом, но при нём возникает риск того, что данные на разных серверах могут разойтись, ввиду чего возникает необходимость в периодических операциях сверки и при необходимости синхронизации данных.


### Задание 2  
Выполните конфигурацию master-slave репликации, примером можно пользоваться из лекции.  
Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.  
#### Ответ:
**0. Перечень команд для подготовки**  
- контейнеров,  
- добавления пользователей в базах данных с правом репликации,  
- изменений в /etc/my.cnf контейнеров,
- изменений в настройках инстанса slave  
[preparation-commands](/06-files/preparation-commands.md)
  
**1. База master**  
- Конфигурация master: [master_my.cnf](06-files/replica-master__/etc/my.cnf)  
![replica-master-conf](06-img/12-06-mysql-repl-task-2-master.png)  
- Базы данных  
![replica-master-databases](06-img/12-06-replication-task-2-master-bases.png)  
  
**2. База slave**  
- Конфигурация slave: [slave_my.cnf](06-files/replica-slave__/etc/my.cnf)  
``` bash
mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: replica-master
                  Master_User: replication
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 158
               Relay_Log_File: mysql-relay-bin.000002
                Relay_Log_Pos: 328
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 158
              Relay_Log_Space: 539
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: 373c9df7-9ed0-11ef-bc4f-0242ac110004
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 10
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
       Master_public_key_path: 
        Get_master_public_key: 0
            Network_Namespace: 
1 row in set, 1 warning (0.00 sec)

mysql> 
```  
- Базы данных slave:  
![replica-slave-databases](06-img/12-06-replication-task-2-slave-bases.png) 
  
---

Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

### Задание 3*  
Выполните конфигурацию master-master репликации. Произведите проверку.  
Приложите скриншоты конфигурации, выполнения работы: состояния и режимы работы серверов.  

#### Ответ:
**1. Создаем два контейнера по образу `mysql:8.3`**  
``` bash
# Создаем первый мастер
docker run -d --name master1 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql:8.3

# Создаем второй мастер
docker run -d --name master2 -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql:8.3
```  
**2. Создаем и настраиваем первый мастер (master1)**  
``` bash
docker exec -it master1 mysql

# Создаем пользователя для репликации
mysql> create user 'replication'@'%';
mysql> grant replication slave on *.* TO 'replication'@'%';

# Создаем тестовую базу данных
mysql> create database testdb;

# Проверяем статус master1
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: mysql-bin.000001
         Position: 158
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:
```  

**3. Создаем и настраиваем второй мастер (master2)**  
``` bash
docker exec -it master2 mysql

# Создаем пользователя для репликации
mysql> create user 'replication'@'%';
mysql> grant replication slave on *.* TO 'replication'@'%';

# Создаем тестовую базу данных
mysql> create database testdb;

# Проверяем статус master2
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: mysql-bin.000001
         Position: 158
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:
```  

**4. На master1 настраиваем репликацию** 
``` bash
mysql> stop slave;
mysql> CHANGE MASTER TO 
    MASTER_HOST='master2',
    MASTER_USER='replication',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=158;
mysql> start slave;

# Проверяем статус репликации
mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: master2
                  Master_User: replication
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 158
               Relay_Log_File: mysql-relay-bin.000002
                Relay_Log_Pos: 326
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```  

**5. На master2 настраиваем репликацию**  
``` bash
msql> stop slave;
mysql> CHANGE MASTER TO 
    MASTER_HOST='master1',
    MASTER_USER='replication',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=157;
mysql> start slave;

# Проверяем статус репликации
mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: master1
                  Master_User: replication
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
          Read_Master_Log_Pos: 158
               Relay_Log_File: mysql-relay-bin.000002
                Relay_Log_Pos: 326
        Relay_Master_Log_File: mysql-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```
  
##### Проверка работы репликации. 
**1. На master1:**  
``` bash
mysql> use testdb;
mysql> create table sample (id INT, test_col VARCHAR(100));
mysql> insert into sample values (1, 'Add from master1');

# Проверяем данные
mysql> select * from sample;
+------+------------------+
| id   | test_col         |
+------+------------------+
|    1 | Add from master1 |
+------+------------------+
```  

**2. На master2**  
``` bash
mysql> use testdb;
mysql> select * from sample;
+------+------------------+
| id   | test_col         |
+------+------------------+
|    1 | Add from master1 | 
+------+------------------+

# Добавляем данные с master2  
mysql> insert into sample values (2, 'Add from master2');
```

**3. Проверяем репликацию обратно на master1** 
``` bash
mysql> select * from sample;
+------+------------------+
| id   | test_col         |
+------+------------------+
|    1 | Add from master1 |
|    2 | Add from master2 |
+------+------------------+
```
  
**4. Настройка AUTO_INCREMENT для предотвращения конфликтов:**  
- на master1  
``` bash
SET GLOBAL auto_increment_increment=2;
SET GLOBAL auto_increment_offset=1;
```
- на master2  
``` bash
SET GLOBAL auto_increment_increment=2;
SET GLOBAL auto_increment_offset=2;
```