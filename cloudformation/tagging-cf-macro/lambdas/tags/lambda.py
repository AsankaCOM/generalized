import os
import json
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def handler(event, context):
    try:
        response = {
            "requestId": event["requestId"],
            "status": "success",
            "statusCode": 200
        }
        new_tags = event['params']
        fragment = event['fragment']
        if check_mandatory_tags(new_tags):
            resources = fragment['Resources']
            tag_resources(resources, new_tags)
        else:
            response['statusCode'] = 400
            response['status'] = 'failure'
            response['errorMessage'] = 'Missing mandatory tags: '+str(get_mandatory_tags())
        response['fragment'] = fragment
        logger.info(response)
        return response
    except Exception as e:
        response["status"] = "failure"
        response["errorMessage"] = str(e)
        response["statusCode"] = 500
        return response

def tag_resources(resources, n_tags):
    try:
        for r in resources:
            resource = resources[r]
            if resource['Type'] in get_allowed_resources_types():
                initialize_tags(resource)
                for t in n_tags:
                    resource['Properties']['Tags'].append({'Key':t, 'Value':n_tags[t]})
        return True
    except Exception as e:
        logger.info('Tagging_macro >> error: '+str(e))
        return False

def initialize_tags(resource):
    try:
        if 'Tags' not in resource['Properties']:
            resource['Properties']['Tags'] = []
    except Exception as e:
        logger.info('Tagging_macro >> error: '+str(e))


def check_mandatory_tags(n_tags):
    try:
        l = []
        for t in n_tags:
            l.append(t)
        for tag in get_mandatory_tags():
            if tag not in l:
                return False
        return True
    except Exception as e:
        logger.info('Tagging_macro >> error: '+str(e))
        return False

def tag_exists(searched):
    if searched in get_mandatory_tags():
        return True
    return False


def get_allowed_resources_types():
    return ['AWS::EC2::Instance', 'AWS::RDS::DBInstance', 'AWS::ECS::Cluster', 'AWS::EKS::Cluster', 'AWS::EC2::VPC', 'AWS::DynamoDB::Table']

def get_mandatory_tags():
    return ['Owner', 'Team', 'Client', 'OwnerEmail']