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

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $filename

cd /app 
rm -rf /app/*
unzip /tmp/cart.zip &>> $filename
npm install &>> $filename
cp $pwd/cart.service /etc/systemd/system/cart.service

systemctl daemon-reload &>> $filename
validate $? "daemon-reload"

systemctl enable catalogue &>> $filename
validate $? "enable cart"

systemctl restart catalogue &>> $filename
validate $? "start cart"