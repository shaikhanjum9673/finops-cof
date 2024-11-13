#!/bin/bash
#
#
#

echo "INFO: Installing aws command line utility"
echo

# Perform sanity check
if command -v aws > /dev/null; then
  echo "INFO: AWS cli is already installed, skipping installation."
else
  echo "INFO: AWS command not found, proceeding with installation."

  # Update apt repo and install unzip
  apt update -y > /dev/null
  apt install curl unzip -y > /dev/null

  # Download aws zip package and store in tmp directory
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

  # Extract zip to /opt directory
  unzip /tmp/awscliv2.zip -d /opt > /dev/null

  # Delete zip file
  rm -f /tmp/awscliv2.zip

  /opt/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli

  # Post installation validation
  command -v aws > /dev/null

  RETURN_CODE=${?}

  if [[ ${RETURN_CODE} -ne 0 ]];then
    echo "ERROR: AWS cli installation failed with unexpected error."
  else
    echo "INFO: AWS cli installation completed successfully."
  fi
fi