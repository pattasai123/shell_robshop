#!/bin/bash
ami_id="ami-0220d79f3f480ecf5"
sgroup="sg-0045e5825324c775b"

for Instan in $@
do
    instance_id=$(aws ec2 run-instances \
      --image-id $ami_id \
      --count 1 \
      --instance-type t3.micro \
      --security-group-ids $sgroup \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$Instan}]" \
      --query 'Instances[0].InstanceId' \
      --output text
    )

    if [ "$Instan" != "frontend" ]; then
        ip=$(aws ec2 describe-instances \
          --instance-ids $instance_id \
          --query 'Reservations[0].Instances[0].PublicIpAddress' \
          --output text)
    else
        ip=$(aws ec2 describe-instances \
          --instance-ids $instance_id \
          --query 'Reservations[0].Instances[0].PrivateIpAddress' \
          --output text)
    fi

    echo "Instance $Instan created with IP: $ip"

done
