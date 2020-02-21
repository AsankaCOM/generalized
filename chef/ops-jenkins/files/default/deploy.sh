#!/bin/bash
export AWS_DEFAULT_REGION=us-east-1

#### Customize those variable
STACK=28ec3bba-7332-48aa-b6fe-329fe9dff138
APP_NAME=sensehealth
RDS_INSTANCE="prd-rds"
APP_LAYER_NAME="prd-app"
#### STOP EDITING

STACK_NAME=`aws opsworks describe-stacks --region us-east-1 --stack-id $STACK | jq -r '.Stacks[].Name'`
APP_ID=`aws opsworks describe-apps --region us-east-1 --stack-id $STACK | jq -r ".Apps[] | select (.Shortname == \"$APP_NAME\") | .AppId"`

APP_LAYER_NAME="$STACK_NAME-app"
APP_LAYER_ID=`aws opsworks describe-layers --region us-east-1 --stack-id $STACK | jq -r ".Layers | .[] | select(.Name | contains(\"$APP_LAYER_NAME\")) | .LayerId"`

APP_INSTANCE_IDS=`aws opsworks describe-instances --region us-east-1 --layer-id $APP_LAYER_ID | jq -r '.[][]["InstanceId"]' | tr '\n' ' '`

NON_APP_INSTANCE_IDS=`aws opsworks describe-instances --region us-east-1 --stack-id $STACK | jq -r ".[][] | select(.LayerIds[] | contains(\"$APP_LAYER_ID\") | not) | .InstanceId" | tr '\n' ' '`

CHAT_LAYER_ID=`aws opsworks describe-layers --region us-east-1 --stack-id $STACK | jq -r '.Layers | .[] | select(.Name | contains("chatscript")) | .LayerId'`
CHAT_INSTANCE_IDS=`aws opsworks describe-instances --region us-east-1 --layer-id $CHAT_LAYER_ID | jq -r '.[][]["InstanceId"]' | tr '\n' ' '`

CELERY_LAYER_ID=`aws opsworks describe-layers --region us-east-1 --stack-id $STACK | jq -r ".Layers | .[] | select(.Name == \"$STACK_NAME-celery\") | .LayerId"`
CELERY_INSTANCE_IDS=`aws opsworks describe-instances --region us-east-1 --layer-id $CELERY_LAYER_ID | jq -r '.[][]["InstanceId"]' | tr '\n' ' '`

#ALL_INSTANCE_IDS=`aws opsworks describe-instances --region us-east-1 --stack-id $STACK | jq -r '.[][]["InstanceId"]' | tr '\n' ' '`
#NON_CHAT_INSTANCE_ID=`echo -e "$ALL_INSTANCE_IDS" | sed "s/$CHAT_INSTANCE_IDS//g"`
#NON_APP_INSTANCE_IDS=`echo -e "$NON_APP_INSTANCE_IDS" | sed "s/$CHAT_INSTANCE_IDS//g"`

LINE="=======================\n"
echo -e "$LINE"
echo "STACK: $STACK"
echo "APP_ID: $APP_ID"
echo "APP_LAYER_ID: $APP_LAYER_ID"
echo "APP_INSTANCE_IDS: $APP_INSTANCE_IDS"
echo "NON_APP_INSTANCE_IDS: $NON_APP_INSTANCE_IDS"
echo -e ""
echo -e "$LINE"

function opswork_update_branch {
  aws opsworks update-app --app-id $APP_ID  --app-source Revision=$branch
}

function opswork_polling_deploy {
  local DEPLOY_ID="$1"
  local UPDATE_STATUS=$(aws opsworks describe-deployments --deployment-id $DEPLOY_ID | jq -r '.Deployments[0].Status')

  while [ "$UPDATE_STATUS" == "running" ]
  do
    echo "still running"
    sleep 7
    UPDATE_STATUS=$(aws opsworks describe-deployments --deployment-id $DEPLOY_ID | jq -r '.Deployments[0].Status')
  done

  get_log "$DEPLOY_ID"

  if [ "$UPDATE_STATUS" == "failed" ]
  then
    echo "build failed"
    exit 1
  fi
}

function opswork_run_update_cookbook {
  if [ "$Update_custom_cookbook" == 'true' ]; then

    local instances=""

    if [ -n "$1" ]; then
      instances="--instance-ids $1"
    fi

    local DEPLOY_ID=`aws opsworks create-deployment --region us-east-1 --stack-id $STACK  $instances --command "{\"Name\":\"update_custom_cookbooks\"}" | jq -r '.DeploymentId'`
    echo "Update cookbook. ID: $DEPLOY_ID"
    local UPDATE_STATUS=$(aws opsworks describe-deployments --deployment-id $DEPLOY_ID | jq -r '.Deployments[0].Status')
    echo update custom cookbook is $UPDATE_STATUS
    opswork_polling_deploy "$DEPLOY_ID"
  fi
}

function opswork_run_deploy {
  local instances=""

  if [ -n "$1" ]; then
    instances="--instance-ids $1"
  fi

  local DEPLOY_ID=""

  echo -e "\n\n=====================\nPrepare for $DEPLOY_ACTION"
  case "$DEPLOY_ACTION" in
    Deploy)
      DEPLOY_ID=`aws opsworks create-deployment --region us-east-1 --stack-id $STACK --custom-json "{\"jenkins_job_id\":\"$BUILD_NUMBER\"}"  --command "{\"Name\":\"deploy\"}" --app-id  $APP_ID $instances | jq -r '.DeploymentId'`
      ;;
    Rollback)
      echo aws opsworks create-deployment --region us-east-1 --stack-id $STACK   --command "{\"Name\":\"rollback\"}" --app-id  $APP_ID $instances
      DEPLOY_ID=`aws opsworks create-deployment --region us-east-1 --stack-id $STACK   --command "{\"Name\":\"rollback\"}" --app-id  $APP_ID $instances | jq -r '.DeploymentId'`
      ;;
  esac
  local UPDATE_STATUS=$(aws opsworks describe-deployments --deployment-id $DEPLOY_ID | jq -r '.Deployments[0].Status')
  echo "$DEPLOY_ACTION $DEPLOY_ID is $UPDATE_STATUS"
  opswork_polling_deploy "$DEPLOY_ID"
}

function opswork_run_custom_recipe {
  local recipe="$1"
  local instance_ids="$2"
  echo aws opsworks create-deployment --region us-east-1 --stack-id $STACK --command "{\"Name\":\"execute_recipes\",\"Args\":{\"recipes\":[\"$recipe\"]}}" --app-id  $APP_ID --instance-ids $instance_ids

  local DEPLOY_ID=`aws opsworks create-deployment --region us-east-1 --stack-id $STACK --command "{\"Name\":\"execute_recipes\",\"Args\":{\"recipes\":[\"$recipe\"]}}" --app-id  $APP_ID --instance-ids $instance_ids| jq -r '.DeploymentId'`
  echo "Run custom cookbook $recipe ID $DEPLOY_ID"

  opswork_polling_deploy "$DEPLOY_ID"
}

function rolling_deploy {
  source /var/lib/jenkins/ed/easydep/bin/activate
  
  echo -e "\n\n=====================\nPrepare for $DEPLOY_ACTION"
  case "$DEPLOY_ACTION" in
    Deploy)
      python /usr/local/bin/easy_deploy.py --elb-region us-east-1 deploy --application=$APP_NAME rolling --stack-name=$STACK_NAME --layer-name=$APP_LAYER_NAME --comment="Rolling deployment to all app servers" --timeout=1000
      ;;
    Rollback)
      echo python /usr/local/bin/easy_deploy.py --elb-region us-east-1 rollback --application=$APP_NAME rolling --stack-name=$STACK_NAME --layer-name=$APP_LAYER_NAME --comment="Rolling rollback to all app servers" --timeout=1000
      python /usr/local/bin/easy_deploy.py --elb-region us-east-1 rollback --application=$APP_NAME rolling --stack-name=$STACK_NAME --layer-name=$APP_LAYER_NAME --comment="Rolling rollback to all app servers" --timeout=1000
      ;;
  esac
}

function backup_rds {
  echo "Create RDS snapshot " $RDS_INSTANCE-$BUILD_NUMBER-$BUILD_ID
  aws rds create-db-snapshot --db-snapshot-identifier "$RDS_INSTANCE-$BUILD_NUMBER-$BUILD_ID" --db-instance-identifier $RDS_INSTANCE
}

function get_log {
  local urls=`aws opsworks describe-commands --deployment-id $1 | jq -r '.Commands[].LogUrl'`
  local log_content=""
  echo "Deployment Log: $1"
  if [ -n "$urls" ]; then
    printf '%s\n' "$urls" | while IFS= read -r line
    do
      curl -s $line | gunzip || echo -e "\n\nCannot fetch log for deployment $1. Please view it in OpsWorks\n\n"
    done
  fi
}

opswork_update_branch || exit 1

if [ -z "$DEPLOY_ACTION" ]; then
  DEPLOY_ACTION="Deploy"
fi

case "$JOB_NAME" in
  chatscript)
    opswork_run_update_cookbook "$CHAT_INSTANCE_IDS" || ( echo "Fail to update cookbook. Check OpsWorks" && exit 1)
    echo opswork_run_deploy "$CHAT_INSTANCE_IDS"
    opswork_run_deploy "$CHAT_INSTANCE_IDS"
    rc="$?"
    echo "OpsWorks may have issue with log for long running job. Here is another attempt to get log"
    aws s3 --region us-east-1 cp s3://sensehealth-logs/opsworks/chatscripts/$BUILD_NUMBER.log - || exit "$rc"
    ;;
  *)
    opswork_run_update_cookbook "$APP_INSTANCE_IDS $CELERY_INSTANCE_IDS" || ( echo "Fail to update cookbook. Check OpsWorks" && exit 1)
    if [ "$ZERO_DOWNTIME" == "true" ]; then
      echo opswork_run_deploy "$CELERY_INSTANCE_IDS"
      opswork_run_deploy "$CELERY_INSTANCE_IDS"
      echo rolling_deploy
      rolling_deploy
    else
      backup_rds
      echo opswork_run_custom_recipe "ops-nginx::down" "$APP_INSTANCE_IDS"
      opswork_run_custom_recipe "ops-nginx::down" "$APP_INSTANCE_IDS"
      echo opswork_run_deploy "$APP_INSTANCE_IDS $CELERY_INSTANCE_IDS"
      opswork_run_deploy "$CELERY_INSTANCE_IDS $APP_INSTANCE_IDS"
      rc="$?"
      echo opswork_run_custom_recipe "ops-nginx::up" "$APP_INSTANCE_IDS"
      opswork_run_custom_recipe "ops-nginx::up" "$APP_INSTANCE_IDS"
      exit "$rc"
    fi
esac
