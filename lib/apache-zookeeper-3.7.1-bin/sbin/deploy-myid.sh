#!/usr/bin/env bash

sudo docker exec master01 mkdir /usr/local/lib/apache-zookeeper-3.7.1-bin/data
sudo docker exec master01 echo 1 > /usr/local/lib/apache-zookeeper-3.7.1-bin/data/myid
sudo docker exec master02 echo 2 > /usr/local/lib/apache-zookeeper-3.7.1-bin/data/myid
sudo docker exec slave01 echo 3 > /usr/local/lib/apache-zookeeper-3.7.1-bin/data/myid