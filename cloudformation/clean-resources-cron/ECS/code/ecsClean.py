import json
import botocore
import boto3
import logging
import datetime
from helpers import *
from datetime import timezone
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def ecs_cleaning(ecs_dict):
    try:
        deleted_ecs = []
        regions = get_regions()
        for region in regions['Regions']:
            ecs = boto3.client('ecs', region_name=region['RegionName'])
            try:
                ecs_result = ecs.list_clusters()
                logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
                cl = ecs.describe_clusters(clusters=ecs_result['clusterArns'], include=['TAGS'])
                for cluster in cl['clusters']:
                    if len(cluster['tags'])>0:
                        check_terminate_ecs(ecs, cluster, cluster['tags'], False, region['RegionName'], ecs_dict)
                    else:
                        check_terminate_ecs(ecs, cluster, None, True, region['RegionName'], ecs_dict)
                logger.info('REGION >> ------------ END')
            except botocore.exceptions.ClientError as e:
                logger.info('CleanUp >> ECS '+str(e.response['Error']['Message']))
        return ""
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error listing ECS '+str(e.response['Error']['Message']))
        return ""

def check_terminate_ecs(ecs_client, cluster, tags, terminate_now, region_name, dict):
    try:
        if terminate_now:
            logger.info('CleanUp >> Terminating Now, has no tags (Stopping for now): '+cluster['clusterName'])
            # dict['terminated'].append({
            #     'arn': cluster['clusterArn'],
            #     'name': cluster['clusterName'],
            #     'tags': tags,
            #     'region': region_name
            # })
            delete_ecs_cluster(ecs_client, cluster['clusterArn'], cluster['clusterName'], tags, region_name, dict)
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 3):
                logger.info('CleanUp >> ECS cluster '+cluster['clusterName']+' | has mandatory tags...')
                dict['running'].append({
                    'arn': cluster['clusterArn'],
                    'name': cluster['clusterName'],
                    'tags': tags,
                    'region': region_name
                })
            else:
                logger.info('CleanUp >> ECS cluster '+cluster['clusterName']+' missing mandatory tags, will be terminated')
                # dict['terminated'].append({
                #     'arn': cluster['clusterArn'],
                #     'name': cluster['clusterName'],
                #     'tags': tags,
                #     'region': region_name
                # })
                delete_ecs_cluster(ecs_client, cluster['clusterArn'], cluster['clusterName'], tags, region_name, dict)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating ECS Cluster: '+cluster['clusterName']+': '+str(e.response['Error']['Message']))
        dict['errors'].append({
            'arn': cluster['clusterArn'],
            'name': cluster['clusterName'],
            'msg': str(e.response['Error']['Message']),
            'tags': tags,
            'region': region_name
        })

def delete_ecs_cluster(ecs_client, cluster_id, cluster_name, tags, region_name, dict):
    try:
        if onTesting():
            if tags != None:
                if check_tags_exist(tags, get_testing_tags(), 3):
                    dict['terminated'].append({
                        'arn': cluster_id,
                        'name': cluster_name,
                        'tags': tags,
                        'region': region_name
                    })
        else:
            dict['terminated'].append({
                'arn': cluster_id,
                'name': cluster_name,
                'tags': tags,
                'region': region_name
            })
    except botocore.exceptions.ClientError as e:
        logger.info('Clean Up >> File: ecsClean.py, Error: '+str(e.response['Error']['Message'])+' when trying to delete cluster: '+str(cluster_name))
        reg[region_name][2]['errors'].append(cluster_name)