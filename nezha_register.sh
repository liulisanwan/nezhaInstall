#!/bin/bash

# Exit if NEZHA_TOKEN is not set
if [ -z "${NEZHA_TOKEN}" ]; then
    echo "NEZHA_TOKEN is not set. Exiting."
    exit 0
fi

# Set default values if variables are not set
NEZHA_PROBE_ADDRESS="${NEZHA_PROBE_ADDRESS:-probe.example.com}"
NEZHA_PROBE_PORT="${NEZHA_PROBE_PORT:-5555}"
NEZHA_DASHBOARD_URL="${NEZHA_DASHBOARD_URL:-https://nezha.example.com}"

NODE_NAME=${NODE_NAME:-$(hostname)}

# Send POST request and capture response and HTTP status code
response=$(curl -s -o response_body.json -w "%{http_code}" -X POST "${NEZHA_DASHBOARD_URL}/api/v1/server/register?simple=true" \
  -H "Content-Type: application/json" \
  -H "Authorization: ${NEZHA_TOKEN}" \
  -d "{\"Name\": \"${NODE_NAME}\"}")

# Extract HTTP status code and Nezha secret
HTTP_CODE="$response"
NEZHA_SECRET=$(cat response_body.json)
rm -f response_body.json

if [ "$HTTP_CODE" != "200" ]; then
    echo "Failed to get Nezha Secret. HTTP status code: $HTTP_CODE"
    exit 1
fi

# Additional check for NEZHA_SECRET to ensure it's not JSON-formatted (indicating failure)
if [[ "${NEZHA_SECRET:0:1}" == "{" ]]; then
    echo "Failed to get Nezha Secret. Received response: ${NEZHA_SECRET}"
    exit 1
fi

# Download and execute the install script with cleanup
curl -fsSL https://raw.githubusercontent.com/nezhahq/scripts/main/install.sh -o nezha.sh && \
chmod +x nezha.sh || { echo "Failed to download or make the script executable"; exit 1; }

# Clean up nezha.sh on exit
trap 'rm -f nezha.sh' EXIT

# Run the Nezha agent installation script
CMD="./nezha.sh install_agent "${NEZHA_PROBE_ADDRESS}" "${NEZHA_PROBE_PORT}" "${NEZHA_SECRET}" --tls"

echo "Run commnad : ${CMD}"

eval $CMD