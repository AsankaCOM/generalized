# RDS Template

## Description

This template is used to create an RDS instance with especifications according to the following parameters

## Parameters
| Parameter        |          Description           |      Type             |   Required |
| ---------------- |:------------------------------:|:--------------------:| ----------:|
| Identifier | A name identifier for the RDS instance | String | Yes |
| VpcId | VPC to host the RDS instance | VPC Id | Yes |
| SubnetIds | Subnet Ids to host the RDS instance | List of Subnets Ids | Yes |
| SourceSecurityGroup | Security Group Id to allow traffic from | Security Group Id | Yes 
| DBName | The name of the default database in the instance | String | Yes |
| DBUsername | Master username for the RDS database | String | Yes | 
| DBClass | Database instance class | String |  Yes |
| DBAllocatedStorage | The amount of storage (in GB) to allocate to the DB Instance | Number | Yes | 
| DBStorageClass | The database storage class to use | String | Yes |
| DBStorageEncrypted | Specifies whether the DB instance is encrypted | String | Yes |
| DBFamily | The database engine family for the ParameterGroup | String | Yes |
| DBEngine | The database engine for the RDS | String | Yes | 
| DBEngineVersion | The database engine version | String | Yes |
| DBPort | The port number for the Database engine | String | Yes |
| DBSnapshotIdentifier | Optional - The RDS snapshot to restore the DB instance | String | No |
| PreferredBackupWindow | Preferred Backup Window Time (UTC) | String | No |
| PreferredMaintenanceWindow | Preferred Maintenance Window Time (UTC) | String | No |
| BackupRetentionPeriod | Number of days to keep the database backup | Number | No | 
| OwnerName |  An arbitrary tag name for the owner of these resources | String | Yes |
| StackName | The name of the stack to which these resources belong | String | Yes |
| Environment | Environment name to append to resources names and tags | String | Yes |

## Outputs
* DBEndpoint: Primary endpoint address
* DBPort: Database endpoint port number
* DBSecurityGroupId: Database security group
* DBName: Default database name
* CredentialsSecret: The database credentials secret