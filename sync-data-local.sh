#!/bin/bash
# Local version of sync-data.sh that doesn't require Hetzner server access

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

# Create a timestamp for the backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create a backup with timestamp
cp ./output/contracts.json "./output/contracts_${TIMESTAMP}.json"
echo "Backup created: ./output/contracts_${TIMESTAMP}.json"

# Optional: Compress the backup to save space
if command -v gzip &> /dev/null; then
  gzip -9 -f "./output/contracts_${TIMESTAMP}.json"
  echo "Backup compressed: ./output/contracts_${TIMESTAMP}.json.gz"
fi

echo "Local processing complete!"
echo ""
echo "To push your code to GitHub instead of Hetzner:"
echo "git remote add origin git@github.com:PaulieB14/substreams-contract-reviewer.git"
echo "git push -u origin master"
