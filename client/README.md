# Jupyter Lab

### Spark Notebook 실행 방법(예제 경로는 /home/notebook)
```
[client]> hadoop fs -mkdir -p /user/spark/event/log
[client]> jupyter lab --ip=0.0.0.0 --port=9090 --allow-root
```


## 1. BasicSparkWithHive

- Spark와 Hive간 연결을 생성하고 HQL을 통해 데이터를 주고받는 연습 코드
- 기본 세팅
```
# Hive 에 스키마가 생성되어있어야 한다.
[master01]> hive
hive>>> CREATE SCHEMA IF NOT EXISTS real_estate;

# Hiveserver2 가 실행되고 있어야 한다.
[master01]> hiveserver2

# Hiveserver2 와의 연결이 설정 되어있어야 한다.
# Airflow의 Web UI(localhost:5082)의 Admin-Connections 메뉴에서 다음을 추가한다.
Connection Id: hive_cli_real_estate
Connection Type: Hive Client Wrapper
Host: master01
Schema: real_estate
Login: hive
Password: hive
Port: 10000
Extra: {"use_beeline": false, "auth": ""}

# Airflow 의 real_estate_workflow DAG 가 최소 한번 실행되어야 한다.
# 이를 위해 Airflow Web UI 에 접속하여 admin/admin 계정에 로그인, Trigger DAG 를 실행한다.
```


## 2. BasicSparkWithKafka

- Spark를 Kafka의 consumer로 연결하고 실시간으로 데이터를 출력하는 연습 코드
- 기본 설정
```
# Kafka Topic에 producer가 데이터를 넣을 수 있어야 한다.
# 기본 Kafka producer 예제인 console-producer를 사용한다.
[master01 || master02 || slave01 || slave02 || slave03]> kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092

# 선택 사항으로, producer가 제대로 동작하고 있는지 확인하기 위해선 다음의 console-consumer를 사용할 수 있다.
[master01 || master02 || slave01 || slave02 || slave03]> kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092
```

## 3. SparkWithKafkaCassandraSink

- Kafka로부터 실시간 생성되는 데이터를 Spark로 전처리 하여 Cassandra DB에 저장하는 연습 코드
- 기본 세팅
```
# Kafka에 데이터를 스트리밍 할 producer가 실행중이어야 한다.
[master01 || master02 || slave01 || slave02 || slave03]> kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092

# Cassandra에 데이터를 출력할 keyspace와 table이 존재해야 한다.
[master01 || master02 || slave01]cqlsh> CREATE KEYSPACE mykeyspace WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
[master01 || master02 || slave01]cqlsh> USE mykeyspace;
[master01 || master02 || slave01]cqlsh> CREATE TABLE stream (
                           key INT PRIMARY KEY,
                           value TEXT,
                           topic TEXT,
                           partition INT,
                           offset BIGINT,
                           timestamp TIMESTAMP,
                           "timestampType" INT
                         );
```


## Apendix A. SSH 터널링을 통한 VNC 접속
```
1. 로컬에 TigerVNC 클라이언트 설치
> apt install tigervnc-viewer

2. 원격에 VNC를 지원하는 Docker 컨테이너 실행
> docker run -p 6080:80 -p 5900:5900 -v /dev/shm:/dev/shm dorowu/ubuntu-desktop-lxde-vnc

3.로컬의 62000포트와 원격의 5900포트를 SSH 터널링
> ssh -L 62000:localhost:5900 -N [원격 사용자 이름]@[원격 주소] -i [키페어 위치]

4. 로컬의 TigerVNC 실행, 62000포트에 접속
```