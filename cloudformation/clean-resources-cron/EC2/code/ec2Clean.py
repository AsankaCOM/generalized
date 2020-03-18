import json
import botocore
import boto3
import logging
import datetime
from helpers import *
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def ec2_cleaning(ec2_dict):
    """
    Description:
        Starts the cleaning Process
    Args:
        No arguments
    Returns:
        No returns
    """
    try:
        regions = get_regions()
        for region in regions['Regions']:
            ec2_r = boto3.client('ec2', region_name=region['RegionName'])
            instances = ec2_r.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values':['pending', 'running','stopped']}])
            logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
            for reservations in instances['Reservations']:
                for ins in reservations['Instances']:
                    if 'Tags' in ins:
                        check_terminate_ec2(ec2_r, ins, ins['Tags'], False, region['RegionName'], ec2_dict)
                    else:
                        check_terminate_ec2(ec2_r, ins, None, True, region['RegionName'], ec2_dict)
            logger.info('REGION >> ------------ END')
        return ""
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: ec2Clean.py on ec2Cleaning,  Error Listing EC2 '+str(e.response['Error']['Message']))
        return []

def check_terminate_ec2(ec2_client, instance_id, tags, terminate_now, region_name, dict):
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
            delete_ec2(ec2_client, instance_id['InstanceId'], tags, region_name, dict)
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 1):
                logger.info('CleanUp >> EC2 instance: '+ instance_id['InstanceId']+ ' | Has mandatory tags... ')
                dict['running'].append({'id':instance_id['InstanceId'], 'region':region_name})
            else:
                logger.info('CleanUp >> EC2 instance: '+instance_id['InstanceId']+ ' missing mandatory tags, will be terminated')
                delete_ec2(ec2_client, instance_id['InstanceId'], tags, region_name, dict)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: ec2Clean.py on check_terminate_ec2, Error Terminating EC2 '+str(instance_id['InstanceId'])+': '+str(e.response['Error']['Message']))

def delete_ec2(ec2_client, instance_id, tags, region_name, dict):
    try:
        if onTesting():
            if tags != None:
                if check_tags_exist(tags, get_testing_tags(), 1):
                    ec2_client.terminate_instances(InstanceIds=[instance_id])
                    dict['terminated'].append({'id':instance_id, 'region':region_name})
        else:
            # real termination
            ec2_client.terminate_instances(InstanceIds=[instance_id])
            dict['terminated'].append({'id':instance_id, 'region':region_name})
    except botocore.exceptions.ClientError as e:
        logger.info('Clean Up >> File: ec2Clean.py, Error: '+str(e.response['Error']['Message'])+' when trying to delete: '+str(instance_id))
        dict['errors'].append({'id':instance_id, 'region':region_name, 'msg':str(e.response['Error']['Message'])})
