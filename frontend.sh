#!/bin/bash

app_name="frontend"

source ./common.sh

CHECK_ROOT

NGINX_SETUP

rm -rf /usr/share/nginx/html/* 

VALIDATE $? " removed contents"

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip

VALIDATE $? " download $app_name"

cd /usr/share/nginx/html 
unzip /tmp/$app_name.zip
VALIDATE $? " unzp $app_name"

cp $CUR_DIR/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx 

PROCESS_TIME