#!/bin/bash
ami-id="ami-0220d79f3f480ecf5"
sgroup="sg-0045e5825324c775b"

for Instan in $@
do
    instance_id=$(aws ec2 run-instances 
    --image-id ami-0220d79f3f480ecf5 
    --count 1 --instance-type t3.micro 
    --security-group-ids sg-0045e5825324c775b --tag-specifications 
    'ResourceType=instance,Tags=[{Key=Name,Value=$Instan}]'
    --output text)
    if [ $instance =! "frontend"]; then
        ip=$(aws ec2 describe-instances \
    --instance-ids i-01292ce7d88fc5494 \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)
    else
       ip=$(aws ec2 describe-instances \
    --instance-ids i-01292ce7d88fc5494 \
    --query 'Reservations[0].Instances[0].PrivateIpAddress' \
    --output text)
    echo "instance is created and public or prive ip is captured"
done