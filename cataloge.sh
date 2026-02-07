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


dnf list installed nodejs &>/dev/null

if [ $? -eq 0 ]; then
    dnf remove nodejs -y &>> $filename
fi
dnf module disable nodejs -y &>> $filename
validate $? "disableing nodejs"

dnf module enable nodejs:20 -y &>> $filename
validate $? "Enableing 20 nodejs"

dnf install nodejs -y  &>/dev/null
validate $? "installing nodejs"
id roboshop &>> $filename
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $filename
else
    echo -e "$r skipping already exist"
fi
mkdir -p /app 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $filename

cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip &>> $filename
npm install &>> $filename
cp $pwd/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload &>> $filename
validate $? "daemon-reload"

systemctl enable catalogue &>> $filename
validate $? "enable catalogue"


cp $pwd/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>> $filename

index=$(mongosh mongodb.bongu.online --quiet --eval "db.getMongo().getDBnames().indexOf('catalogue')")
if [ $? -le 0 ];then 
    mongosh --host mongodb.bongu.online </app/db/master-data.js &>> $filename
else
    echo -e "$g we are skiping already exit "
fi
systemctl restart catalogue &>> $filename
validate $? "start catalogue"