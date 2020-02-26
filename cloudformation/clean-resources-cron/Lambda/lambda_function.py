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
        ###############################
        logger.info('CleanUp >> ------------ ECS CLEANING ---------------------')
        ecs_dict = {'Regions':[]}
        Message += ecsClean.ecs_cleaning(ecs_dict)+"\n"
        logger.info(ecs_dict)
        ###############################
        logger.info('CleanUp >> ------------ EKS CLEANING ---------------------')
        eks_dict = {'Regions':[]}
        Message += eksClean.eks_cleaning(eks_dict)+"\n"
        logger.info(eks_dict)
        ###############################
        logger.info('CleanUp >> ------------ RDS CLEANING ---------------------')
        rds_dict = {'Regions':[]}
        Message += rdsClean.rds_cluster_cleaning(rds_dict)
        logger.info(rds_dict)
        rds_cl_dict = {'Regions':[]}
        Message += rdsClean.rds_cleaning(rds_cl_dict)+"\n"
        logger.info(rds_cl_dict)
        ###############################
        logger.info('CleanUp >> ------------ EC2 CLEANING ---------------------')
        ec2_dict = {'Regions':[]}
        Message += ec2Clean.ec2_cleaning(ec2_dict)+"\n"
        logger.info(ec2_dict)
        ###############################
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