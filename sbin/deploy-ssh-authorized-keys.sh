#!/usr/bin/env bash

m1=$(sudo docker exec master01 cat /root/.ssh/id_rsa.pub)
m2=$(sudo docker exec master02 cat /root/.ssh/id_rsa.pub)
s1=$(sudo docker exec slave01 cat /root/.ssh/id_rsa.pub)
s2=$(sudo docker exec slave02 cat /root/.ssh/id_rsa.pub)
s3=$(sudo docker exec slave03 cat /root/.ssh/id_rsa.pub)
ms=$(sudo docker exec metastore cat /root/.ssh/id_rsa.pub)

echo $m1
echo $m2
echo $s1
echo $s2
echo $s3
echo $ms

auth_keys=${m1}$'\n'${m2}$'\n'${s1}$'\n'${s2}$'\n'${s3}$'\n'${ms}$'\n'

touch authorized_keys
echo $m1 >> authorized_keys
echo $m2 >> authorized_keys
echo $s1 >> authorized_keys
echo $s2 >> authorized_keys
echo $s3 >> authorized_keys
echo $ms >> authorized_keys

cat authorized_keys

sudo docker cp authorized_keys master01:/root/.ssh/authorized_keys
sudo docker cp authorized_keys master02:/root/.ssh/authorized_keys
sudo docker cp authorized_keys slave01:/root/.ssh/authorized_keys
sudo docker cp authorized_keys slave02:/root/.ssh/authorized_keys
sudo docker cp authorized_keys slave03:/root/.ssh/authorized_keys
sudo docker cp authorized_keys metastore:/root/.ssh/authorized_keys

rm authorized_keys