#!/bin/bash
# Monitoring script for Substreams Contract Reviewer

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Substreams Contract Reviewer Monitoring ===${NC}"
echo ""

# Check local environment
echo -e "${BLUE}Checking local environment...${NC}"

# Check if Rust is installed
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    echo -e "${GREEN}✓ Rust is installed:${NC} $RUST_VERSION"
else
    echo -e "${RED}✗ Rust is not installed${NC}"
fi

# Check if Substreams CLI is installed
if command -v substreams &> /dev/null; then
    SUBSTREAMS_VERSION=$(substreams --version)
    echo -e "${GREEN}✓ Substreams CLI is installed:${NC} $SUBSTREAMS_VERSION"
else
    echo -e "${RED}✗ Substreams CLI is not installed${NC}"
fi

# Check if jq is installed
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    echo -e "${GREEN}✓ jq is installed:${NC} $JQ_VERSION"
else
    echo -e "${RED}✗ jq is not installed${NC}"
fi

# Check if rclone is installed
if command -v rclone &> /dev/null; then
    RCLONE_VERSION=$(rclone --version | head -n 1)
    echo -e "${GREEN}✓ rclone is installed:${NC} $RCLONE_VERSION"
else
    echo -e "${RED}✗ rclone is not installed${NC}"
fi

# Check if AWS CLI is installed
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version)
    echo -e "${GREEN}✓ AWS CLI is installed:${NC} $AWS_VERSION"
else
    echo -e "${RED}✗ AWS CLI is not installed${NC}"
fi

echo ""
echo -e "${BLUE}Checking project files...${NC}"

# Check if WASM file exists
if [ -f "./target/wasm32-unknown-unknown/release/contract_reviewer.wasm" ]; then
    WASM_SIZE=$(du -h "./target/wasm32-unknown-unknown/release/contract_reviewer.wasm" | cut -f1)
    echo -e "${GREEN}✓ WASM file exists:${NC} $WASM_SIZE"
else
    echo -e "${YELLOW}! WASM file not found. Run 'cargo build --target wasm32-unknown-unknown --release'${NC}"
fi

# Check output directory
if [ -d "./output" ]; then
    OUTPUT_FILES=$(find ./output -type f | wc -l)
    OUTPUT_SIZE=$(du -sh ./output | cut -f1)
    echo -e "${GREEN}✓ Output directory exists:${NC} $OUTPUT_FILES files, $OUTPUT_SIZE"
else
    echo -e "${YELLOW}! Output directory not found${NC}"
fi

echo ""
echo -e "${BLUE}Checking Hetzner connection...${NC}"

# Check if we can connect to Hetzner
if ssh -q -o BatchMode=yes -o ConnectTimeout=5 ${HETZNER_USER}@${HETZNER_IP} exit; then
    echo -e "${GREEN}✓ SSH connection to Hetzner server successful${NC}"
    
    # Check storage usage on Hetzner
    echo ""
    echo -e "${BLUE}Checking Hetzner storage...${NC}"
    
    # For Storage Box (using rclone)
    if command -v rclone &> /dev/null && rclone listremotes | grep -q "hetzner:"; then
        STORAGE_SIZE=$(rclone size hetzner:substreams-data 2>/dev/null || echo "Unable to get size")
        echo -e "${GREEN}✓ Storage Box:${NC} $STORAGE_SIZE"
    else
        echo -e "${YELLOW}! Storage Box not configured or accessible${NC}"
    fi
    
    # For Object Storage (using AWS CLI)
    if command -v aws &> /dev/null; then
        if aws s3 ls --endpoint-url http://${HETZNER_IP}:9000 --profile hetzner s3://${HETZNER_BUCKET_NAME:-your-bucket-name} &>/dev/null; then
            BUCKET_SIZE=$(aws s3 ls --endpoint-url http://${HETZNER_IP}:9000 --profile hetzner s3://${HETZNER_BUCKET_NAME:-your-bucket-name} --recursive --human-readable --summarize | grep "Total Size" || echo "Unable to get size")
            echo -e "${GREEN}✓ Object Storage:${NC} $BUCKET_SIZE"
        else
            echo -e "${YELLOW}! Object Storage not configured or accessible${NC}"
        fi
    fi
    
    # Check web server
    echo ""
    echo -e "${BLUE}Checking web dashboard...${NC}"
    if curl -s --head --request GET http://${HETZNER_IP} | grep "200 OK" > /dev/null; then
        echo -e "${GREEN}✓ Web dashboard is accessible${NC}"
    else
        echo -e "${YELLOW}! Web dashboard is not accessible${NC}"
    fi
else
    echo -e "${RED}✗ Cannot connect to Hetzner server${NC}"
fi

echo ""
echo -e "${BLUE}=== Monitoring Complete ===${NC}"
