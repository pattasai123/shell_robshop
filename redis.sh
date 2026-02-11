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
dnf module disable redis -y &>> $filename
validate $? "disableing redis"
dnf module enable redis:7 -y &>> $filename
validate $? "enable redis"
dnf install redis -y &>> $filename
validate $? "Installing redis"
sed -i -e "s/127.0.0.1/0.0.0.0/g" -e "/protected-mode/ c protected-mode no" /etc/redis/redis.conf
systemctl enable redis &>> $filename
validate $? "Enableing redis"
systemctl start redis  &>> $filename
validate $? "Starting redis"

