#!/bin/bash

app_name="catalogue"
source ./common.sh

CHECK_ROOT

CREATE_USER

APP_SETUP

NODE_SETUP

MONGO_REPO

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "install mongo client"

INDEX=$(mongosh $MONGO_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -lt 0 ]; then
    mongosh --host $MONGO_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

system_setup

PROCESS_TIME




