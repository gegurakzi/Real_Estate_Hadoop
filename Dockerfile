FROM centos:centos7

MAINTAINER Malachai <prussian1933@naver.com>

# Utilities
RUN \
    cd /home && \
    yum update -y && \
    yum install net-tools -y && \
    yum install vim-enhanced -y && \
    yum install wget -y && \
    yum install openssh-server openssh-clients openssh-askpass -y && \
    yum install gcc make openssl-devel bzip2-devel libffi-devel -y

# Java installation
RUN \
    yum install java-1.8.0-openjdk-devel.x86_64 -y
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.352.b08-2.el7_9.x86_64
ENV PATH=$PATH:$JAVA_HOME/bin

# Python3 installation
RUN \
    wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tgz && \
    tar -xvf Python-3.9.5.tgz && \
    mv Python-3.9.5 /usr/bin/python-3.9.5 && \
    cd /usr/bin/python-3.9.5 && \
    ./configure --enable-optimizations && \
    make altinstall
ENV PYTHON_HOME=/usr/local/bin/python3.9
ENV PYSPARK_PYTHON=$PYTHON_HOME

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
RUN \
    echo \
        $'export HADOOP_PID_DIR=/usr/local/lib/hadoop-3.3.4/pids \n\
          export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.352.b08-2.el7_9.x86_64 \n\
          export HDFS_NAMENODE_USER=\"root\" \n\
          export HDFS_DATANODE_USER=\"root\" \n\
          export HDFS_SECONDARYNAMENODE_USER=\"root\" \n\
          export YARN_RESOURCEMANAGER_USER=\"root\" \n\
          export YARN_NODEMANAGER_USER=\"root\" \n\
          ' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HADOOP_PID_DIR=$HADOOP_HOME/pids
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root


# Zookeeper installation
RUN \
    wget https://dlcdn.apache.org/zookeeper/zookeeper-3.7.1/apache-zookeeper-3.7.1-bin.tar.gz &&\
    tar xvfz apache-zookeeper-3.7.1-bin.tar.gz && \
    mv apache-zookeeper-3.7.1-bin /usr/local/lib/apache-zookeeper-3.7.1-bin && \
    mkdir /usr/local/lib/apache-zookeeper-3.7.1-bin/data
ENV ZOOKEEPER_HOME=/usr/local/lib/apache-zookeeper-3.7.1-bin
ENV PATH=$PATH:$ZOOKEEPER_HOME/bin

# Zookeeper env settings
COPY lib/apache-zookeeper-3.7.1-bin/conf/zoo.cfg $ZOOKEEPER_HOME/conf

# Hadoop-Zookeeper HA env settings
COPY lib/hadoop-3.3.4/etc/hadoop/core-site.xml $HADOOP_CONF_DIR
COPY lib/hadoop-3.3.4/etc/hadoop/hdfs-site.xml $HADOOP_CONF_DIR
COPY lib/hadoop-3.3.4/etc/hadoop/yarn-site.xml $HADOOP_CONF_DIR
COPY lib/hadoop-3.3.4/etc/hadoop/mapred-site.xml $HADOOP_CONF_DIR
COPY lib/hadoop-3.3.4/etc/hadoop/workers $HADOOP_CONF_DIR
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
COPY lib/apache-hive-3.1.3-bin/conf/hive-site.xml $HIVE_HOME/conf

RUN \
    yum install -y epel-release erlang rabbitmq-server

# Spark installation
RUN \
    wget https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz && \
    tar -xzf spark-3.3.1-bin-hadoop3.tgz && \
    mv spark-3.3.1-bin-hadoop3 /usr/local/lib/spark-3.3.1-bin-hadoop3
ENV SPARK_HOME=/usr/local/lib/spark-3.3.1-bin-hadoop3
ENV PATH=$PATH:$SPARK_HOME/bin

#Spark env settings
COPY lib/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
COPY lib/spark-3.3.1-bin-hadoop3/conf/spark-env.sh $SPARK_HOME/conf/spark-env.sh

# Airflow installation
ENV AIRFLOW_HOME=/usr/local/lib/airflow-2.2.5
ENV AIRFLOW_CONFIG=$AIRFLOW_HOME/conf/airflow.cfg
RUN \
    AIRFLOW_VERSION=2.2.5 && \
    PYTHON_VERSION=3.9 && \
    mkdir -p /usr/local/lib/airflow-${AIRFLOW_VERSION} && \
    export AIRFLOW_HOME=/usr/local/lib/airflow-${AIRFLOW_VERSION} && \
    mkdir $AIRFLOW_HOME/dags && \
    mkdir $AIRFLOW_HOME/logs && \
    mkdir $AIRFLOW_HOME/output && \
    mkdir $AIRFLOW_HOME/conf && \
    yum install python3-pip -y && \
    pip3 install --upgrade pip && \
    pip install apache-airflow

# Airflow env settings
COPY lib/airflow-2.2.5/conf/airflow.cfg $AIRFLOW_HOME/conf

ENTRYPOINT ["/bin/bash"]

