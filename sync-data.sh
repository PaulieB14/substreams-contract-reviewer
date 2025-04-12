#!/bin/bash
# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Ensure output directory exists
mkdir -p ./output

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it first:"
  echo "  macOS: brew install jq"
  echo "  Linux: sudo apt-get install jq"
  exit 1
fi

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
  echo "Error: rclone is not installed. Please install it first:"
  echo "  macOS: brew install rclone"
  echo "  Linux: curl https://rclone.org/install.sh | sudo bash"
  exit 1
fi

# Run substreams and save output
# Note: The API key is passed via the authentication header in the endpoint URL
ENDPOINT="mainnet.eth.streamingfast.io:443"
if [ -n "$SUBSTREAMS_API_KEY" ]; then
  ENDPOINT="${SUBSTREAMS_API_KEY}@${ENDPOINT}"
fi

echo "Running Substreams to collect contract data..."
substreams run -e $ENDPOINT \
  substreams.yaml map_contract_usage \
  --start-block 16000000 --stop-block +1000 \
  | jq -c '.contracts[]' > ./output/contracts.json

echo "Data saved to ./output/contracts.json"

# Configure rclone if not already configured
if ! rclone listremotes | grep -q "hetzner:"; then
  echo "Configuring rclone for Hetzner Storage Box..."
  rclone config create hetzner sftp \
    host=5.161.70.165 \
    user=${HETZNER_USERNAME:-your-username} \
    pass=${HETZNER_PASSWORD:-your-password}
fi

# Sync to Hetzner Storage Box using rclone
echo "Syncing data to Hetzner Storage Box..."
rclone copy ./output hetzner:substreams-data
echo "Sync complete!"
