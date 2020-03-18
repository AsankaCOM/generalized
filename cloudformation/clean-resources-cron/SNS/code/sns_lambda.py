import json
import time
import botocore
import boto3
import logging
import os
from ec2_report import *
from rds_report import *
from ecs_report import *
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
def lambda_handler(event, context):
    try:
        client = boto3.client('sns')
        ec2 = get_ec2_report(event['EC2']['terminated'], event['EC2']['errors'], event['EC2']['running']) + "<< Logs: " + event['EC2']['logs'] + " >> \n\n"
        rds = get_rds_report(event['RDS_Instances']['terminated'], event['RDS_Instances']['errors'], event['RDS_Instances']['running'], 'Instances') + " << Logs: " + event['RDS_Instances']['logs'] + " >> \n\n"
        rds_c = get_rds_report(event['RDS_Clusters']['terminated'], event['RDS_Clusters']['errors'], event['RDS_Clusters']['running'], 'Clusters') + " << Logs: " + event['RDS_Clusters']['logs'] + " >> \n\n"
        ecs = ecs_report_terminated(event['ECS']['terminated']) + "<< Logs: " + event['ECS']['logs'] + " >> \n\n"
        msg = ec2 + rds + rds_c + ecs
        resus = client.publish(TopicArn=os.environ['topic_arn'], Message=msg, Subject='nClouds CleanUp Notification')
        response = {"statusCode": 200,"Message": "Succesfull"}
        logger.info('Cleaning >> Finish...')
        return response
    except botocore.exceptions.ClientError as e:
        logger.info('Cleaning >> Error while notifying: '+str(e.response['Error']['Message']))
        response = {"statusCode": 500,"Message": "Error"}
        return response


