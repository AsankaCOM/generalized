import json
import time
import botocore
import boto3
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def rds_report_terminated(terminated, typerds):
    try:
        msg = "================================\n"
        msg += ">> Terminated RDS "+typerds+": \n"
        for t in terminated:
            msg += "  *- "+typerds+": "+t['id']+" |  Region: "+t['region']+"\n"
        return msg + "================================\n"
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))

def rds_report_errors(errors, typerds):
    try:
        if len(errors) > 0:
            msg = "================================\n"
            msg += ">> Encountered Errors RDS "+typerds+": \n"
            for er in errors:
                msg += " *- "+typerds+": "+er['id']+" | Region: "+er['region']+" | Error: "+er['msg'] + "\n"
            return msg + "================================\n" 
        return ""
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))

def get_rds_report(terminated, errors, running, typerds):
    try:
        msg = ">> RDS "+typerds+" Report Summary \n"
        msg += rds_report_terminated(terminated, typerds)
        msg += rds_report_errors(errors, typerds)
        return msg
    except Exception as e:
        logger.info('Cleaning >> error '+str(e))

