#!/usr/bin/env bash

sudo docker exec master01 echo 1 > $ZOOKEEPER_HOME/data/myid
sudo docker exec master02 echo 2 > $ZOOKEEPER_HOME/data/myid
sudo docker exec slave01 echo 3 > $ZOOKEEPER_HOME/data/myid