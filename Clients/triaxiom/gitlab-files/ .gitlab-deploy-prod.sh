#!/bin/bash
BASTION_IP=$PROD_BASTION_IP
APPLICATION_IP=$PROD_APPLICATION_IP
ssh -o StrictHostKeyChecking=no ec2-user@${BASTION_IP} -A ssh -o StrictHostKeyChecking=no ${APPLICATION_IP} "sudo bash /home/onetick/gitpull.sh"
ssh -o StrictHostKeyChecking=no ec2-user@${BASTION_IP} -A ssh -o StrictHostKeyChecking=no ${APPLICATION_IP} "sudo chown -R onetick:onetick /home/onetick/client_data"