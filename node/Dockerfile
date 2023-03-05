FROM ubuntu:22.04

MAINTAINER Malachai <prussian1933@naver.com>

# Utilities
RUN \
    cd /home && \
    apt-get update && \
    apt-get install net-tools vim wget curl -y && \
    apt-get install ssh -y && \
    apt-get install build-essential gcc g++ make -y
RUN \
    apt-get install zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libbz2-dev libsasl2-dev -y && \
    apt-get install sqlite3 libsqlite3-dev -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Java installation
RUN \
    mkdir -p /usr/lib/jvm && \
    wget https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u342-b07/OpenJDK8U-jdk_x64_linux_8u342b07.tar.gz && \
    tar -xvf OpenJDK8U-jdk_x64_linux_8u342b07.tar.gz && \
    mv openjdk-8u342-b07 /usr/lib/jvm/java-1.8.0-openjdk-8u342-b07 && \
    mkdir -p /usr/lib/jvm/java-1.8.0-openjdk-8u342-b07/lib/ext
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-8u342-b07
ENV PATH=$PATH:$JAVA_HOME/bin

# Scala Installation
RUN \
    wget https://downloads.lightbend.com/scala/2.12.17/scala-2.12.17.tgz && \
    tar -xvf scala-2.12.17.tgz && \
    mv scala-2.12.17 /usr/local/lib/scala-2.12.17
ENV SCALA_HOME=/usr/local/lib/scala-2.12.17
ENV PATH=$PATH:$SCALA_HOME/bin

# Python3 installation
RUN \
    mkdir -p /usr/local/lib && \
    wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tgz && \
    tar -xzf Python-3.9.5.tgz && \
    mv Python-3.9.5 /usr/local/lib/python-3.9.5 && \
    cd /usr/local/lib/python-3.9.5 && \
    ./configure --enable-optimizations && \
    make -j 12 && \
    make altinstall
RUN \
    python3.9 -m pip install pip --upgrade && \
    pip install --upgrade setuptools && \
    cd /home && \
    apt install python3-dev -y

# Hadoop installation
RUN \
    mkdir -p /usr/local/lib && \
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && \
    tar xvzf hadoop-3.3.4.tar.gz && \
    mv hadoop-3.3.4 /usr/local/lib/hadoop-3.3.4
ENV HADOOP_HOME=/usr/local/lib/hadoop-3.3.4
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV PATH=$PATH:$HADOOP_HOME/sbin

# Hadoop env settings
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
COPY ../lib/hadoop-3.3.4/etc/hadoop/hadoop-env.sh $HADOOP_CONF_DIR

# Zookeeper installation
RUN \
    wget https://dlcdn.apache.org/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz &&\
    tar xvfz apache-zookeeper-3.7.1-bin.tar.gz && \
    mv apache-zookeeper-3.7.1-bin /usr/local/lib/apache-zookeeper-3.7.1-bin && \
    mkdir /usr/local/lib/apache-zookeeper-3.7.1-bin/data
ENV ZOOKEEPER_HOME=/usr/local/lib/apache-zookeeper-3.7.1-bin
ENV PATH=$PATH:$ZOOKEEPER_HOME/bin

# Zookeeper env settings
COPY ../lib/apache-zookeeper-3.7.1-bin/conf/zoo.cfg $ZOOKEEPER_HOME/conf

# Hadoop-Zookeeper HA env settings
COPY ../lib/hadoop-3.3.4/etc/hadoop/core-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/hdfs-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/yarn-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/mapred-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/workers $HADOOP_CONF_DIR
ENV HDFS_JOURNALNODE_USER=root
ENV HDFS_ZKFC_USER=root
ENV YARN_PROXYSERVER_USER=root

# Hive installation
RUN \
    wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz && \
    tar -xzvf apache-hive-3.1.3-bin.tar.gz && \
    mv apache-hive-3.1.3-bin /usr/local/lib/apache-hive-3.1.3-bin
ENV HIVE_HOME=/usr/local/lib/apache-hive-3.1.3-bin
ENV PATH=$PATH:$HIVE_HOME/bin

# Hive env settings
RUN \
    wget https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j-8.0.32.tar.gz &&\
    tar -xvf mysql-connector-j-8.0.32.tar.gz && \
    mv mysql-connector-j-8.0.32/mysql-connector-j-8.0.32.jar $JAVA_HOME/jre/lib/ext
COPY ../lib/apache-hive-3.1.3-bin/conf/hive-site.xml $HIVE_HOME/conf

# Spark installation
RUN \
    wget https://dlcdn.apache.org/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz && \
    tar -xzf spark-3.3.2-bin-hadoop3.tgz && \
    mv spark-3.3.2-bin-hadoop3 /usr/local/lib/spark-3.3.2-bin-hadoop3
ENV SPARK_HOME=/usr/local/lib/spark-3.3.2-bin-hadoop3
ENV PATH=$PATH:$SPARK_HOME/bin

# Spark env settings
COPY ../lib/spark-3.3.2-bin-hadoop3/conf/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
COPY ../lib/spark-3.3.2-bin-hadoop3/conf/spark-env.sh $SPARK_HOME/conf/spark-env.sh

# RabbitMQ installation
RUN \
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt install erlang logrotate socat -y
RUN \
    wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.10.9/rabbitmq-server_3.10.9-1_all.deb && \
    dpkg -i rabbitmq-server_3.10.9-1_all.deb

# Airflow installation
RUN \
    apt install libmysqlclient-dev -y && \
    pip install mysqlclient && \
    pip install mysql-connector-python && \
    pip install apache-airflow[mysql,celery]==2.5.0 && \
    mkdir -p /usr/local/lib/apache-airflow-2.5.0/logs && \
    mkdir -p /usr/local/lib/apache-airflow-2.5.0/dags && \
    mkdir -p /usr/local/lib/apache-airflow-2.5.0/plugins && \
    mkdir -p /usr/local/lib/apache-airflow-2.5.0/conf
ENV AIRFLOW_HOME=/usr/local/lib/apache-airflow-2.5.0
ENV AIRFLOW_CONFIG=$AIRFLOW_HOME/conf/airflow.cfg
ENV DAGS_FOLDER=/usr/local/lib/apache-airflow-2.5.0/dags
ENV PYTHONPATH=$PYTHONPATH:$AIRFLOW_HOME/dags/lib

# Airflow env settings
COPY ../lib/apache-airflow-2.5.0/conf/airflow.cfg $AIRFLOW_HOME/conf
ENV AIRFLOW_CONN_HIVE_CLI_DEFAULT=jdbc:hive2://hive:hive@localhost:10000/real_estate

# Python packages for Airflow DAGs
RUN \
    apt-get update && \
    pip install pandas && \
    pip install apache-airflow-providers-apache-hive

# Kafka Installation
RUN \
    wget https://dlcdn.apache.org/kafka/3.4.0/kafka_2.12-3.4.0.tgz && \
    tar -xvf kafka_2.12-3.4.0.tgz && \
    mv kafka_2.12-3.4.0 /usr/local/lib/kafka_2.12-3.4.0
ENV KAFKA_HOME=/usr/local/lib/kafka_2.12-3.4.0
ENV PATH=$PATH:$KAFKA_HOME/bin

# Kafka env settings
ENV KAFKA_CONF_DIR=$KAFKA_HOME/config

# Flume Installation
RUN \
    wget https://dlcdn.apache.org/flume/1.11.0/apache-flume-1.11.0-bin.tar.gz && \
    tar -xvf apache-flume-1.11.0-bin.tar.gz && \
    mv apache-flume-1.11.0-bin /usr/local/lib/apache-flume-1.11.0-bin
ENV FLUME_HOME=/usr/local/lib/apache-flume-1.11.0-bin
ENV PATH=$PATH:$FLUME_HOME/bin

# Flume env settings
ENV FLUME_CONF_DIR=$FLUME_HOME/conf
COPY ../lib/apache-flume-1.11.0-bin/conf/flume-conf.properties $FLUME_CONF_DIR
COPY ../lib/apache-flume-1.11.0-bin/conf/flume-hdfs-conf.properties $FLUME_CONF_DIR
COPY ../lib/apache-flume-1.11.0-bin/conf/flume-kafka-conf.properties $FLUME_CONF_DIR

# Cassandra Installation
RUN \
    wget https://dlcdn.apache.org/cassandra/4.0.8/apache-cassandra-4.0.8-bin.tar.gz && \
    tar xzvf apache-cassandra-4.0.8-bin.tar.gz && \
    mv apache-cassandra-4.0.8 /usr/local/lib/apache-cassandra-4.0.8
ENV CASSANDRA_HOME=/usr/local/lib/apache-cassandra-4.0.8
ENV PATH=$PATH:$CASSANDRA_HOME/bin

# Cassandra env settings
COPY ../lib/apache-cassandra-4.0.8/conf/cassandra-env.sh $CASSANDRA_HOME/conf
COPY ../lib/apache-cassandra-4.0.8/conf/cassandra.yaml $CASSANDRA_HOME/conf
COPY ../lib/apache-cassandra-4.0.8/conf/logback.xml $CASSANDRA_HOME/conf


ENTRYPOINT ["/bin/bash"]