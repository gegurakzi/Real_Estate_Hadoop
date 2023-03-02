#!/usr/bin/env bash

sudo docker exec -u 0 master01 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 master01 /etc/init.d/ssh start
sudo docker exec -u 0 master01 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 master02 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 master02 /etc/init.d/ssh start
sudo docker exec -u 0 master02 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 slave01 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 slave01 /etc/init.d/ssh start
sudo docker exec -u 0 slave01 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 slave02 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 slave02 /etc/init.d/ssh start
sudo docker exec -u 0 slave02 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 slave03 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 slave03 /etc/init.d/ssh start
sudo docker exec -u 0 slave03 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 metastore apt update -y
sudo docker exec -u 0 metastore apt install openssh-server -y
sudo docker exec -u 0 metastore ssh-keygen -A
sudo docker exec -u 0 metastore /etc/init.d/ssh start
sudo docker exec -u 0 metastore ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa