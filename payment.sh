#!/bin/bash

app_name="payment"
source ./common.sh

CHECK_ROOT

dnf install python3 gcc python3-devel -y
VALIDATE $? "install python"

CREATE_USER

APP_SETUP

cd /app 
pip3 install -r requirements.txt &>>LOG_FILE
VALIDATE $? "install dependecies"

system_setup

PROCESS_TIME