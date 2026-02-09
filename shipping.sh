#!/bin/bash

user=$(id -u)

if [ $user -ne 0 ]; then
    echo "ERROR:: please run this with root access"
    exit 1
fi
r="\e[32m"
g="\e[33m"
folder="/var/log/shell_roboshop"
file=$(echo $0| cut -d "." -f1)
filename="$folder/$file.log"
pwd=$PWD
mkdir -p $folder
validate(){
    if [ $1 -eq 0 ]; then
        echo -e "$2... $r success $g" | tee -a $filename
    else 
        echo -e "$2 ... $r Failure $g " | tee -a $filename
        exit 1
    fi
}


dnf install maven -y  &>> $filename
validate $? "installing maven"
id roboshop &>> $filename
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $filename
else
    echo -e "$r skipping already exist"
fi
mkdir -p /app 

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $filename

cd /app 
rm -rf /app/*
unzip /tmp/shipping.zip &>> $filename
cd /app 
mvn clean package &>> $filename
mv target/shipping-1.0.jar shipping.jar &>> $filename
cp $pwd/shipping.service /etc/systemd/system/shipping.service
systemctl daemon-reload &>> $filename
validate $? "daemon-reload"

systemctl enable shipping &>> $filename
validate $? "enable shipping"

systemctl restart shipping &>> $filename
validate $? "start shipping"

dnf install mysql -y &>> $filename
validate $? "installing mysql"

mysql -h mysql.bongu.online -uroot -pRoboShop@1 "use mysql"
if [ $? -ne 0 ]; then
    mysql -h mysql.bongu.online -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h mysql.bongu.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h mysql.bongu.online -uroot -pRoboShop@1 < /app/db/master-data.sql
else
    echo -e "$r we are skipping because shipping data is already there"
fi
systemctl restart shipping &>> $filename
validate $? "restarting mysql"