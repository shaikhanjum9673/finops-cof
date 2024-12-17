#!/bin/bash
#
#

# Define variables
CSV_INSTANCE_REPORT="instance-report.csv"
HTML_TEMPLATE_FILE="templates/emailBody.html.tpl"
RENDERED_HTML_FILE="rendered-email-content.html"

for line in $(awk 'NR > 1' $CSV_INSTANCE_REPORT); do

  csp=$(echo "$line" | awk -F"," '{print $1}')
  instance_name=$(echo "$line" | awk -F"," '{print $2}')
  instance_ip=$(echo "$line" | awk -F"," '{print $3}')
  instance_state=$(echo "$line" | awk -F"," '{print $4}')
  instance_schedule_time=$(echo "$line" | awk -F"," '{print $5}')
  instance_tag=$(echo "$line" | awk -F"," '{print $6}')

  TABLE_ROWS+="
  <tr>
    <td>$csp</td>
    <td>$instance_name</td>
    <td>$instance_ip</td>
    <td>$instance_state</td>
    <td>$instance_schedule_time</td>
    <td>$instance_tag</td>
  </tr>
  "
done

# Read HTML template and store in variable
HTML_TEMPLATE=$(cat "$HTML_TEMPLATE_FILE")

# Replace the placeholder with actual table rows using bash parameter expansion
# ${variable//pattern/replacement}
HTML_TEMPLATE=${HTML_TEMPLATE//__TABLE_ROWS_PLACEHOLDER__/$TABLE_ROWS}
HTML_TEMPLATE=${HTML_TEMPLATE//__TIMESTAMP__/$(date)}

# Write HTML template to the output file
echo "$HTML_TEMPLATE" > $RENDERED_HTML_FILE

echo "INFO: HTML email template with table rows and data has been generated. Output file: ${RENDERED_HTML_FILE}"