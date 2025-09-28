#!/bin/bash

app_name="mongo"
source ./common.sh

CHECK_ROOT

MONGO_REPO
MONGO_SERVER
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Replace global"

systemctl restart mongod

PROCESS_TIME