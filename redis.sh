#!/bin/bash

app_name="redis"
# install_software="redis"
software_name="redis"
source ./common.sh

CHECK_ROOT

dnf module disable redis -y

VALIDATE $? "disable redis"
dnf module enable redis:7 -y

VALIDATE $? "enable redis"

install "redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

software_start

PROCESS_TIME

