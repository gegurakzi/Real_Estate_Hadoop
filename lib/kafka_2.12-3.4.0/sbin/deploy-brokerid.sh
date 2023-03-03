#!/usr/bin/env bash

sudo docker cp lib/kafka_2.12-3.4.0/config/server-master01.properties master01:/usr/local/lib/kafka_2.12-3.4.0/config/server.properties
sudo docker cp lib/kafka_2.12-3.4.0/config/server-master02.properties master02:/usr/local/lib/kafka_2.12-3.4.0/config/server.properties
sudo docker cp lib/kafka_2.12-3.4.0/config/server-slave01.properties slave01:/usr/local/lib/kafka_2.12-3.4.0/config/server.properties
sudo docker cp lib/kafka_2.12-3.4.0/config/server-slave02.properties slave02:/usr/local/lib/kafka_2.12-3.4.0/config/server.properties
sudo docker cp lib/kafka_2.12-3.4.0/config/server-slave03.properties slave03:/usr/local/lib/kafka_2.12-3.4.0/config/server.properties