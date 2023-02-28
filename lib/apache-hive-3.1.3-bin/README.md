# Hive Description

## 0-1. Dependencies for HiveOperator
```
apache-airflow>=2.3.0
apache-airflow-providers-common-sql>=1.3.1
hmsclient>=0.1.0
pandas>=0.17.1
pyhive[hive]>=0.6.0
sasl>=0.3.1; python_version>="3.9"
thrift>=0.9.2

apt install build-essential
apt install python3-dev
apt install libsasl2-dev
```

## 0-2. Airflow-Hive Library
```
apache-airflow-providers-apache-hive
```
Airflow - Hive 커넥션을 설정하기 위해선 Admin-Connection 메뉴에서 관리할 수 있음
Connection URI를 등록한 이후 HiveOperator의 hive_cli_conn_id를 통해 접속할 수 있음

* user authentication 문제 발생 시 다음을 hadoop/core-site.xml에 추가




## 1. Metastore initialization
```
> schematool -initSchema -dbType mysql
```

## 2. Hive Connection
```
> hive
```

## 3. Schema creation
```
> CREATE SCHEMA IF NOT EXISTS real_estate
```

## 4. Hive server start up
```
> hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000
```

## 5. HiveServer2 Connection Setup
```
Connection Id: hive_cli_real_estate
Connection Type: Hive Client Wrapper
Host: master01
Schema: real_estate
Login: hive
Password: hive
Port: 10000
Extra: {"use_beeline": false, "auth": ""}
```