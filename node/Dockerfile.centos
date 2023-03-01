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
    yum install gcc make openssl-devel bzip2-devel libffi-devel -y && \
    yum install mysql-devel sqlite-devel -y && \
    yum install build-essential gcc-c++ python39-devel cyrus-sasl cyrus-sasl-devel -y

# Java installation
RUN \
    mkdir -p /usr/lib/jvm && \
    wget https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u342-b07/OpenJDK8U-jdk_x64_linux_8u342b07.tar.gz && \
    tar -xvf OpenJDK8U-jdk_x64_linux_8u342b07.tar.gz && \
    mv openjdk-8u342-b07 /usr/lib/jvm/java-1.8.0-openjdk-8u342-b07 && \
    mkdir -p $JAVA_HOME/lib/ext
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-8u342-b07
ENV PATH=$PATH:$JAVA_HOME/bin

# Python3 installation
RUN \
    wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tgz && \
    tar -xvf Python-3.9.5.tgz && \
    mv Python-3.9.5 /usr/local/lib/python-3.9.5 && \
    cd /usr/local/lib/python-3.9.5 && \
    ./configure --enable-optimizations && \
    yum install make -y && \
    make altinstall && \
    ln -Tfs /usr/local/bin/python3.9 /usr/bin/python3 && \
    python3 -m pip install --upgrade pip && \
    pip install --upgrade setuptools && \
    cd /

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
          export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-8u342-b07 \n\
          export CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/lib/ext:$JAVA_HOME/jre/lib:$JAVA_HOME/jre/lib/ext \n\
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
    yum install -y epel-release && \
    wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm && \
    rpm -Uvh erlang-solutions-1.0-1.noarch.rpm && \
    yum install erlang logrotate socat -y && \
    rpm -Uvh https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.9.12/rabbitmq-server-3.9.12-1.el7.noarch.rpm

# Airflow installation
RUN \
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
    yum update -y && \
    pip install pandas && \
    pip install apache-airflow-providers-apache-hive

ENTRYPOINT ["/bin/bash"]

