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


dnf list installed nginx &>/dev/null

if [ $? -eq 0 ]; then
    dnf remove nginx -y &>> $filename
fi
dnf module disable nginx -y &>> $filename
validate $? "disableing nginx"

dnf module enable nginx:1.24 -y &>> $filename
validate $? "Enableing 20 nginx"

dnf install nginx -y &>> $filename
validate $? "installing nginx"
systemctl enable nginx &>> $filename
validate $? "enable nginx"
systemctl start nginx &>> $filename
validate $? "start nginx"
rm -rf /usr/share/nginx/html/* &>> $filename
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $filename
cd /usr/share/nginx/html &>> $filename
unzip /tmp/frontend.zip &>> $filename

cp pwd/nginx.conf /etc/nginx/nginx.conf

systemctl restart nginx  &>> $filename
validate $? "restart nginx"
