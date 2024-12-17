#!/bin/bash
#
#

# ----------------------- FUNCTION -------------------------
# NAME: stop_ec2
# DESCRIPTION:
# -----------------------------------------------------------
stop_ec2(){

  instance=$1

  # Sanity check
  instance_state=$(aws ec2 describe-instances --instance-id ${instance} --query "Reservations[].Instances[].State.Name" --output text)

  if [[ $instance_state == "running" ]]; then
    echo "INFO: Instance is in running state, stopping instance ${instance}..."
    aws ec2 stop-instances --instance-ids ${instance} > /dev/null
  else
    echo "INFO: Instance ${instance} is already in stopped state."
  fi
}

# ----------------------- FUNCTION -------------------------
# NAME: stop_azvm
# DESCRIPTION:
# -----------------------------------------------------------
stop_azvm(){

  instance=$1

  azvm_rg=$(az vm list --query "[?name=='$instance'].resourceGroup" -o tsv)
  azvm_state=$(az vm show -d --name $instance -g $azvm_rg --query 'powerState' -o tsv | awk '{print $NF}')

  if [[ $azvm_state == "running" ]]; then
    echo "INFO: VM is in running state, deallocating vm ${instance}..."
    az vm deallocate --name ${instance} --resource-group ${azvm_rg} --no-wait
  else
    echo "INFO: VM ${instance} is already in deallocated state."
  fi
}

# ====================================
# AWS: Start ec2 instance
# ====================================
for instance_id in $(aws ec2 describe-instances --filter "Name=tag:shutdown,Values=true" --query "Reservations[].Instances[].InstanceId" --output text)
do
  stop_ec2 $instance_id
done

# ====================================
# Azure: Start azvm
# ====================================
for instance in $(az vm list --query "[?tags.shutdown=='true'].name" -o tsv)
do
  stop_azvm $instance
done