#!/bin/bash

app_name="shipping"
software_name="maven"

source ./common.sh

CHECK_ROOT

for pkg in maven mysql; do
    install "$pkg"
done

CREATE_USER

APP_SETUP

cd /app 
mvn clean package 
VALIDATE $? "packaging"
mv target/shipping-1.0.jar shipping.jar 

VALIDATE $? " moving jar"

system_setup

TABLE_COUNT=$(mysql -h"$DB_HOST" -uroot  -pRoboShop@1 -Ddb -se "SHOW TABLES;" | wc -l)

if [ "$TABLE_COUNT" -gt 0 ]; then
    echo "✅ Database there "
else
    mysql -h $DB_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $DB_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql
    mysql -h $DB_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
fi

systemctl restart shipping

VALIDATE $? "restarting shipping"

PROCESS_TIME