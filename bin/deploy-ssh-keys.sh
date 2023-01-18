#!/usr/bin/env bash

sudo docker exec -u 0 master01 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 master01 /usr/sbin/sshd
sudo docker exec -u 0 master01 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 master02 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 master02 /usr/sbin/sshd
sudo docker exec -u 0 master02 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 slave01 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 slave01 /usr/sbin/sshd
sudo docker exec -u 0 slave01 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 slave02 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 slave02 /usr/sbin/sshd
sudo docker exec -u 0 slave02 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 slave03 /usr/sbin/sshd-keygen -A
sudo docker exec -u 0 slave03 /usr/sbin/sshd
sudo docker exec -u 0 slave03 ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa

sudo docker exec -u 0 metastore ssh-keygen -A
sudo docker exec -u 0 metastore service ssh start
sudo docker exec -u 0 metastore ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa