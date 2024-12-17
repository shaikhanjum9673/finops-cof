#!/bin/bash
#
#
#

# ------------- FUNCTION ----------------------
# NAME: script_usage
# DESCRIPTION:
# ----------------------------------------------------
script_usage() {
  echo
  echo "USAGE:"
  echo "  sudo ./$0 --action <start|stop>"
}


# ============================================================
# ======================= MAIN PROGRAM ========================
# ============================================================
MAIL_RECIPIENT="shaikhanjum9673@gmail.com"
MAIL_FROM="noreply-cof@rtlab.com"
MAIL_COTENT="rendered-email-content.html"


if [[ $# -eq 0 ]]; then
  echo "ERROR: Missing required script parameter"
  script_usage
  exit 1
fi


if [[ $1 == "--action" ]]; then
  APP_ACTION=$2
else
  echo "ERROR: Unrecognized parameter provided to script, $1"
  script_usage
  exit 1
fi


# Install cloud cli tools
. libs/install-aws-cli.sh
. libs/install-azure-cli.sh

# Authenticate to cloud
if [[ -f ~/.cof/csp_auth.yaml ]]; then
  . libs/csp-authentication.sh ~/.cof/csp_auth.yaml
elif [[ -f .cof/csp_auth.yaml ]]; then
  . libs/csp-authentication.sh .cof/csp_auth.yaml
else
  echo "ERROR: Authentication file not found at default locations. Check README.md for authN details."
  exit 1
fi

# Perform instance start/stop action
if [[ ${APP_ACTION} == "stop" ]]; then
  . libs/stop-instances.sh
elif [[ ${APP_ACTION} == "start" ]]; then
  . libs/start-instances.sh
else
  echo "ERROR: Wrong value provided for parameter --action: ${APP_ACTION}"
  script_usage
  exit 1
fi

# Capture instance state
. libs/capture-instance-state-csv.sh

# Generate HTML report
. libs/generate-html-report.sh

# ----------------------------------
# Send email notification
# ----------------------------------
if [[ ! -f ${MAIL_COTENT} ]]; then
  echo "ERROR: Email template file '${MAIL_COTENT}' missing/not found."
  exit 1
fi

sendmail $MAIL_RECIPIENT <<EOF
From: $MAIL_FROM
To: $MAIL_RECIPIENT
Subject: Daily Instance Schedule Report
Content-Type: text/html

$(cat ${MAIL_COTENT})
EOF

if [[ $? -eq 0 ]]; then
  echo "INFO: Email sent to all recipient(s) successfully."
fi