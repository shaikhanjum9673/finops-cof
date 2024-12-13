#!/bin/bash


# Define variables
CREDENTIAL_FILE=".cof/csp_auth.yaml"

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
aws configure set output${AWS_OUTPUT}

# Validate login
aws sts get-caller-identity


# Azure login
az login --service-principal \
  -u ${AZURE_CLIENT_ID} \
  -p  ${AZURE_CLIENT_SECRET} \
  --tenant ${AZURE_TENANT_ID} \
  --allow-no-subscriptions

# Validate login
az account show
az ad sp show --id ${AZURE_CLIENT_ID}