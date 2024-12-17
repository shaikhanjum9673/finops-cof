#!/bin/bash
#
#
#
# NOTE: detect secret only detect secret once changes are added to staging area (git add .)

# set -x

DETECT_SECRET=$(command -v detect-secrets)

if [ -z "${DETECT_SECRET}" ]; then
  sudo apt install python3 python3-pip -y > /dev/null

  # Install secret-detect using pip
  pip install detect-secrets

  if command -v detect-secrets > /dev/null; then
    DETECT_SECRET=$(command -v detect-secrets)
  else
    # Add detect-secret path to shell PATH variable
    echo PATH=$PATH:~/.local/bin >> ~/.bashrc

  DETECT_SECRET=~/.local/bin/detect-secrets
  fi
fi

# $DETECT_SECRET scan --exclude-files README.md --all-files | jq -r '.results | keys[]' | wc -l

if [[ $($DETECT_SECRET scan --exclude-files README.md | jq -r '.results | keys[]' | wc -l) -ne 0 ]]; then
  echo -e "\n============================================"
  echo "ERROR: Sensitive information detected."
  echo -e "============================================\n"

  # ${DETECT_SECRET} scan | jq -r '.results | .[]'
${DETECT_SECRET} scan --exclude-files README.md | jq -r '.results | .[]'

  exit 1
fi
