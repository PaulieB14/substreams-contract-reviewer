#!/bin/bash
# Script to test connection to Hetzner server

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Testing Hetzner Server Connection ===${NC}"
echo ""

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}

echo -e "Server IP: ${YELLOW}$HETZNER_IP${NC}"
echo -e "Username: ${YELLOW}$HETZNER_USER${NC}"
echo ""

# Test 1: Basic ping
echo -e "${BLUE}Test 1: Ping the server${NC}"
if ping -c 3 -W 5 $HETZNER_IP > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Server is reachable via ping${NC}"
else
  echo -e "${RED}✗ Cannot ping the server${NC}"
  echo -e "  This could mean:"
  echo -e "  - The server is offline"
  echo -e "  - The IP address is incorrect"
  echo -e "  - ICMP (ping) is blocked by a firewall"
fi
echo ""

# Test 2: Check if port 22 is open
echo -e "${BLUE}Test 2: Check if SSH port (22) is open${NC}"
if nc -z -w 5 $HETZNER_IP 22 > /dev/null 2>&1; then
  echo -e "${GREEN}✓ SSH port (22) is open${NC}"
else
  echo -e "${RED}✗ SSH port (22) is closed or blocked${NC}"
  echo -e "  This could mean:"
  echo -e "  - SSH service is not running on the server"
  echo -e "  - A firewall is blocking port 22"
  echo -e "  - The server is using a non-standard SSH port"
fi
echo ""

# Test 3: Try SSH connection with timeout
echo -e "${BLUE}Test 3: Attempt SSH connection${NC}"
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ SSH connection successful${NC}"
else
  echo -e "${RED}✗ SSH connection failed${NC}"
  echo -e "  This could mean:"
  echo -e "  - The username or password is incorrect"
  echo -e "  - SSH key authentication is required"
  echo -e "  - The server is not accepting connections"
fi
echo ""

echo -e "${BLUE}=== Troubleshooting Tips ===${NC}"
echo ""
echo -e "1. Verify your Hetzner server is running and accessible"
echo -e "2. Check that the IP address in your .env file is correct"
echo -e "3. Ensure your Hetzner server has SSH enabled and port 22 is open"
echo -e "4. Verify the username in your .env file is correct (typically 'root' for new servers)"
echo -e "5. If using SSH key authentication, ensure your key is properly set up:"
echo -e "   ssh-copy-id ${HETZNER_USER}@${HETZNER_IP}"
echo ""
echo -e "6. If you're using GitHub instead of Hetzner for repository hosting:"
echo -e "   - Update your scripts to use your GitHub repository"
echo -e "   - Run: git remote add origin git@github.com:PaulieB14/substreams-contract-reviewer.git"
echo -e "   - Push your code: git push -u origin master"
echo ""
echo -e "${BLUE}=== Alternative Setup Without Hetzner ===${NC}"
echo ""
echo -e "You can still use the Substreams Contract Reviewer without a Hetzner server:"
echo -e ""
echo -e "1. For data storage, use local storage instead:"
echo -e "   - Data will be saved to the ./output directory"
echo -e "   - Modify scripts to remove Hetzner-specific parts"
echo -e ""
echo -e "2. For repository hosting, use GitHub:"
echo -e "   git remote add origin git@github.com:PaulieB14/substreams-contract-reviewer.git"
echo -e "   git push -u origin master"
echo -e ""
echo -e "3. Run Substreams locally:"
echo -e "   ./sync-data-local.sh (create this by modifying sync-data.sh to remove Hetzner parts)"
echo ""
