#!/bin/bash

app_name="mysql"
# install_software="mysql-server"
software_name="mysqld"

source ./common.sh

CHECK_ROOT

install "mysql-server"
software_start

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "set pass for mysql "

PROCESS_TIME