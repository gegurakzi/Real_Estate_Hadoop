FROM dorowu/ubuntu-desktop-lxde-vnc

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
COPY ../lib/hadoop-3.3.4/etc/hadoop/core-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/hdfs-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/yarn-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/mapred-site.xml $HADOOP_CONF_DIR
COPY ../lib/hadoop-3.3.4/etc/hadoop/workers $HADOOP_CONF_DIR

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

# Jupyter Lab Installation
RUN \
    pip install pysqlite3 && \
    pip install jupyterlab

# Jupyter Lab env settings
RUN \
    pip install findspark && \
    mkdir -p /home/notebook