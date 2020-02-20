import json
import os
import botocore
import boto3
import logging
import datetime
import ec2Clean
import rdsClean
import eksClean
import ecsClean
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        response = {}
        Message = ""
        logger.info('CleanUp >> ------------ ECS CLEANING ---------------------')
        Message += ecsClean.ecs_cleaning()+"\n"
        logger.info('CleanUp >> ------------ EKS CLEANING ---------------------')
        Message += eksClean.eks_cleaning()+"\n"
        logger.info('CleanUp >> ------------ RDS CLEANING ---------------------')
        Message += rdsClean.rds_cluster_cleaning()
        Message += rdsClean.rds_cleaning()+"\n"
        logger.info('CleanUp >> ------------ EC2 CLEANING ---------------------')
        Message += ec2Clean.ec2_cleaning()+"\n"
        send_notifiction(os.environ['AWS_REGION'], context.log_group_name, context.log_stream_name, Message)
        response = {"statusCode": 200,"Message": "Succesful"}
        return response
    except Exception as e:
        logger.info('CleanUp >> ERROR '+str(e))
        response = {"statusCode": 500,"Message": str(e)}

def send_notifiction(Region, GroupName, StreamName, message):
    try:
        Greetings = " Clean up nClouds account report:\n"
        client = boto3.client('sns')
        url = 'https://console.aws.amazon.com/cloudwatch/home?region='+Region+'#logEventViewer:group='+GroupName+';stream='+StreamName
        logs = "Execution Logs: \n"+url
        resus = client.publish(TopicArn=str(os.environ['topic_arn']), Message=Greetings+message+logs, Subject='Clean Notification')
        logger.info('CleanUp >> Notification Sended')
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error while trying to send notification: '+str(e.response['Error']['Message']))