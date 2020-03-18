import json
import time
import botocore
import boto3
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def ec2_report_terminated(terminated):
    try:
        msg = "================================\n"
        msg += ">> Terminated EC2 Instances: \n"
        for t in terminated:
            msg += "  *- Instance: "+t['id']+" |  Region: "+t['region']+"\n"
        return msg + "================================\n"
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))

def ec2_report_errors(errors):
    try:
        if len(errors) > 0:
            msg = "================================\n"
            msg += ">> Encountered Errors EC2 Instances: \n"
            for er in errors:
                msg += " *- Instance: "+er['id']+" | Region: "+er['region']+" | Error: "+er['msg'] + "\n"
            return msg + "================================\n" 
        return ""
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))


def get_ec2_report(terminated, errors, running):
    try:
        msg = ">> EC2 Report Summary \n"
        msg += ec2_report_terminated(terminated)
        msg += ec2_report_errors(errors)
        return msg
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))