#!/usr/local/bin/python

import sys
sys.path.insert(1, '/var/www/app.clearlist.com/clearlist/src/python/')

import argparse
from trooly.aws.service.noperm import NoPerm
from trooly.aws.service.quality import Quality
from trooly.aws.service.cron import Cron
from trooly.aws.service.monitoring import Monitoring
from trooly.aws.client import AWSClient
from trooly.config import AWS_REGION, AWS_KEY, AWS_SECRET
import logging
import nagiosplugin
import subprocess
import re

ROOT_PATH = '/var/www/app.clearlist.com/clearlist/src/python'
WORKER_CTL_PATH = "%s%s" % (ROOT_PATH, '/trooly/mq/workerctl.py')
SSL_PEM_FILE = "%s%s" % (ROOT_PATH, '/resources/awskey.pem')
#SSL_PEM_FILE = "%s" % ('/home/ec2-user/awskey.pem')

VALID_WORKER_SERVICES = {
    'trooly_noperm': NoPerm(),
    'trooly_monitoring': Monitoring(),
    'trooly_quality': Quality(),
    'trooly_cron': Cron(),
}

VALID_FABRICS = {'prod', 'stg', 'qa'}
_log = logging.getLogger('nagiosplugin')


class WorkerHealthChecker(nagiosplugin.Resource):

    def __init__(self,
                 service_type,
                 trooly_service_type,
                 expectedNumProcessesPerMachine,
                 allow_empty_workers=False,
                 fabric=None):
        self.service = service_type
        self.trooly_service = trooly_service_type
        self.expectedNumProcs = expectedNumProcessesPerMachine
        self.client = AWSClient(AWS_REGION, AWS_KEY, AWS_SECRET)
        self.fabric = fabric
        self.allow_empty_workers = allow_empty_workers
        if fabric is None:
            self.fabric = self.client.get_self_mode()

    def get_worker_ips(self):
        valid_instances = self.client.running_instances(self.fabric,
                                          VALID_WORKER_SERVICES[self.trooly_service])
        for inst in valid_instances:
            yield inst.private_ip_address

    def probe(self):
        valid_host_ips = self.get_worker_ips()
        num_ips = 0
        for ip_address in valid_host_ips:
            num_ips += 1
            userHost = '%s%s' % ('ec2-user@', ip_address)
            remoteCmd = '/bin/sh -c "env \"PYTHONPATH={2}\" python {3} {4} status\"' \
                        .format(SSL_PEM_FILE,
                                userHost,
                                ROOT_PATH,
                                WORKER_CTL_PATH,
                                self.service)
            _log.info('Cmd is :  %s' % (remoteCmd))
            p = subprocess.Popen(remoteCmd, shell=True, stdout=subprocess.PIPE)
            #Get the last line
            output = str(p.communicate()[-2])
            _log.info("Output is %s" % output)
            out = re.search('^\s*(\d+)', output)
            count = 0
            if out:
                count = out.group(1)
                count = int(count)
            yield nagiosplugin.Metric('Num %s workers in %s' %
                                      (self.trooly_service, ip_address),
                                      count,
                                      min=0,
                                      context='num_%s_workers' %
                                      (self.trooly_service))

        if num_ips == 0 and self.allow_empty_workers:
            yield nagiosplugin.Metric('No Workers for %s but '
                                      'treating as success' %
                                      (self.trooly_service),
                                      2,
                                      min=0,
                                      context='num_%s_workers' %
                                      (self.trooly_service))
        elif num_ips == 0:
            yield nagiosplugin.Metric('\"No Worker machines allocated for %s !!\"' %
                                      (self.trooly_service),
                                      0,
                                      min=1,
                                      context='num_%s_workers' %
                                      (self.trooly_service))


@nagiosplugin.guarded
def main():
    argp = argparse.ArgumentParser(description=__doc__)
    argp.add_argument('-e', '--expected_nprocs',
                      metavar='RANGE',
                      default='',
                      help='return critical if number of processes \
                      is outside RANGE')
    argp.add_argument('-f', '--fabric',
                      default='',
                      help='Fabric which needs to be checked')
    argp.add_argument('-s', '--service_type',
                      default='',
                      help='Worker Service which needs to be checked')
    argp.add_argument('-a', dest='allow_empty_workers',
                      action='store_true', default=False)
    argp.add_argument('-v', '--verbose',
                      default=0,
                      help='Verbosity level')
    argp.add_argument('-t', '--timeout',
                      default=30,
                      help='Timeout in secs')
    args = argp.parse_args()

    # validate service
    service = args.service_type
    trooly_service = service
    if not service.startswith('trooly_'):
        trooly_service = 'trooly_' + service
    else:
        service = trooly_service[len('trooly_'):]

    service = service.lower()
    trooly_service = trooly_service.lower()
    if trooly_service not in VALID_WORKER_SERVICES:
        raise ValueError('Invalid worker service {0}'.format(trooly_service))

    # Validate fabric
    fabric = args.fabric.lower()
    if fabric not in VALID_FABRICS:
        raise ValueError('Invalid fabric {0}'.format(fabric))

    check = nagiosplugin.Check(WorkerHealthChecker(service,
                                                   trooly_service,
                                                   args.expected_nprocs,
                                                   args.allow_empty_workers,
                                                   fabric),
                               nagiosplugin.ScalarContext(
                                   'num_%s_workers' % trooly_service,
                                   '-1:',
                                   str(args.expected_nprocs)))
    check.main(args.verbose, timeout=args.timeout)
    exit(check.exitcode)

if __name__ == '__main__':
        main()
