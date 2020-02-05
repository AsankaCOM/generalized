## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| null | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| autoscaler\_version | Version of the cluster autoscaler | `string` | `"v1.3.7"` | no |
| cluster\_name | Name of the EKS cluster | `string` | `"nclouds"` | no |
| cluster\_policies | Cluster default policies | `list` | <code><pre>[<br>  "AmazonEKSClusterPolicy",<br>  "AmazonEKSServicePolicy"<br>]<br></pre></code> | no |
| dashboard\_version | version of the dashboard | `string` | `"v1.10.1"` | no |
| deploy\_efs | Wheter create EFS or not | `string` | `false` | no |
| efs\_namespace | Namespace where the efs storage class will be executed | `string` | `"kube-system"` | no |
| efs\_provisioner\_version | Version of the efs provisioner | `string` | `"v1.0.0-k8s1.10"` | no |
| environment | Environment where the cluster will be deployed | `string` | `"dev"` | no |
| external\_dns\_version | Version of external dns pod | `string` | `"v0.5.11"` | no |
| k8s\_version | k8s version | `string` | `"1.14"` | no |
| kube2iam\_version | Version of kube2iam daemon | `string` | `"0.10.4"` | no |
| metrics\_server\_version | variable of metrics server, needed for hpa | `string` | `"v0.3.1"` | no |
| private\_domain\_name | Private domain for the services | `string` | `""` | no |
| private\_subnets | list of private subnets where the cluster will be deploy | `list` | n/a | yes |
| private\_subnets\_count | count of private subnets, due to an error while trying to count the subnets when they have not been created yet we have to send the value from outside the module | `string` | `0` | no |
| public\_domain\_name | Public domain for the public services | `string` | `""` | no |
| public\_subnets | list of private subnets where the cluster will be deploy | `list` | n/a | yes |
| render\_files | Wheter render the templates or not | `string` | `true` | no |
| vpc\_id | Id of the vpc where the cluster will be deploy | `string` | n/a | yes |
| vpn\_sg | Security group of the vpn to allow connections over ssh to the worker nodes | `string` | `""` | no |
| worker | Map of EKS workers settings (instance-type, min-size, max-size, key\_name, volume\_type, volume\_size) | `map` | <code><pre>{<br>  "instance-type": "t3.large",<br>  "key_name": "",<br>  "max-size": "4",<br>  "min-size": "2",<br>  "volume_size": 100,<br>  "volume_type": "gp2"<br>}<br></pre></code> | no |
| worker\_node\_policies | Worker node default policies | `list` | <code><pre>[<br>  "AmazonEKSWorkerNodePolicy",<br>  "AmazonEKS_CNI_Policy",<br>  "AmazonEC2ContainerRegistryReadOnly",<br>  "CloudWatchFullAccess"<br>]<br></pre></code> | no |

## Outputs

| Name | Description |
|------|-------------|
| eks\_access\_role | n/a |
| eks\_worker\_role\_arn | n/a |

