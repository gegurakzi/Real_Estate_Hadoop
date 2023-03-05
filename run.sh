#!/usr/bin/env bash

sudo docker-compose down && \
\
sudo docker build -t cluster:node -f node/Dockerfile . && \
sudo docker build -t cluster:client -f client/Dockerfile . && \
sudo docker-compose up -d && \
\
sudo bash sbin/deploy-ssh-keys.sh && \
sudo bash sbin/deploy-ssh-authorized-keys.sh && \
\
sudo docker exec -u root metastore mysql -u root -proot -e "
  CREATE DATABASE hive;
  CREATE DATABASE airflow;
  CREATE USER hive IDENTIFIED BY 'hive';
  CREATE USER airflow IDENTIFIED BY 'airflow';
  GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%';
  GRANT ALL PRIVILEGES ON airflow.* TO 'airflow'@'%';"
\
sudo docker exec slave01 rabbitmq-plugins enable rabbitmq_management && \
sudo docker exec slave01 /usr/sbin/rabbitmq-server start -detached && \
sleep 10 && \
sudo docker exec slave01 rabbitmqctl add_user airflow-user airflow-user && \
sudo docker exec slave01 rabbitmqctl add_vhost airflow && \
sudo docker exec slave01 rabbitmqctl set_user_tags airflow-user administrator && \
sudo docker exec slave01 rabbitmqctl set_permissions -p airflow airflow-user ".*" ".*" ".*" && \
\
sudo docker exec master01 airflow db init && \
sudo docker exec master01 airflow users create --username admin  --password admin \
  --firstname FIRST_NAME --lastname LAST_NAME --role Admin --email admin@example.org && \
sudo docker exec -d master01 sh -c "airflow celery worker > /usr/local/lib/apache-airflow-2.5.0/logs/master01-celery-worker.log" && \
sudo docker exec -d master02 sh -c "airflow celery worker > /usr/local/lib/apache-airflow-2.5.0/logs/master02-celery-worker.log" && \
sudo docker exec -d slave01 sh -c "airflow celery worker > /usr/local/lib/apache-airflow-2.5.0/logs/slave01-celery-worker.log" && \
sudo docker exec -d slave02 sh -c "airflow celery worker > /usr/local/lib/apache-airflow-2.5.0/logs/slave02-celery-worker.log" && \
sudo docker exec -d slave03 sh -c "airflow celery worker > /usr/local/lib/apache-airflow-2.5.0/logs/slave03-celery-worker.log" && \
sudo docker exec -d slave01 sh -c "airflow celery flower > /usr/local/lib/apache-airflow-2.5.0/logs/slave01-celery-flower.log" && \
sudo docker exec -d slave01 sh -c "airflow scheduler > /usr/local/lib/apache-airflow-2.5.0/logs/slave01-scheduler.log" && \
sudo docker exec -d slave01 sh -c "airflow webserver --port 5080 > /usr/local/lib/apache-airflow-2.5.0/logs/slave01-web-server.log" && \
\
sudo bash lib/apache-zookeeper-3.7.1-bin/sbin/deploy-myid.sh && \
sudo docker exec master01 sh -c "zkServer.sh start" && \
sudo docker exec master02 sh -c "zkServer.sh start" && \
sudo docker exec slave01 sh -c "zkServer.sh start" && \
\
export KAFKA_HOME=/usr/local/lib/kafka_2.12-3.4.0 && \
sudo bash lib/kafka_2.12-3.4.0/sbin/deploy-brokerid.sh && \
sudo docker exec -d master01 kafka-server-start.sh $KAFKA_HOME/config/server.properties && \
sudo docker exec -d master02 kafka-server-start.sh $KAFKA_HOME/config/server.properties && \
sudo docker exec -d slave01 kafka-server-start.sh $KAFKA_HOME/config/server.properties && \
sudo docker exec -d slave02 kafka-server-start.sh $KAFKA_HOME/config/server.properties && \
sudo docker exec -d slave03 kafka-server-start.sh $KAFKA_HOME/config/server.properties && \
\
sudo docker exec master01 sh -c "hdfs zkfc -formatZK" && \
sudo docker exec master01 sh -c "hdfs --daemon start journalnode" && \
sudo docker exec master02 sh -c "hdfs --daemon start journalnode" && \
sudo docker exec slave01 sh -c "hdfs --daemon start journalnode" && \
\
sudo docker exec master01 sh -c "hdfs namenode -format" && \
sudo docker exec master01 sh -c "start-dfs.sh" && \
sudo docker exec master02 sh -c "hdfs namenode -bootstrapStandby" && \
sudo docker exec master02 sh -c "hdfs --daemon start namenode" && \
\
sudo docker exec master01 sh -c "start-yarn.sh" && \
sudo docker exec master01 sh -c "mapred --daemon start historyserver" && \
sudo docker exec master02 sh -c "mapred --daemon start historyserver" && \
\
sudo docker exec master01 schematool -initSchema -dbType mysql && \
#\
#export FLUME_CONF_DIR=/usr/local/lib/apache-flume-1.11.0-bin/conf && \
#export FLUME_LOG_DIR=/usr/local/lib/apache-flume-1.11.0-bin && \
#sudo docker exec -d master01 flume-ng agent -c $FLUME_CONF_DIR -f $FLUME_CONF_DIR/flume-hdfs-conf.properties -Dflume.log.dir=$FLUME_LOG_DIR -n hdfs-airflow-log && \
#sudo docker exec -d master02 flume-ng agent -c $FLUME_CONF_DIR -f $FLUME_CONF_DIR/flume-hdfs-conf.properties -Dflume.log.dir=$FLUME_LOG_DIR -n hdfs-airflow-log && \
#sudo docker exec -d slave01 flume-ng agent -c $FLUME_CONF_DIR -f $FLUME_CONF_DIR/flume-hdfs-conf.properties -Dflume.log.dir=$FLUME_LOG_DIR -n hdfs-airflow-log && \
#sudo docker exec -d slave02 flume-ng agent -c $FLUME_CONF_DIR -f $FLUME_CONF_DIR/flume-hdfs-conf.properties -Dflume.log.dir=$FLUME_LOG_DIR -n hdfs-airflow-log && \
#sudo docker exec -d slave03 flume-ng agent -c $FLUME_CONF_DIR -f $FLUME_CONF_DIR/flume-hdfs-conf.properties -Dflume.log.dir=$FLUME_LOG_DIR -n hdfs-airflow-log && \
\
sudo docker exec -d master01 sh -c 'cassandra -R >> $CASSANDRA_HOME/cassandra-startup.log' && \
sleep 10 && \
sudo docker exec -d master02 sh -c 'cassandra -R >> $CASSANDRA_HOME/cassandra-startup.log' && \
sleep 10 && \
sudo docker exec -d slave01 sh -c 'cassandra -R >> $CASSANDRA_HOME/cassandra-startup.log'
