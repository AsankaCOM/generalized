# RDS Template

## Description

This template is used to create an RDS instance with especifications according to the following parameters

**Important:** For the password of the db instance, you need to create a Parameter Store variable and needs to be a SecureString Type. Use alias/aws/ssm KMS key. The name of the variable needs to be provided to the template (DBMasterPasswordSP)

### Parameters
| Parameter        |          Description           |      Type             |   Required |
| ---------------- |:------------------------------:| :--------------------:| ----------:|
| DBInstanceName   | Name will be given to the Instance  | String           |   Yes      |
| DBEngine         | Engine that the instance will use   | String           |   Yes      |
| DBEngineVersion  | Engine version used by the instance | String           |   Yes      |
| DBdataBaseName   | Database name that will be created  | String           |   Yes      |
| DBDeleteProtection | Enables or Disables delete protection | String       |   No       |
| DBInstanceClass  | Instance class that rds instance will use | String     |   Yes      |
| DBMasterUsernameSP | User name that the database will use    | String     |   Yes     |
| DBMasterPasswordSP | Parameter Store name where the password is stored | String | Yes  |
| DBMasterPasswordParameterStoreVersion | Version of the Parameter Store where password is saved | Yes |
| DBMultiAZ | Enables or Disables Multi-AZ deployment | String | Yes|
| DBStorage | Storage size for the Instance (GB) | String | Yes |
| DBMinorVersionUpgrade | indicates whether minor engine upgrades are applied automatically to the DB instance during the maintenance window | String | No|
| DBMantainanceWindow | weekly time during which system maintenance can occur, format valid format ddd:hh24:mi-ddd:hh24:mi | String | Yes |
| DBPort | Port number where the db accepts connections | String | Yes |
| DBParameterGroup | Valid parameter group according to the DB Instance Engine used | String | Yes |
| VPCId | VPC Id where db will be created | VPC Id | Yes |
| Subnet1 | valid subnet id according to the vpc provided (VPCId) | Subnet Id | Yes |
| Subnet2 | valid subnet id according to the vpc provided (VPCId) | Subnet Id | Yes |
| OwnerName | Owner of the resources | String | Yes |
| StackName | Stack name from where the resources are deployed | String | Yes |
| Environment | Environment name to append to resources names and tags | String | Yes |

## Outputs
| Name   | Description |
| ---------------- | ---------------- |
| DBInstanceCreated |  DB instance created by the template |
