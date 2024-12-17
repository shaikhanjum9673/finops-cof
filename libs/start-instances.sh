#!/bin/bash
#
#

# ----------------------- FUNCTION -------------------------
# NAME: start_ec2
# DESCRIPTION:
# -----------------------------------------------------------
start_ec2(){

  instance=$1

  # Sanity check
  instance_state=$(aws ec2 describe-instances --instance-id ${instance} --query "Reservations[].Instances[].State.Name" --output text)

  if [[ $instance_state == "stopped" ]]; then
    echo "INFO: Instance is in stopped state, starting instance ${instance}..."
    aws ec2 start-instances --instance-ids ${instance} > /dev/null
  else
    echo "INFO: Instance ${instance} is already in running state."
  fi
}

# ----------------------- FUNCTION -------------------------
# NAME: start_azvm
# DESCRIPTION:
# -----------------------------------------------------------
start_azvm(){

  instance=$1

  azvm_rg=$(az vm list --query "[?name=='$instance'].resourceGroup" -o tsv)
  azvm_state=$(az vm show -d --name $instance -g $azvm_rg --query 'powerState' -o tsv | awk '{print $NF}')

  if [[ $azvm_state == "deallocated" ]]; then
    echo "INFO: VM is in deallocated state, starting vm ${instance}..."
    az vm start --name ${instance} --resource-group ${azvm_rg} --no-wait
  else
    echo "INFO: VM ${instance} is already in running state."
  fi
}

# ====================================
# AWS: Start ec2 instance
# ====================================
for instance_id in $(aws ec2 describe-instances --filter "Name=tag:shutdown,Values=true" --query "Reservations[].Instances[].InstanceId" --output text)
do
  start_ec2 $instance_id
done

# ====================================
# Azure: Start azvm
# ====================================
for instance in $(az vm list --query "[?tags.shutdown=='true'].name" -o tsv)
do
  start_azvm $instance
done