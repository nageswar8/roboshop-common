#!/bin/bash

app_name="rabbit"
install_software="rabbitmq-server"
software_name="rabbitmq-server"
source ./common.sh

CHECK_ROOT

RABBIT_REPO

install

rabbitmqctl add_user roboshop roboshop123
VALIDATE $? "add user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

VALIDATE $? "set permission"

PROCESS_TIME