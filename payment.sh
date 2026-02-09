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

dnf install python3 gcc python3-devel -y &>/dev/null
validate $? "installing python3"
id roboshop &>> $filename
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $filename
else
    echo -e "$r skipping already exist"
fi
mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $filename

cd /app 
rm -rf /app/*
unzip /tmp/payment.zip &>> $filename
cd /app 
pip3 install -r requirements.txt&>> $filename
cp $pwd/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload &>> $filename
validate $? "daemon-reload"

systemctl enable payment &>> $filename
validate $? "enable payment"

systemctl restart payment &>> $filename
validate $? "start payment"