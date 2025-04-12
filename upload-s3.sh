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

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "Error: AWS CLI is not installed. Please install it first:"
  echo "  macOS: brew install awscli"
  echo "  Linux: pip install awscli"
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

# Configure AWS CLI if not already configured
if [ ! -f ~/.aws/credentials ] || ! grep -q "\[hetzner\]" ~/.aws/credentials; then
  echo "Configuring AWS CLI for Hetzner Object Storage..."
  mkdir -p ~/.aws
  cat >> ~/.aws/credentials << EOF
[hetzner]
aws_access_key_id = ${AWS_ACCESS_KEY_ID:-your_access_key}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY:-your_secret_key}
EOF
  echo "AWS credentials configured."
fi

# Upload to Hetzner Object Storage (S3)
echo "Uploading data to Hetzner Object Storage..."
aws s3 cp ./output/contracts.json s3://${HETZNER_BUCKET_NAME:-your-bucket-name}/ \
  --endpoint-url http://5.161.70.165:9000 \
  --profile hetzner
echo "Upload complete!"
