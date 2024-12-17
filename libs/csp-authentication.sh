#!/bin/bash

# Define variables
CREDENTIAL_FILE="$1"

AWS_ACCESS_KEY_ID=$(yq -r '.auth_configs.aws.access_key' $CREDENTIAL_FILE)
AWS_SECRET_ACCESS_KEY=$(yq -r '.auth_configs.aws.secret_access_key' $CREDENTIAL_FILE)
AWS_REGION=$(yq -r '.auth_configs.aws.region' $CREDENTIAL_FILE)
AWS_OUTPUT=$(yq -r '.auth_configs.aws.output' $CREDENTIAL_FILE)

AZURE_CLIENT_ID=$(yq -r '.auth_configs.azure.client_id' $CREDENTIAL_FILE)
AZURE_CLIENT_SECRET=$(yq -r '.auth_configs.azure.client_secret' $CREDENTIAL_FILE)
AZURE_TENANT_ID=$(yq -r '.auth_configs.azure.tenant' $CREDENTIAL_FILE)
# shellcheck disable=SC2034
SUBSCRIPTION_ID=$(yq -r '.auth_configs.azure.subscription_id' $CREDENTIAL_FILE)

# aws authenticate
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set region ${AWS_REGION}
aws configure set output ${AWS_OUTPUT}

# Validate login
if aws sts get-caller-identity >/dev/null 2>&1; then

  iam_username=$(aws sts get-caller-identity --query 'Arn' --output text)
  echo "INFO: Successfully logged in with AWS IAM User $iam_username"
else
  echo "ERROR: Unexpected error occured while authenticating with IAM User"
  exit 1
fi

# Azure login
az login --service-principal \
  -u ${AZURE_CLIENT_ID} \
  -p  ${AZURE_CLIENT_SECRET} \
  --tenant ${AZURE_TENANT_ID} \
  --allow-no-subscriptions > /dev/null

# Validate login
if az account show >/dev/null 2>&1; then

  az_spid="$(az account show --query 'user.name' -o tsv)"
  az_spname=$(az ad sp show --id $az_spid --query appDisplayName -o tsv)
  echo "INFO: Successfully logged in with Azure Service Principle $az_spname/$az_spid"
else
  echo "ERROR: Unexpected error occured while authenticating with Service Principle"
  exit 1
fi
