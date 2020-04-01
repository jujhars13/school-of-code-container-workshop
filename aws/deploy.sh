#!/usr/bin/env bash
# spins up vpc and then cloud9 environments using cloudformation
# ensure AWS_PROFILE/SECRET_ACCESS are set before

readonly RANDOM_NUM="${RANDOM}"
readonly FILE_DIRECTORY=$(dirname "${BASH_SOURCE[0]}")
readonly STACK_NAME="soc-cloud9-${RANDOM_NUM}"
readonly NOW=$(date +%Y-%m-%dT%H:%M:%S)
readonly TAGS=("ApplicationName=cs-server" "Batch=batch-${RANDOM_NUM}" "DateCreation=${NOW}" "StackName=${STACK_NAME}" "Owner=jujharsingh@economist.com")
readonly AWS_DEFAULT_REGION="eu-west-1"

# where shall I open ssh access from?
readonly myIpAddress="$(curl -s https://ifconfig.me/)/32"

echo "Deploying network ${STACK_NAME}"
# deploy network
aws cloudformation deploy \
  --template-file "${FILE_DIRECTORY}/cloudFormation/01-networking.yml" \
  --stack-name "${STACK_NAME}-net" \
  --capabilities CAPABILITY_IAM \
  --tags "${TAGS[@]}" \
  --no-fail-on-empty-changeset \
  --region "${AWS_DEFAULT_REGION}" \
  --parameter-overrides \
      stackName="${STACK_NAME}" \
# have to wait for VPC  
aws cloudformation wait \
stack-exists \
--stack-name "${STACK_NAME}-net"

# deploys cloud9
aws cloudformation deploy \
  --template-file "${FILE_DIRECTORY}/cloudFormation/02-cloud9.yml" \
  --stack-name "${STACK_NAME}" \
  --capabilities CAPABILITY_IAM \
  --tags "${TAGS[@]}" \
  --no-fail-on-empty-changeset \
  --region "${AWS_DEFAULT_REGION}" \
  --parameter-overrides \
      stackName="${STACK_NAME}" \
      myIpAddress="${myIpAddress}" \
      envName="${RANDOM_NUM}" \
      User="jujharsingh@economist.com" \
      ownerArn="arn:aws:iam::975608782524:user/jujharsingh@economist.com"