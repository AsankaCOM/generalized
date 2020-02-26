# OpenVPN Server
## Description
Template to launch a OpenVPN server using OpenVPN AMI in the marketplace

## Parameters
| Parameter        |          Description           |      Type             |   Required |
| ---------------- |:------------------------------:|:--------------------:| ----------:|
| VpcId    |  VPC id to configure vpn instance | VPC Id | Yes
| Subnet   |  Subnet where the vpn will be launched | Subnet ID | Yes
| InstanceKeyName | Key pair to use to access the vpn instance | Key Name | Yes |
| VpnInstanceType | Type of the instance to use for vpn server | String | Yes|
| VpnUsername | The initial admin Username for the VPN |  String | Yes |
| VpnPassword | The initial admin Password for the VPN |  String | Yes |
| Identifier | Identifier for the db instance and also name to tag resources created by the stack | String | Yes |
| OwnerName | An arbitrary tag name for the owner of these resources | String | Yes |
| StackName | The name of the stack to which these resources belong | String | Yes |
| Environment | Environment name to append to resources names and tags | String | Yes | 

## Resources
The template creates the following resources
* SecurityGroupVpn: creates security group to allow connection to the vpn server
* VpnServerInstance: EC2 instance that will be the vpn server
* VpnIpAddress: Elastic IP address associated to the vpn server

## Outputs
* VpnIpAddress: The elastic ip associated to the VPN server