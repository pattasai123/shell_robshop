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

dnf install golang -y &>/dev/null
validate $? "installing golang"
id roboshop &>> $filename
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $filename
else
    echo -e "$r skipping already exist"
fi
mkdir -p /app 

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>> $filename

cd /app 
rm -rf /app/*
unzip /tmp/dispatch.zip &>> $filename 
cd /app 
go mod init dispatch &>> $filename
go get &>> $filename 
go build &>> $filename
cp $pwd/dispatch.service /etc/systemd/system/dispatch.service

systemctl daemon-reload &>> $filename
validate $? "daemon-reload"

systemctl enable dispatch  &>> $filename
validate $? "enable dispatch "

systemctl restart dispatch  &>> $filename
validate $? "start dispatch "