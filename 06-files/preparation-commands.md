1. Запуск контейнеров
``` bash
$ docker run --name replica-slave -e MYSQL_ROOT_PASSWORD=master -d mysql:8.3
$ docker run --name replica-slave -e MYSQL_ROOT_PASSWORD=slave -d mysql:8.3

$ docker network create replica-network
$ docker network connect replica-network replica-master 
$ docker network connect replica-network replica-slave
```
2. в контейнере, который будет master:
``` bash
$ docker exec -it replica-master mysql -uroot -p

mysql> CREATE USER 'replication'@'%';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
mysql> SHOW GRANTS FOR 'replication'@'%';

mysql> exit

# теперь нужно добавить пару строк в конфигурационный файл  /etc/my.cnf в контейрене master:
$ docker exec -it replica-master bash -uroot -p
$ sudo cd /etc/
$ cat my.cnf

# copy stdot - to file /home/user/HW-12-DataBases/06-files/my.cnf.bkp
# add to section [mysqld] добавляем следующие параметры:
# server_id = 1
# log_bin = mysql-bin
# и записываем обратно в /etc/my.cnf: вводим строку, и далее shift+Insert - добавляем весь ранее сохраненный и доработанный текст файла
$ cat > my.cnf << EOF
> ...
> ...
> EOF
#  exit
```
3. При изменении конфигурации сервера требуется перезагрузка:
``` bash
docker restart replication-master
```
После требуется зайти в контейнер и проверить состояние:
``` bash
docker exec -it replication-master mysql
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      158 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set, 1 warning (0.01 sec)
```

4. Выполяним доработку /etc/my.cnf для контейнера replica-slave

Открываем конфигурационный файл на Slave my.cnf, в секции [mysqld] добавляем следующие параметры:
``` bash
log_bin = mysql-bin
server_id = 2
relay-log = /var/lib/mysql/mysql-relay-bin
relay-log-index = /var/lib/mysql/mysql-relay-bin.index
read_only = 1
```

Перезагружаем slave:
``` bash
docker restart replication-slave
```


5. Произведем настройку mysql на replica-slave
``` bash
$ docker exec -it replica-slave mysql -uroot -p
Enter password: 
mysql> CHANGE MASTER TO MASTER_HOST='replica-master', MASTER_USER='replication', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=158;

ERROR 3021 (HY000): This operation cannot be performed with a running replica io thread; run STOP REPLICA IO_THREAD FOR CHANNEL '' first.

mysql> STOP REPLICA IO_THREAD FOR CHANNEL '';
Query OK, 0 rows affected (0.00 sec)

mysql> CHANGE MASTER TO MASTER_HOST='replica-master', 
MASTER_USER='replication', 
MASTER_LOG_FILE='mysql-bin.000001', 
MASTER_LOG_POS=158;

Query OK, 0 rows affected, 7 warnings (0.00 sec)

mysql> START REPLICA IO_THREAD FOR CHANNEL '';
Query OK, 0 rows affected (0.01 sec)

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



