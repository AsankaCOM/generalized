# Elastic Search Template

## Description

Template to create an elastic search cluster

## Parameters
| Parameter        |          Description           |      Type             |   Required |
| ---------------- |:------------------------------:|:--------------------:| ----------:|
| DomainName | Domain name to use for elastic search | String | Yes |
| EbsEnabled | Specifies whether Amazon EBS volumes are attached to data nodes in the Amazon ES domain | String | No |
| VolumeSize | Size in GB of the EBS volume attached on each node | Number | No |
| VolumeType | Type of storage selected for the esb | String | No |
| NumberOfInstances | The number of data nodes (instances) to use in the Amazon ES domain | Number | No |
| InstanceType | Type of instance to use for the nodes | String | No |
| ElasticSearchVersion | The version of Elasticsearch to use | String | No |
| SnapshotHour | The hour in UTC during which the service takes an automated daily snapshot | Number | No |
| OwnerName | An arbitrary tag name for the owner of these resources | String | Yes |
| StackName | The name of the stack to which these resources belong | String | Yes |
| Environment | Environment name to append to resources names and tags | String | Yes |

## Outputs
* ESArn: Elastic Search ARN
* ESDomainArn: Elastic Search Domain ARN
* ESEndpoint: Elastic Search Endpoint