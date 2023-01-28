#!/usr/bin/env bash

sudo docker exec -it master01 sh -c 'echo 1 > /usr/local/lib/apache-zookeeper-3.7.1-bin/data/myid'
sudo docker exec -it master02 sh -c 'echo 2 > /usr/local/lib/apache-zookeeper-3.7.1-bin/data/myid'
sudo docker exec -it slave01 sh -c 'echo 3 > /usr/local/lib/apache-zookeeper-3.7.1-bin/data/myid'