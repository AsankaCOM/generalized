#!/bin/bash
if [ -d "/home/onetick/client_data/.git" ]; then
  git -C /home/onetick/client_data pull https://`aws ssm get-parameter --name triaxiom_devops_username --with-decryption --output text --query Parameter.Value --region us-west-2`:`aws ssm get-parameter --name triaxiom_devops_pass --with-decryption --output text --query Parameter.Value --region us-west-2`@gitlab.com/triaxiom.devops/triaxiom.devops.git 
else
  git clone https://`aws ssm get-parameter --name triaxiom_devops_username --with-decryption --output text --query Parameter.Value --region us-west-2`:`aws ssm get-parameter --name triaxiom_devops_pass --with-decryption --output text --query Parameter.Value --region us-west-2`@gitlab.com/triaxiom.devops/triaxiom.devops.git /home/onetick/client_data
fi;