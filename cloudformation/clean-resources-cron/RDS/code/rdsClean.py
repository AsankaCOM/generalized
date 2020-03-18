import json
import botocore
import boto3
import logging
import datetime
from helpers import *
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
#=================================================================================
#                               RDS CLEAN
#=================================================================================
def rds_cleaning(rds_dict):
    """
    Description:
    Args:
    Returns:
    """
    try:
        deleted_rds = []
        regions = get_regions()
        for region in regions['Regions']:
            rds = boto3.client('rds', region_name=region['RegionName'])
            rds_result = rds.describe_db_instances()
            logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
            for rdsi in rds_result['DBInstances']:
                if rdsi['DBInstanceStatus'] == 'available':
                    tags = rds.list_tags_for_resource(ResourceName=rdsi['DBInstanceArn'])
                    if len(tags['TagList'])>0:
                        check_terminate_rds(rds, rdsi, tags['TagList'], False, region['RegionName'], rds_dict)
                    else:
                        check_terminate_rds(rds, rdsi, None, True, region['RegionName'], rds_dict)
            logger.info('REGION >> ------------ END')
        return ""
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on check_terminate_rds, Error Listing RDS '+str(e.response['Error']['Message']))
        return []

def check_terminate_rds(rds_client, rds_instance, tags, terminate_now, region_name, dict):
    """
    Description:
    Args:
    Returns:
    """
    try:
        if terminate_now:
            logger.info('CleanUp >> RDS instance has no mandatory tags, terminating RDS instance:'+rds_instance['DBInstanceIdentifier'])
            delete_rds_instance(rds_client, rds_instance['DBInstanceIdentifier'], tags, region_name, dict)
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 1):
                logger.info('CleanUp >> RDS instance: '+ rds_instance['DBInstanceIdentifier']+ ' | Has mandatory tags... ')
                dict['running'].append({'id':rds_instance['DBInstanceIdentifier'],'region':region_name})
            else:
                logger.info('CleanUp >> RDS instance: '+ rds_instance['DBInstanceIdentifier']+ ' mising mandatory tags, will be terminated')
                delete_rds_instance(rds_client, rds_instance['DBInstanceIdentifier'], tags, region_name, dict)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on check_terminate_rds, Error terminating RDS instance: '+rds_instance['DBInstanceIdentifier']+': '+str(e.response['Error']['Message']))

def delete_rds_instance(rds_client, instance_id, tags, region_name, dict):
    try:
        if onTesting():
            if tags != None:
                if check_tags_exist(tags, get_testing_tags(), 1):
                    rds_client.delete_db_instance(DBInstanceIdentifier=instance_id, SkipFinalSnapshot=True)
                    dict['terminated'].append({'id':instance_id,'region':region_name})
        else:
            rds_client.delete_db_instance(DBInstanceIdentifier=instance_id, SkipFinalSnapshot=True)
            dict['terminated'].append({'id':instance_id,'region':region_name})
    except botocore.exceptions.ClientError as e:
        logger.info('Clean Up >> File: rdsClean.py, Error: '+str(e.response['Error']['Message'])+' when trying to delete: '+str(instance_id))
        dict['errors'].append({'id':instance_id,'region':region_name, 'msg':str(e.response['Error']['Message'])})

def rds_cluster_cleaning(rds_cl_dict):
    """
    Description:
    Args:
    Returns:
    """
    try:
        cluster_rds = []
        regions = get_regions()
        for region in regions['Regions']:
            rds = boto3.client('rds', region_name=region['RegionName'])
            rds_result = rds.describe_db_clusters()
            logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
            for rdsi in rds_result['DBClusters']:
                if rdsi['Status'] == 'available':
                    tags = rds.list_tags_for_resource(ResourceName=rdsi['DBClusterArn'])
                    if len(tags['TagList'])>0:
                        check_terminate_rds_cluster(rds, rdsi, tags['TagList'], False, region['RegionName'], rds_cl_dict)
                    else:
                        check_terminate_rds_cluster(rds, rdsi, None, True, region['RegionName'], rds_cl_dict)
            logger.info('REGION >> ------------ END')
        return ""
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on rds_cluster_cleaning, Error Listing RDS '+str(e.response['Error']['Message']))
        return []

def check_terminate_rds_cluster(rds_client, rds_cluster, tags, terminate_now, region_name, dict):
    """
    Description:
    Args:
    Returns:
    """
    try:
        if terminate_now:
            logger.info('CleanUp >> RDS instance has no mandatory tags, terminating RDS instance:'+rds_cluster['DBClusterIdentifier'])
            delete_rds_cluster(rds_client, rds_cluster['DBClusterIdentifier'], tags, region_name, dict)
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 1):
                logger.info('CleanUp >> RDS instance: '+ rds_cluster['DBClusterIdentifier']+ ' | Has mandatory tags... ')
                dict['running'].append({'id':rds_cluster['DBClusterIdentifier'],'region':region_name})
            else:
                logger.info('CleanUp >> RDS instance: '+ rds_cluster['DBClusterIdentifier']+ ' mising mandatory tags, will be terminated')
                delete_rds_cluster(rds_client, rds_cluster['DBClusterIdentifier'], tags, region_name, dict)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on check_terminate_rds_cluster, Error terminating RDS Cluster: '+rds_cluster['DBClusterIdentifier']+': '+str(e.response['Error']['Message']))
        reg[region_name][2]['errors'].append(rds_cluster['DBClusterIdentifier'])

def delete_rds_cluster(rds_client, instance_id, tags, region_name, dict):
    try:
        if onTesting():
            if tags != None:
                if check_tags_exist(tags, get_testing_tags(), 1):
                    rds_client.delete_db_cluster(DBClusterIdentifier=instance_id,SkipFinalSnapshot=True)
                    dict['terminated'].append({'id':instance_id,'region':region_name})
        else:
            rds_client.delete_db_cluster(DBClusterIdentifier=instance_id,SkipFinalSnapshot=True)
            dict['terminated'].append({'id':instance_id,'region':region_name})
    except botocore.exceptions.ClientError as e:
        logger.info('Clean Up >> File: rdsClean.py, Error: '+str(e.response['Error']['Message'])+' when trying to delete: '+str(instance_id))
        dict['errors'].append({'id':instance_id,'region':region_name, 'msg':str(e.response['Error']['Message'])})
#=================================================================================