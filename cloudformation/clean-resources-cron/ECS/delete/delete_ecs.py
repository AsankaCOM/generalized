import json
import os
import botocore
import boto3
import logging
import datetime
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        response = {}
        Message = ""
        # ###############################
        logger.info('CleanUp >> ------------ ECS DELETION ---------------------')
        arn = event['arn']
        region = event['region']
        name = event['name']
        message = ""
        if delete_cluster(arn, name, region, message):
             response = {"statusCode": 200,"Message": "Succesful", "arn": arn, "region": region, "name": name}
             return response
        # ###############################s
        response = {"statusCode": 500,"Message": message, "arn": arn, "region":region, "name": name}
        return response
    except Exception as e:
        logger.info('CleanUp >> ERROR '+str(e))
        response = {"statusCode": 500,"Message": str(e)}
        return response

def delete_cluster(arn, name, region, message):
    if delete_services(arn, name, region, message):
        if deregister_instances(arn, name, region, message):
            return True
        return False
    else:
        return False

def delete_services(arn, name, region, message):
    try:
        ecs = boto3.client('ecs', region_name=region)
        services = ecs.list_services(cluster=arn)
        for s in services['serviceArns']:
            ecs.update_service(cluster=arn, service=s, desiredCount=0)
            ecs.delete_service(cluster=arn, service=s, force=True)
            waiter = ecs.get_waiter('services_inactive')
            waiter.wait(cluster=arn,services=[s])
        return True
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating ECS Cluster Services: '+name+': '+str(e.response['Error']['Message']))
        message = str(e.response['Error']['Message'])
        return False

def deregister_instances(arn, name, region, message):
    try:
        ecs_client = boto3.client('ecs', region_name=region)
        instances = ecs_client.list_container_instances(cluster=arn)
        for i in instances['containerInstanceArns']:
            ecs_client.deregister_container_instance(cluster=arn,containerInstance=i,force=True)
            logger.info('CleanUp >> deregistering container instance: '+str(i))
        ecs_client.delete_cluster(cluster=arn)
        return True
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating ECS Cluster Services: '+name+': '+str(e.response['Error']['Message']))
        message = str(e.response['Error']['Message'])
        return False
