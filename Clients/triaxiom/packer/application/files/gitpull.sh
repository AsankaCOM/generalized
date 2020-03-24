#!/bin/bash
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
username=`aws ssm get-parameter --name triaxiom_devops_username --with-decryption --output text --query Parameter.Value --region $EC2_REGION`
password=`aws ssm get-parameter --name triaxiom_devops_pass --with-decryption --output text --query Parameter.Value --region $EC2_REGION`
if [ -d "/home/onetick/client_data/.git" ]; then
  git -C /home/onetick/client_data pull https://$username:$password@gitlab.com/triaxiom.devops/triaxiom.devops.git 
else
  git clone https://$username:$password@gitlab.com/triaxiom.devops/triaxiom.devops.git /home/onetick/client_data
fi