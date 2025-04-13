#!/bin/bash
# Setup script for Substreams Contract Reviewer

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Substreams Contract Reviewer Setup ===${NC}"
echo ""

# Check if Rust is installed
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    echo -e "${GREEN}✓ Rust is installed:${NC} $RUST_VERSION"
else
    echo -e "${RED}✗ Rust is not installed${NC}"
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
fi

# Install wasm32-unknown-unknown target
echo ""
echo -e "${BLUE}Installing WebAssembly target...${NC}"
rustup target add wasm32-unknown-unknown
echo -e "${GREEN}✓ WebAssembly target installed${NC}"

# Check if Substreams CLI is installed
echo ""
echo -e "${BLUE}Checking Substreams CLI...${NC}"
if command -v substreams &> /dev/null; then
    SUBSTREAMS_VERSION=$(substreams --version)
    echo -e "${GREEN}✓ Substreams CLI is installed:${NC} $SUBSTREAMS_VERSION"
else
    echo -e "${YELLOW}! Substreams CLI is not installed${NC}"
    echo "Installing Substreams CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew tap streamingfast/tap
        brew install substreams
    else
        # Linux
        echo -e "${YELLOW}Please install Substreams CLI manually:${NC}"
        echo "Visit: https://substreams.streamingfast.io/getting-started/installing-the-cli"
    fi
fi

# Check if jq is installed
echo ""
echo -e "${BLUE}Checking jq...${NC}"
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    echo -e "${GREEN}✓ jq is installed:${NC} $JQ_VERSION"
else
    echo -e "${YELLOW}! jq is not installed${NC}"
    echo "Installing jq..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install jq
    else
        # Linux
        sudo apt-get update && sudo apt-get install -y jq
    fi
fi

# Check if rclone is installed
echo ""
echo -e "${BLUE}Checking rclone...${NC}"
if command -v rclone &> /dev/null; then
    RCLONE_VERSION=$(rclone --version | head -n 1)
    echo -e "${GREEN}✓ rclone is installed:${NC} $RCLONE_VERSION"
else
    echo -e "${YELLOW}! rclone is not installed${NC}"
    echo "Installing rclone..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install rclone
    else
        # Linux
        curl https://rclone.org/install.sh | sudo bash
    fi
fi

# Check if AWS CLI is installed
echo ""
echo -e "${BLUE}Checking AWS CLI...${NC}"
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version)
    echo -e "${GREEN}✓ AWS CLI is installed:${NC} $AWS_VERSION"
else
    echo -e "${YELLOW}! AWS CLI is not installed${NC}"
    echo "Installing AWS CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install awscli
    else
        # Linux
        echo -e "${YELLOW}Please install AWS CLI manually:${NC}"
        echo "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    fi
fi

# Create .env file if it doesn't exist
echo ""
echo -e "${BLUE}Setting up environment...${NC}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env file from example${NC}"
    else
        echo -e "${YELLOW}! .env.example not found, creating basic .env file${NC}"
        cat > .env << EOF
# Environment variables for Substreams Contract Reviewer

# Substreams API key
SUBSTREAMS_API_KEY=server_9dc03b3b92c9802bd3346befc0f6c0ab

# Hetzner credentials
HETZNER_IP=5.161.70.165
HETZNER_USERNAME=your_username
HETZNER_PASSWORD=your_password

# S3 credentials for Hetzner Object Storage
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
HETZNER_BUCKET_NAME=your_bucket_name
HETZNER_REGION=your_region
EOF
    fi
    echo -e "${YELLOW}! Please edit .env file with your credentials${NC}"
fi

# Ensure output directory exists
mkdir -p output
echo -e "${GREEN}✓ Created output directory${NC}"

# Make scripts executable
echo ""
echo -e "${BLUE}Making scripts executable...${NC}"
chmod +x *.sh
echo -e "${GREEN}✓ Scripts are now executable${NC}"

# Build the project
echo ""
echo -e "${BLUE}Building the project...${NC}"
cargo build --target wasm32-unknown-unknown --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
else
    echo -e "${RED}✗ Build failed. Please check the error messages above.${NC}"
fi

echo ""
echo -e "${BLUE}=== Setup Complete ===${NC}"
echo ""
echo -e "Next steps:"
echo -e "1. Edit the ${YELLOW}.env${NC} file with your credentials"
echo -e "2. Run ${YELLOW}./sync-data.sh${NC} or ${YELLOW}./upload-s3.sh${NC} to start collecting data"
echo -e "3. Use ${YELLOW}./monitor.sh${NC} to check the status of your setup"
