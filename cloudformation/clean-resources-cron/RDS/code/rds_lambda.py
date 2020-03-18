import json
import os
import botocore
import boto3
import logging
import datetime
import rdsClean
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        response = {}
        Message = ""
        ###############################
        logger.info('CleanUp >> ------------ RDS CLEANING ---------------------')
        rds_i_dict = {
            "terminated":[],
            "running":[],
            "errors":[],
            "logs": 'https://console.aws.amazon.com/cloudwatch/home?region='+os.environ['AWS_REGION']+'#logEventViewer:group='+context.log_group_name+';stream='+context.log_stream_name
        }
        rdsClean.rds_cleaning(rds_i_dict)
        ###############################
        ###############################
        logger.info('CleanUp >> ------------ RDS CLUSTER CLEANING ---------------------')
        rds_cl_dict = {
            "terminated":[],
            "running":[],
            "errors":[],
            "logs": 'https://console.aws.amazon.com/cloudwatch/home?region='+os.environ['AWS_REGION']+'#logEventViewer:group='+context.log_group_name+';stream='+context.log_stream_name
        }
        rdsClean.rds_cluster_cleaning(rds_cl_dict)
        ###############################
        response = {"statusCode": 200,"Message": "Succesful"}
        response['RDS_Instances'] = rds_i_dict
        response['RDS_Clusters'] = rds_cl_dict
        response['EC2'] = event['EC2']
        response['ECS'] = event['ECS']
        return response
    except Exception as e:
        logger.info('CleanUp >> ERROR '+str(e))
        response = {"statusCode": 500,"Message": str(e)}
        return response