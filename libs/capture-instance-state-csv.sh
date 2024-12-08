#!/bin/bash
#
#

OUTPUT_CSV_FILE="instance-report.csv"

echo "CLOUD_PROVIDER,INSTANCE_NAME,INSTANCE_IP,INSTANCE_STATE,DATE,TAGS" > $OUTPUT_CSV_FILE

# ====================================
# AWS: Capture aws ec2 instance state
# ====================================
for instance_id in $(aws ec2 describe-instances --filter "Name=tag:shutdown,Values=true" --query "Reservations[].Instances[].InstanceId" --output text)
do

  echo "INFO: fetching details of AWS instance id ${instance_id}."

  instance_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${instance_id}" --query "Tags[?Key=='Name'].Value" --output text)
  instance_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance_name}" --query 'Reservations[].Instances[].PrivateIpAddress' --output text)
  instance_state=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${instance_name}" --query 'Reservations[].Instances[].State.Name' --output text)
  datestamp=$(date +%Y%m%d-%H%M%S)

  echo "aws,$instance_name,$instance_ip,$instance_state,$datestamp,shutdown" >> $OUTPUT_CSV_FILE

done

# ============================================
# Azure: Capture azure virtual machine state
# ============================================

for instance in $(az vm list --query "[?tags.shutdown=='true'].name" -o tsv)
do

  echo "INFO: fetching details of Azure Virtual Machine for ${instance}."

  azvm_rg=$(az vm list --query "[?name=='$instance'].resourceGroup" -o tsv)
  azvm_ip=$(az vm show -d --name $instance -g $azvm_rg --query 'privateIps' -o tsv)
  azvm_state=$(az vm show -d --name $instance -g $azvm_rg --query 'powerState' -o tsv | awk '{print $NF}')
  datestamp=$(date +%Y%m%d-%H%M%S)

  echo "azure,$instance,$azvm_ip,$azvm_state,$datestamp,shutdown" >> $OUTPUT_CSV_FILE

done