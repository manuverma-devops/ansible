#!/bin/bash

sudo yum install gettext -y &>/dev/null
COMPONENT=$1


if [ -z "${COMPONENT}" ]; then
       echo "Need input of the component name or all to create all the instances"
       exit 1
fi

if [ "${COMPONENT}" == all ];then

   for COMPONENT in  

fi

STATE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" --query 'Reservations[*].Instances[*].State.Name' --output text)

if [ "${STATE}" != "running" ]; then
    aws ec2 run-instances --launch-template LaunchTemplateId=lt-0717144b48f3f7db5 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" &>/dev/null
    sleep 10
fi

IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)

export IPADDRESS
export COMPONENT

envsubst < record.json > /tmp/${COMPONENT}.json
cat record.json
aws route53 change-resource-record-sets --hosted-zone-id Z0389593AKK6AGHKDTF2 --change-batch file:///tmp/${COMPONENT}.json

cat /tmp/${COMPONENT}.json

#This is to update the roboshop ansible inventory
sed -i -e "/${COMPONENT}/ d" ~/inventory
PUBLICIPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
echo "${PUBLICIPADDRESS}  APP=${COMPONENT}" >> ~/inventory
