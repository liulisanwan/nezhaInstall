#!/bin/bash

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        hostname=*)
        NODE_NAME="${arg#*=}"
        ;;
        token=*)
        NEZHA_TOKEN="${arg#*=}"
        ;;
        probe_address=*)
        NEZHA_PROBE_ADDRESS="${arg#*=}"
        ;;
        dashboard_url=*)
        NEZHA_DASHBOARD_URL="${arg#*=}"
        ;;
    esac
done

# Check if all required parameters are provided
if [ -z "${NEZHA_TOKEN}" ] || [ -z "${NEZHA_PROBE_ADDRESS}" ] || [ -z "${NEZHA_DASHBOARD_URL}" ]; then
    echo "错误：缺少必要参数"
    echo "使用方法："
    echo "./nezha_register.sh hostname=主机名 token=面板TOKEN probe_address=探针地址 dashboard_url=面板地址"
    echo "示例："
    echo "./nezha_register.sh hostname=server1 token=your_token probe_address=probe.example.com dashboard_url=https://nezha.example.com"
    exit 1
fi

# Set default hostname if not provided
NODE_NAME=${NODE_NAME:-$(hostname)}

# Set default probe port
NEZHA_PROBE_PORT="443"

# Send POST request and capture response and HTTP status code
response=$(curl -s -o response_body.json -w "%{http_code}" -X POST "${NEZHA_DASHBOARD_URL}/api/v1/server/register?simple=true" \
  -H "Content-Type: application/json" \
  -H "Authorization: ${NEZHA_TOKEN}" \
  -d "{\"Name\": \"${NODE_NAME}\", \"HideForGuest\": \"off\"}")

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