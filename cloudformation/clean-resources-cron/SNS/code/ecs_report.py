import json
import time
import botocore
import boto3
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def ecs_report_terminated(terminated):
    try:
        msg = "================================\n"
        msg += ">> Terminated ECS Clusters: \n"
        good = msg
        errors = ">> Errors ECS Cluster: \n"
        for t in terminated:
            if t['statusCode'] == 200:
                good += "  *- Cluster: "+t['name']+" |  Region: "+t['region']+"\n"
            else:
                errors += "  *- Cluster: "+t['name']+" |  Region: "+t['region']+" | Error: "+t['Message']+"\n"
        return good + "================================\n" + errors + "================================\n"
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))

