import json
import botocore
import boto3
import logging
import datetime
from helpers import *
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def ec2_cleaning():
    """
    Description:
        Starts the cleaning Process
    Args:
        No arguments
    Returns:
        No returns
    """
    try:
        deleted_ec2 = []
        regions = get_regions()
        for region in regions['Regions']:
            ec2_r = boto3.client('ec2', region_name=region['RegionName'])
            instances = ec2_r.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values':['pending', 'running','stopped']}])
            logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
            for reservations in instances['Reservations']:
                for ins in reservations['Instances']:
                    if 'Tags' in ins:
                        check_terminate_ec2(ec2_r, ins, ins['Tags'], False, deleted_ec2, region['RegionName'])
                    else:
                        check_terminate_ec2(ec2_r, ins, None, True, deleted_ec2, region['RegionName'])
            logger.info('REGION >> ------------ END')
        return get_ec2_report(deleted_ec2)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: ec2Clean.py on ec2Cleaning,  Error Listing EC2 '+str(e.response['Error']['Message']))
        return []

def check_terminate_ec2(ec2_client, instance_id, tags, terminate_now, deleted_ec2, region_name):
    """
    Description:
        Gets and looks for all instances that are running on the regions
    Args:
        ec2_client (boto3 ec2 client): boto 3 client to stop instances
        instance_id (dict): dictionary containing ec2 instance information
        tags (dict): dictonary of tags that the instance has
        terminate_now (bool): indicates if the instances should be evaluated or terminated
    Returns:
        No Returns
    """
    try:
        if terminate_now:
            logger.info('CleanUp >> ec2 has no tags mandatory tags, terminating ec2 instance: '+instance_id['InstanceId'])
            ec2_client.stop_instances(InstanceIds=[instance_id['InstanceId']])
            #ec2_client.terminate_instances(InstanceIds=[instance_id['InstanceId']])
            deleted_ec2.append(instance_id['InstanceId']+' on Region '+str(region_name))
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 1):
                logger.info('CleanUp >> EC2 instance: '+ instance_id['InstanceId']+ ' | Has mandatory tags... ')
            else:
                logger.info('CleanUp >> EC2 instance: '+instance_id['InstanceId']+ ' missing mandatory tags, will be terminated')
                ec2_client.stop_instances(InstanceIds=[instance_id['InstanceId']])
                #ec2_client.terminate_instances(InstanceIds=[instance_id['InstanceId']])
                deleted_ec2.append(instance_id['InstanceId']+' on Region '+str(region_name))
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: ec2Clean.py on check_terminate_ec2, Error Terminating EC2 '+str(instance_id['InstanceId'])+': '+str(e.response['Error']['Message']))

def get_ec2_report(deleted_ec2):
    try:
        r = " EC2 Instances terminated: \n"
        for i in deleted_ec2:
            r += "  * Instance ID: "+str(i)+" \n"
        r += "-----------------------------------------------\n"
        return r
    except Exception as e:
        logger.info('Clean Up >> File: ec2Clean.py on get_ec2_reporte, Error: '+str(e))