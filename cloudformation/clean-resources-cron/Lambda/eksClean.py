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
#                               EKS CLEAN
#=================================================================================
def eks_cleaning(eks_dict):
    try:
        deleted_eks = []
        regions = get_regions()
        for region in regions['Regions']:
            eks = boto3.client('eks', region_name=region['RegionName'])
            try:
                eks_result = eks.list_clusters()
                logger.info('REGION >> ------------- '+str(region['RegionName'])+" | status: "+str(region['OptInStatus']))
                ###############################
                reg = {region['RegionName']:[]}
                terminated = {'terminated':[]}
                running = {'running':[]}
                errors = {'errors':[]}
                reg[region['RegionName']].append(terminated)
                reg[region['RegionName']].append(running)
                reg[region['RegionName']].append(errors)
                flag = False
                ###############################
                for cluster in eks_result['clusters']:
                    flag = True
                    cl = eks.describe_cluster(name=cluster)
                    t = cl['cluster']['tags']
                    if len(t)>0:
                        check_terminate_eks(eks, cl['cluster'], t, False, deleted_eks, reg, region['RegionName'])
                    else:
                        check_terminate_eks(eks, cl['cluster'], None, True, deleted_eks, reg, region['RegionName'])
                logger.info('REGION >> ------------ END')
                ###############################
                if flag:
                    eks_dict['Regions'].append(reg)
            except botocore.exceptions.ClientError as e:
                logger.info('CleanUp >> EKS '+str(e.response['Error']['Message']))
        return get_eks_report(deleted_eks)
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error listing EKS '+str(e.response['Error']['Message']))
        return []

def check_terminate_eks(eks_client, cluster, tags, terminate_now, deleted_eks, reg, region_name):
    try:
        if terminate_now:
            logger.info('CleanUp >> EKS has no tags mandatory tags, terminating EKS cluster: '+cluster['name'])
            terminate_eks_cluster(eks_client, cluster, tags, region_name, reg)
            deleted_eks.append(cluster['name'])
            reg[region_name][0]['terminated'].append(cluster['name'])
        else:
            if check_tags_exist(tags, get_mandatory_tags(), 2):
                logger.info('CleanUp >> EKS cluster '+cluster['name']+' | has mandatory tags...')
                terminate_eks_cluster(eks_client, cluster, tags, region_name, reg)
                reg[region_name][1]['running'].append(cluster['name'])      
            else:
                logger.info('CleanUp >> EKS cluster '+cluster['name']+' missing mandatory tags, will be terminated')
                terminate_eks_cluster(eks_client, cluster, tags, region_name, reg)
                deleted_eks.append(cluster['name'])
                reg[region_name][0]['terminated'].append(cluster['name'])
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating EKS Cluster: '+cluster['name']+': '+str(e.response['Error']['Message']))
        reg[region_name][2]['errors'].append(cluster['name'])

def delete_eks_node_groups(eks_client, cluster):
    try:
        node_groups = eks_client.list_nodegroups(clusterName=cluster['name'])
        for ng in node_groups['nodegroups']:
            try:
                eks_client.delete_nodegroup(clusterName=cluster['name'], nodegroupName=ng)
            except botocore.exceptions.ClientError as e:
                logger.info('CleanUp >> Error deleting nodegroup :'+str(ng))
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating EKS Cluster: '+cluster['name']+': '+str(e.response['Error']['Message'])) 

def delete_eks_fargateprofile(eks_client, cluster):
    try:
        fargate_profiles = eks_client.list_fargate_profiles(clusterName=cluster['name'])
        for fargate in fargate_profiles['fargateProfileNames']:
            try:
                eks_client.delete_fargate_profile(clusterName=cluster['name'], fargateProfileName=fargate)
            except botocore.exceptions.ClientError as e:
                logger.info('CleanUp >> Error deleting fargate profile :'+str(fargate))
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating EKS Cluster: '+cluster['name']+': '+str(e.response['Error']['Message']))

def delete_eks_cluster(eks_client, cluster, region_name, reg):
    try:
        delete_eks_node_groups(eks_client, cluster)
        delete_eks_fargateprofile(eks_client, cluster)
        eks_client.delete_cluster(name=cluster['name'])
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> Error terminating EKS Cluster: '+cluster['name']+': '+str(e.response['Error']['Message']))
        reg[region_name][2]['errors'].append(cluster['name'])

def terminate_eks_cluster(eks_client, cluster, tags, region_name, reg):
    try:
        if onTesting():
            if tags != None:
                if check_tags_exist(tags, get_testing_tags(), 2):
                    delete_eks_cluster(eks_client, cluster, region_name, reg)
                    reg[region_name][0]['terminated'].append(cluster['name'])
        else:
            delete_eks_cluster(eks_client, cluster, region_name, reg)
            reg[region_name][0]['terminated'].append(cluster['name'])
    except botocore.exceptions.ClientError as e:
        logger.info('Clean Up >> File: eksClean.py, Error: '+str(e.response['Error']['Message'])+' when trying to delete cluster: '+str(cluster['name']))
        reg[region_name][2]['errors'].append(cluster['name'])

def get_eks_report(deleted_eks):
    try:
        r = " EKS Clusters deleted: \n"
        for i in deleted_eks:
            r += "  * Cluster ID: "+str(i)+" \n"
        r += "-----------------------------------------------\n"
        return r
    except Exception as e:
        logger.info('Clean Up >> File: eksClean.py on get_ecs_report, Error: '+str(e))
#=================================================================================