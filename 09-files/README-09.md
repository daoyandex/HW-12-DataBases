Каталог
hw-12-9-mdb
b1gub4a146654m0cufvr

Инициализация yc-профиля для каталога
~/HW-12-DataBases/09-mdb

OAuth-токен 
y0_AgAAAAB1k72UAATuwQAAAAED3RSNAADMBRh2XShNyrRaGREkNnLUinFffQ


Сервисный аккаунт
sa-12-9-mdb
aje8lsci4sbbfttdmav1

#### 4 Для созданного сервисного аккаунта создадим авторизованный ключ для управления каталогом
yc iam key create --service-account-name sa-12-9-mdb --folder-name hw-12-9-mdb --output ./yc-sa-key-12-9-mdb.json
id: ajer42kibpd4tn1u6nih
service_account_id: aje8lsci4sbbfttdmav1
created_at: "2024-12-04T08:57:58.183749928Z"
key_algorithm: RSA_2048

## 5 Для конфигурации профиля CLI yc profile-12-9
## укажем созданный авторизованный ключ сервсного аккаунта sa-12-9-mdb :
$ yc config set service-account-key ./yc-sa-key-12-9-mdb.json

## В ~/.bashrc прописана функция
``` bash
init_yc() {
        export YC_TOKEN=$(yc iam create-token)
        export YC_CLOUD_ID=$(yc config get cloud-id)
        export YC_FOLDER_ID=$(yc config get folder-id)
}
```
Вызовем ее для получения переменных окружения

echo $YC_TOKEN
t1.9euelZqOnI-ez82Tz42JnI6QiZ6Mm-3rnpWax5OMnJbLjJ2dmYuLm5Keic7l8_dAPz9F-e9ILSFr_t3z9wBuPEX570gtIWv-zef1656VmsaKi5aZxo2Ni5rLzcmPnM2P7_zN5_XrnpWajcvNlJadj5vLi5HOismRlpfv_cXrnpWaxoqLlpnGjY2LmsvNyY-czY8.Hf-JlfV7Nw2iujKX_E6hVKIhjfWWCmP210GDaGlE_fcHKA0DJPUztlvUAnrtiqLi-RNPe-OBkS34BMtjbf96Cw

echo $YC_CLOUD_ID
b1gat3mr49cc9tpvs9vo

echo $YC_FOLDER_ID
b1gub4a146654m0cufvr



rc1a-6vvxue977rffcyx9.mdb.yandexcloud.net
62.84.118.232

rc1a-xmr02l7c5udquvdy.mdb.yandexcloud.net
84.201.158.186

rc1b-sgd3r7j12nutga86.mdb.yandexcloud.net
89.169.163.239

## получить сертификат
$ mkdir -p ~/.postgresql && \
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" --output-document ~/.postgresql/root.crt && \
chmod 0655 ~/.postgresql/root.crt

## вывести список хостов кластера
user@debian:~$ yc managed-postgresql host list   --cluster-name test_ha
+-------------------------------------------+----------------------+---------+--------+---------------+-----------+-------------------------------------------+
|                   NAME                    |      CLUSTER ID      |  ROLE   | HEALTH |    ZONE ID    | PUBLIC IP |            REPLICATION SOURCE             |
+-------------------------------------------+----------------------+---------+--------+---------------+-----------+-------------------------------------------+
| rc1a-6vvxue977rffcyx9.mdb.yandexcloud.net | c9qmfuhmograqid1c2n9 | MASTER  | ALIVE  | ru-central1-a | true      |                                           |
| rc1a-xmr02l7c5udquvdy.mdb.yandexcloud.net | c9qmfuhmograqid1c2n9 | REPLICA | ALIVE  | ru-central1-a | true      |                                           |
| rc1b-sgd3r7j12nutga86.mdb.yandexcloud.net | c9qmfuhmograqid1c2n9 | REPLICA | ALIVE  | ru-central1-b | true      | rc1a-6vvxue977rffcyx9.mdb.yandexcloud.net |
+-------------------------------------------+----------------------+---------+--------+---------------+-----------+-------------------------------------------+

## Подключение к хосту-мастеру кластера
## в параметре host= указаны FQDN всех хостов кластера через запятую
user@debian:~$ psql "host=rc1a-6vvxue977rffcyx9.mdb.yandexcloud.net,rc1a-xmr02l7c5udquvdy.mdb.yandexcloud.net,rc1b-sgd3r7j12nutga86.mdb.yandexcloud.net \                                     
      port=6432 \
      sslmode=verify-full \
      dbname=testdb \
      user=user \
      target_session_attrs=read-write"

Пароль пользователя user: 
psql (17.0 (Debian 17.0-1.pgdg120+1), сервер 15.8 (Ubuntu 15.8-201-yandex.55088.00e177b87c))
SSL-соединение (протокол: TLSv1.3, шифр: TLS_AES_256_GCM_SHA384, сжатие: выкл., ALPN: нет)
Введите "help", чтобы получить справку.

testdb=>