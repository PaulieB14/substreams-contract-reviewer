#!/bin/bash
# Incremental sync script for Substreams Contract Reviewer

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Configuration
STATE_FILE="./output/last_block.txt"
BLOCK_CHUNK=1000
DEFAULT_START_BLOCK=16000000

# Ensure output directory exists
mkdir -p ./output

# Get the last processed block or use default
if [ -f "$STATE_FILE" ]; then
    LAST_BLOCK=$(cat "$STATE_FILE")
    START_BLOCK=$((LAST_BLOCK + 1))
else
    START_BLOCK=$DEFAULT_START_BLOCK
fi

# Get current block height (this is a placeholder - in production you'd query an Ethereum node)
# For example: CURRENT_BLOCK=$(curl -s https://api.etherscan.io/api?module=proxy&action=eth_blockNumber | jq -r '.result' | printf "%d" "$(xargs echo $((16#$(cut -c 3-))))")
CURRENT_BLOCK=$((START_BLOCK + BLOCK_CHUNK))  # Placeholder for demo purposes

echo "Processing blocks from $START_BLOCK to $CURRENT_BLOCK"

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

# Run substreams for the incremental block range
# Note: The API key is passed via the authentication header in the endpoint URL
ENDPOINT="mainnet.eth.streamingfast.io:443"
if [ -n "$SUBSTREAMS_API_KEY" ]; then
  ENDPOINT="${SUBSTREAMS_API_KEY}@${ENDPOINT}"
fi

echo "Processing blocks from $START_BLOCK to $CURRENT_BLOCK..."
substreams run -e $ENDPOINT \
  substreams.yaml map_contract_usage \
  --start-block $START_BLOCK --stop-block $CURRENT_BLOCK \
  | jq -c '.contracts[]' > "./output/contracts_${START_BLOCK}_${CURRENT_BLOCK}.json"

# Update the state file with the last processed block
echo $CURRENT_BLOCK > "$STATE_FILE"
echo "Updated state file with last processed block: $CURRENT_BLOCK"

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

echo "Completed processing up to block $CURRENT_BLOCK"
