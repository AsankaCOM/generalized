# Talix Infrastructure




## Deployment

To deploy this CloudFormation stack execute the following command. *(aws cli required)* *(You need appropiate IAM permissions to deploy the stack)*

```console
aws cloudformation create-stack \
  --stack-name nclouds-hipaa \
  --region us-west-2 \
  --template-body "file://master.yml" \
  --parameters="file://parameters.json" \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
```