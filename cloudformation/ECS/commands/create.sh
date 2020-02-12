cd "${BASH_SOURCE%/*}" || exit
cd ..
COMMAND=$(sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' config.yml) 
eval $COMMAND 
aws cloudformation create-stack --region $REGION --stack-name "$StackName" --template-body file://master.yml --parameters ParameterKey=KeyPair,ParameterValue="$KeyPair" ParameterKey=S3BucketName,ParameterValue="$TemplatesBucketName" ParameterKey=S3KeyPrefix,ParameterValue="$Prefix" --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND