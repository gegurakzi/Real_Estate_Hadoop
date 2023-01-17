# Hadoop cluster deployment

```
sudo docker build -t cluster:node .
```

```
docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=root -d mysql:8.0-debian
sudo docker exec -it metastore apt update -y
sudo docker exec -it metastore apt install ssh openssh-server -y
sudo docker exec -it metastore service start
sudo docker exec -it metastore mysql -p
sudo docker exec -it metastore /bin/bash
CREATE DATABASE hive;
CREATE DATABASE airflow;
CREATE USER hive;
CREATE USER airflow;
GRANT ALL PRIVILEGES ON hive.* to 'hive'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON airflow.* to 'airflow'@'%' WITH GRANT OPTION;
```
