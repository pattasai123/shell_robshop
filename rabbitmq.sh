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
        echo -e "$2...$r success $g" | tee -a $filename
    else 
        echo -e "$2 ... $r Failure $g " | tee -a $filename
        exit 1
    fi
}

cp $pwd/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
dnf install rabbitmq-server -y &>> $filename
validate $? "Installing rabbit-server"
systemctl enable rabbitmq-server &>> $filename
validate $? "Enableing rabbit-server"
systemctl start rabbitmq-server &>> $filename
validate $? "Starting rabbit-server"
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"