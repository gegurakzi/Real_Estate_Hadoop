# Hadoop cluster deployment

## 1. Dockerfile 빌드
```
sudo docker build -t cluster:node .
```

## 2. docker-compose 실행
```
sudo docker-compose up -d
```

## 3. 컨테이너 간 SSH 키 공유
```
sudo bash sbin/deploy-ssh-keys.sh
sudo bash sbin/deploy-ssh-authorized-keys.sh
```
* 기본적으로 SSH 접근하는 사용자는 root이기 때문에 sudo 권한으로 스크립트 실행

## 4. MySQL metastore 컨테이너에 hive, airflow metastore 추가
```
sudo docker exec -it metastore mysql -p
CREATE DATABASE hive;
CREATE DATABASE airflow;
CREATE USER hive;
CREATE USER airflow;
GRANT ALL PRIVILEGES ON hive.* to 'hive'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON airflow.* to 'airflow'@'%' WITH GRANT OPTION;
quit;
```

```
[master01 ~]$ zkServer.sh start
[master02 ~]$ zkServer.sh start
[slave01 ~]$ zkServer.sh start
[master01 ~]$ hdfs zkfc -formatZK
[master01 ~]$ hdfs --daemon start journalnode
[master02 ~]$ hdfs --daemon start journalnode
[slave01 ~]$ hdfs --daemon start journalnode
[master01 ~]$ hdfs namenode -format
[master02 ~]$ hdfs namenode -bootstrapStandby
[master01 ~]$ start-dfs.sh
[master01 ~]$ start-yarn.sh
[master01 ~]$ mapred --daemon start historyserver
[master02 ~]$ mapred --daemon start historyserver
```