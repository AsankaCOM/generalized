### Terraform

## Prerequisites

- Terraform v0.11.14
- jq
- aws-iam-authenticator
- kubectl
- Pem key already created


## Allow worker nodes to connect to your cluster

To update the kubeconfig you can execute the following command, this will update the kubeconfig and if your iam user has the role that will allow you access to the cluster you can start using kubectl

```sh
aws eks update-kubeconfig --name <cluster-name>
```

Once you have the kubeconfig set up you can apply the aws-auth configmap that was rendered into the dist folder to allow the worker nodes to connect the cluster using the following command.

```sh
kubectl apply -f dist/1.aws_configmap_<cluster-name>.yaml
```

## How does the EKS authentication process works?

Since EKS manage the control-panel section of the kubernetes cluster, when the cluster is created it automatically creates a configuration that only allows access to the cluster to the person/role that created it, in the cluster's RBAC configuration.

So in order to get the user connected, the eks module creates a role for allowing users to access eks using kubectl.

After that we configured the EKS cluster to allow access to only the role, so before you connect to the cluster you need to assume the role.

## How to authenticate to EKS cluster

* Add an entry into your ~/.aws/credentials file
```bash
[qa]
role_arn = <eks-access-role>
source_profile = YOUR_DEFAULT_PROFILE
```
source_profile needs to be the profile that has access to the bkj aws account.

* Export the profile that you just created

```bash
export AWS_PROFILE=your_profile
```
You neeed to do the above command every time that you want to connect to the cluster, if not you wont assume the role and you wont be able to access.

* Update your kubeconfig file

```bash
aws eks update-kubeconfig --name cluster_name --region us-west-2
```

* Test the cluster

```bash
kubectl get svc
```
### Deploy Kubernetes addons

After the cluster creation under the dist folder you will see the yaml templates to deploy the following addons:

- Kubernetes Dashboard
- Kube2iam
- External-Dns
- Alb Ingress Controller
- Metrics Server
- Cluster Autoscaler
- EFS Storage Class

You can deploy all at once with the following command :
```sh
kubectl apply -f dist/ --recursive
```

#### Render file with Terraform.
If you make a change on the rendered files on your terraform templates, you'll need to change the value of the variable `render_files`

Possible values are:
```
# 1. Set the variable to true, so it will remove old rendered files.
render_files  = "true"
# 2. Apply the terraform changes.
terraform apply -var-file=config/qa.tfvars
# 3. Get the value back to false, so it don't remove the rendered files.
render_files  = "false"
```

### Kubernetes Dashboard

The kubernetes dashboard is an addon and its yaml file is rendered into the `dist` folder, once the rendered template is applied you should be able to access the dashboard.

In order to access the dashboard follow this steps:

* On your terminal execute the following command
```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```
* You will get an output like the following, copy the `token` :

```
Name:         eks-admin-token-2zrl4
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: eks-admin
              kubernetes.io/service-account.uid: e57b67d0-993a-11e9-be8c-0621026b78ce

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      pJrMgV7EjYUMY_W3NAMHdXkJ_5MLhwAWnXR36i6yhoReuszGvk4Bcn6tN8FewV7y5Qz2c4-abGgjvbCtDOec3bxth8459SYf3gnzR9GjI2GR2VRS6y1NP2ajRnqFx1ipMabcEwdt_iZ7344HdELv2_ASQpHuHAKub_-kkq3UIqmOy9VRiw5tR2bOwxtgoXNOYyNffITsML0Z4FTMMOygEwdt_iZ7344HdELv2_ASQpHuHAKub_-kkq3UIqmOy9VRiw
```

* Now we need to proxy the dashboard to your localhost, execute:
```bash
kubectl proxy
```

* Access to the following URL: [Kubernetes dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login)
 
* You will see a prompt asking you for the token, paste the token generated in the first step and click sign in.


### Troubleshoot

### Output reference error

In the case that you get an error while destroying the template similar as the following :

```
output.foo: Resource 'null_resource.b' does not have attribute 'id' for variable 'null_resource.b.id'
```
export the following variable and try again

```bash
export TF_WARN_OUTPUT_ERRORS=1
```
