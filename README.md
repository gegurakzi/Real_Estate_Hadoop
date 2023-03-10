# Hadoop cluster deployment

```
Namenode: master01, master02
Datanode: slave01, slave02, slave03
Jouralnode: master01, master02, slave01
Hive: master01, master02
Spark: master01, master02
Airflow(celery workers): master01, master02, slave01(with webserver, scheduler), slave02, slave03

Namenode Web: 50070(master01) 50071(master02)
Node Manager Web: 8042(master01) 8043(master02)
Resource Manager Web: 8088(master01) 8089(master02)
MapReduce JobHistory Web: 19888(master01) 19889(master02)
Spark Application Manager Web(4040 4041 -> redirect to YARN Resource Manager/Spark Application): 8088/app_id#(master01) 8089/app_id#(master02)
Spark History Web: 18080(master01) 18081(master02)
Airflow WebServer: 5082:5080(default: 8080)
RabbitMQ Server: 15674:15672
Flower UI(web management for Airflow celery workers): 5557:5555
```

## 0. 실행법 요약
```
[local]> sudo bash run.sh
[local]> sudo docker attach client
[client]> jupyter lab --ip=0.0.0.0 --port=9090 --allow-root
```
daemons
- Zookeeper(JN)
- Hadoop(NN, DN, RM, NM)
- Rabbitmq
- Airflow(Celery, webserver, scheduler)
- Jupyter Lab


## 1. Dockerfile 빌드
```
[local]> sudo docker build -t cluster:node .
```

## 2. docker-compose 실행
```
[local]> sudo docker-compose up -d
```

## 3. 컨테이너 간 SSH 키 공유
```
[local]> sudo bash sbin/deploy-ssh-keys.sh
[local]> sudo bash sbin/deploy-ssh-authorized-keys.sh
```
* 기본적으로 SSH 접근하는 사용자는 root이기 때문에 sudo 권한으로 스크립트 실행

## 4. MySQL metastore 컨테이너에 hive, airflow metastore 추가
```
[metastore]> sudo docker exec -it metastore mysql -p
CREATE DATABASE hive;
CREATE DATABASE airflow;
CREATE USER hive IDENTIFIED BY 'hive';
CREATE USER airflow IDENTIFIED BY 'airflow';
GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%';
GRANT ALL PRIVILEGES ON airflow.* TO 'airflow'@'%';
quit;
```

## 5. RabbitMQ 시작
```
[slave01]> sudo service rabbitmq-server start
[slave01]> sudo rabbitmq-plugins enable rabbitmq_management
[slave01]> sudo rabbitmqctl add_user admin admin
[slave01]> sudo rabbitmqctl set_user_tags admin administrator
[slave01]> sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
```
* 사용 포트: 4369, 5671, 5672, 15672 ,25672 ,61613 ,61614 ,1883 ,8883

## 6. Airflow 시작
```
[slave01]> airflow db init
[slave01]> airflow users create \
--username admin \
--password admin \
--firstname FIRST_NAME \
--lastname LAST_NAME \
--role Admin \
--email admin@example.org
[master01~slave03]> airflow celery worker
[slave01]> airflow celery flower
[slave01]> airflow scheduler
[slave01]> airflow webserver --port 5080 -D &
```

## 7. Hadoop HA 클러스터 시작
```
[local]> sudo bash lib/apache-zookeeper-3.7.1-bin/sbin/deploy-myid.sh
[master01]> zkServer.sh start
[master02]> zkServer.sh start
[slave01]> zkServer.sh start
[master01]> hdfs zkfc -formatZK
[master01]> hdfs --daemon start journalnode
[master02]> hdfs --daemon start journalnode
[slave01]> hdfs --daemon start journalnode
[master01]> hdfs namenode -format
[master02]> hdfs namenode -bootstrapStandby
[master01]> start-dfs.sh
[master01]> start-yarn.sh
[master01]> mapred --daemon start historyserver
[master02]> mapred --daemon start historyserver
```

## 8. Kafka Server 시작
```
[master01~slave03]> kafka-server-start.sh $KAFKA_HOME/config/server.properties
```

## 9. Cassandra 시작
- master01, master02, slave01
```
[master01, master02, slave01]> cassandra -R >> $CASSANDRA_HOME/cassandra-startup.log

## Database 테스트
[master01]> clqsh master01 9042
```

## Appendix A.Client 실행 및 예제 연습
- client/README.md 참고