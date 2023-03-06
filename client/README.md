# Jupyter Lab

### Spark Notebook 실행 방법(예제 경로는 /home/notebook)
```
[client]> hadoop fs -mkdir -p /user/spark/event/log
[client]> jupyter lab --ip=0.0.0.0 --port=9090 --allow-root
```


## 1. BasicSparkWithHive

- Spark와 Hive간 연결을 생성하고 HQL을 통해 데이터를 주고받는 연습 코드

## 2. BasicSparkWithKafka

- Spark를 Kafka의 consumer로 연결하고 실시간으로 데이터를 출력하는 연습 코드

## 3. SparkWithKafkaCassandraSink

- Kafka로부터 실시간 생성되는 데이터를 Spark로 전처리 하여 Cassandra DB에 저장하는 연습 코드