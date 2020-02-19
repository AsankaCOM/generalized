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
def rds_cleaning():
    """
    Description:
    Args:
    Returns:
    """
    try:
        regions = get_regions()
        for region in regions['Regions']:
            rds = boto3.client('rds', region_name=region['RegionName'])
            rds_result = rds.describe_db_instances()
            logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
            for rdsi in rds_result['DBInstances']:
                if rdsi['DBInstanceStatus'] == 'available':
                    tags = rds.list_tags_for_resource(ResourceName=rdsi['DBInstanceArn'])
                    if len(tags['TagList'])>0:
                        check_terminate_rds(rds, rdsi, tags['TagList'], False)
                    else:
                        check_terminate_rds(rds, rdsi, None, True)
            logger.info('REGION >> ------------ END')
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on check_terminate_rds, Error Listing RDS '+str(e.response['Error']['Message']))

def check_terminate_rds(rds_client, rds_instance, tags, terminate_now):
    """
    Description:
    Args:
    Returns:
    """
    try:
        if terminate_now:
            logger.info('CleanUp >> RDS instance has no mandatory tags, terminating RDS instance:'+rds_instance['DBInstanceIdentifier'])
            #rds_client.stop_db_instance(DBInstanceIdentifier=rds_instance['DBInstanceIdentifier'])
            #rds_client.delete_db_instance(DBInstanceIdentifier=rds_instance['DBInstanceIdentifier'], SkipFinalSnapshot=True)
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 1):
                logger.info('CleanUp >> RDS instance: '+ rds_instance['DBInstanceIdentifier']+ ' | Has mandatory tags... ')
            else:
                logger.info('CleanUp >> RDS instance: '+ rds_instance['DBInstanceIdentifier']+ ' mising mandatory tags, will be terminated')
                #rds_client.stop_db_instance(DBInstanceIdentifier=rds_instance['DBInstanceIdentifier'])
                #rds_client.delete_db_instance(DBInstanceIdentifier=rds_instance['DBInstanceIdentifier'], SkipFinalSnapshot=True)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on check_terminate_rds, Error terminating RDS instance: '+rds_instance['DBInstanceIdentifier']+': '+str(e.response['Error']['Message']))

def rds_cluster_cleaning():
    """
    Description:
    Args:
    Returns:
    """
    try:
        regions = get_regions()
        for region in regions['Regions']:
            rds = boto3.client('rds', region_name=region['RegionName'])
            rds_result = rds.describe_db_clusters()
            logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
            for rdsi in rds_result['DBClusters']:
                if rdsi['Status'] == 'available':
                    tags = rds.list_tags_for_resource(ResourceName=rdsi['DBClusterArn'])
                    if len(tags['TagList'])>0:
                        check_terminate_rds_cluster(rds, rdsi, tags['TagList'], False)
                    else:
                        check_terminate_rds_cluster(rds, rdsi, None, True)
            logger.info('REGION >> ------------ END')
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on rds_cluster_cleaning, Error Listing RDS '+str(e.response['Error']['Message']))

def check_terminate_rds_cluster(rds_client, rds_cluster, tags, terminate_now):
    """
    Description:
    Args:
    Returns:
    """
    try:
        if terminate_now:
            logger.info('CleanUp >> RDS instance has no mandatory tags, terminating RDS instance:'+rds_cluster['DBClusterIdentifier'])
            #rds_client.stop_db_cluster(DBClusterIdentifier=rds_cluster['DBClusterIdentifier'])
            #rds_client.delete_db_cluster(DBClusterIdentifier=rds_cluster['DBClusterIdentifier'],SkipFinalSnapshot=True)
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 1):
                logger.info('CleanUp >> RDS instance: '+ rds_cluster['DBClusterIdentifier']+ ' | Has mandatory tags... ')
            else:
                logger.info('CleanUp >> RDS instance: '+ rds_cluster['DBClusterIdentifier']+ ' mising mandatory tags, will be terminated')
                #rds_client.stop_db_cluster(DBClusterIdentifier=rds_cluster['DBClusterIdentifier'])
                #rds_client.delete_db_cluster(DBClusterIdentifier=rds_cluster['DBClusterIdentifier'],SkipFinalSnapshot=True)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: rdsClean on check_terminate_rds_cluster, Error terminating RDS Cluster: '+rds_cluster['DBClusterIdentifier']+': '+str(e.response['Error']['Message']))
#=================================================================================