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
mkdir -p $folder
validate(){
    if [ $1 -eq 0 ]; then
        echo -e "$2...$r success $g" | tee -a $filename
    else 
        echo -e "$2 ... $r Failure $g " | tee -a $filename
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
dnf list installed nodejs
if [ $? -eq 0 ]; then
    dnf remove nodejs -y &>> $filename
fi
dnf module disable nodejs -y &>> $filename
validate $? "disableing nodejs"

dnf module enable nodejs:20 -y &>> $filename
validate $? "Enableing 20 nodejs"

dnf install nodejs -y  &>> $filename
validate $? "installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

mkdir -p /app 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

cd /app 
unzip /tmp/catalogue.zip
cd /app 
npm install 
cp catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload &>> $filename

systemctl enable catalogue &>> $filename
systemctl start catalogue &>> $filename

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>> $filename

mongosh --host mongodb.bongu.online </app/db/master-data.js

mongosh --host mongodb.bongu.online
