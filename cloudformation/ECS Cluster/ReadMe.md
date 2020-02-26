
# AWS ECS / Fargate

Amazon Elastic Container Service (Amazon ECS) is a highly scalable, high-performance container orchestration service that supports Docker containers and allows to easily run and scale containerized applications on AWS. Amazon ECS eliminates the need for you to install and operate your own container orchestration software, manage and scale a cluster of virtual machines, or schedule containers on those virtual machines.

## Fargate
AWS Fargate is a compute engine for Amazon ECS that allows you to run containers without having to manage servers or clusters. With AWS Fargate, you no longer have to provision, configure, and scale clusters of virtual machines to run containers.

![Fargate](images/fargate.png)

To Spin up an aplication on ECS you need to define a Service and Tasks Definitions:
- A service allows you to run and maintain a specified number of instances of a task definition simultaneously in the ECS cluster
- A task definition is the way you define the docker containers that you want to run. You specify some parameters like the image, roles, and cpu and memory to use with each task.

## CloudFormation

A common architecture of an ECS application uses a load balancer and private and public subnets within a VPC:

![ECS](images/ecs.png)

### Parameters

- **DesiredCapacity**: Desired capacity for the auto scaling group, count of EC2 instances.
- **MaxSize**: Maximum count of instances of cluster.
- **InstanceType**: EC2 Instance type for cluster.
- **ECSSubnets**: List of subnets to distribute cluster.
- **VpcId**: VPC identifier.
- **LoadBalancerSecurityGroup**: Security group of load balancer
- **KeyPair**: Key Pair Name for EC2 access.
- **ClusterName**: Name of cluster.
- **ECSAMI**: AMI for ECS.


### Using Cloudformation Script parameters.

The script attached creates a task definition using a tomcat image. upload the task definition to the S3 bucket. The scheme of the load balancer should be internet facing for this cluster. service bucket name should be the name of the bucket and service name will be the name of the file uploaded on the cluster, E.g for a tomcat1.yaml file uploaded to a s3 bucket name democlusterbucket, the parameters will be servicebucketpath = democlusterbucket, serviceName = tomcat1
