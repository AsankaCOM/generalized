import json
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
        logger.info('Ejemplo de funcionamiento')
        logger.info('CleanUp >> ------------ ECS CLEANING ---------------------')
        ecsClean.ecs_cleaning()
        logger.info('CleanUp >> ------------ EKS CLEANING ---------------------')
        eksClean.eks_cleaning()
        logger.info('CleanUp >> ------------ RDS CLEANING ---------------------')
        rdsClean.rds_cluster_cleaning()
        rdsClean.rds_cleaning()
        logger.info('CleanUp >> ------------ EC2 CLEANING ---------------------')
        ec2Clean.ec2_cleaning()
        response = {"statusCode": 200,"Message": "Succesful"}
        return response
    except Exception as e:
        logger.info('CleanUp >> ERROR '+str(e))
        response = {"statusCode": 500,"Message": str(e)}