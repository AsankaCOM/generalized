# generalized

## Description
Repository storing all general Chef templates and Lambda Scripts making it easy to re-use Chef and lambda code.

## Content

### Chef
* ops-datadog
* ops-icinga2
* ops-jenkins
* ops-vpn

### Lambda
* share-ami-with-multiple-accounts

## Git
**IMPORTANT NOTE: Git usage**
In order to make changes to repository, the following best practices MUST be followed:

* Commit messages suggestions with common prefixes:
  * feat(eks-ssm): added ssm policies to eks worker role
  * fix(rds): fixed issues with instance identifier name
  * bug(ecs module): found a bug in the terraform ecs module when creating target groups, static dependencies found.
  * doc(vpc module): adding vpc module documentation as requested.

* Branches prefix suggestion following the same logic:
  * change/environment
  * feature/eks-encryption
  * documentation/vpc-module
