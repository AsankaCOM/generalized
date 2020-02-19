import botocore
import boto3
import datetime
from datetime import timezone
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
#=================================================================================
#                               OTHER METHODS
#=================================================================================
def check_tags(tags, tag_searched):
    """
    Description:
        Searches for an specific tag
    Args:
        tags (dict): dictionary of tags
        tag_searched (string): name of the tag you are looking for
    Returns:
        dictionary with two values: 
            Found (bool) indicates if the tag was found
            Value: value of the tag
    """
    try:
        for t in tags:
            if t['Key'] == tag_searched:
                return {'Found': True, 'Value': t['Value']}
        return {'Found': False, 'Value': 0}
    except Exception as e:
        logger.info('CleanUp >> File: helper.py on check_tags, ERROR TAGS: '+str(e))
        return {'Found': False, 'Value': 0}

def check_tags_v3(tags, tag_searched):
    """
    Description:
        Searches for an specific tag
    Args:
        tags (dict): dictionary of tags
        tag_searched (string): name of the tag you are looking for
    Returns:
        dictionary with two values: 
            Found (bool) indicates if the tag was found
            Value: value of the tag
    """
    try:
        for t in tags:
            if t['key'] == tag_searched:
                return {'Found': True, 'Value': t['value']}
        return {'Found': False, 'Value': 0}
    except Exception as e:
        logger.info('CleanUp >> File: helper.py on check_tags, ERROR TAGS: '+str(e))
        return {'Found': False, 'Value': 0}

def check_tags_v2(tags, tag_searched):
    try:
        if tag_searched in tags:
            return {'Found': True, 'Value': tags[tag_searched]}
        return {'Found': False, 'Value': 0}
    except Exception as e:
        logger.info('CleanUp >> File: helper.py on check_tags_v2, ERROR TAGS: '+str(e))
        return {'Found': False, 'Value': 0}

def get_regions():
    try:
        ec2 = boto3.client('ec2')
        regions = ec2.describe_regions()
        return regions
    except botocore.exceptions.ClientError as e:
        logger.info('CleanUp >> File: helper.py on get_regions, Error Getting Regions: '+str(e.response['Error']['Message']))


def check_tags_exist(tags, tags_searched, tag_type):
    try:
        x = 0
        for tag_s in tags_searched:
            if tag_type == 1:
                res = check_tags(tags, tag_s)
                if res['Found'] : x += 1
            elif tag_type == 2:
                res = check_tags_v2(tags, tag_s)
                if res['Found'] : x += 1
            elif tag_type == 3:
                res = check_tags_v3(tags, tag_s)
                if res['Found'] : x+= 1
            else:
                return False
        resp = True if len(tags_searched) == x else False
        return resp
    except Exception as e:
        logger.info('CleanUp >> File: helper.py, Error'+str(e))

def to_hours(createdAt):
    try:
        return round(((datetime.datetime.today().replace(tzinfo=timezone.utc) - createdAt).total_seconds()/3600))
    except Exception as e:
        logger.info('CleanUp >> File: helper.py on to_hours method, Error'+str(e))
        return 0

def get_mandatory_tags():
    return ['Owner', 'Client', 'Team']