#!/bin/bash

set -x

# Define variables
ROOT_USER_ID=0
CURRENT_USER_ID=$(id -u)

# Run main program
if [[ $CURRENT_USER_ID -eq $ROOT_USER_ID ]]; then
  echo "INFO: User with sudo privileg detected, proceeding with further execution."
else
  echo "ERROR: Please execute the script with sudo privilege user."
  echo "Current User ID: $CURRENT_USER_ID"
  exit 1
fi