#!/bin/bash
# Script to connect to Hetzner server using IPv4 only

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

echo -e "${BLUE}=== Connecting to Hetzner Server via IPv4 ===${NC}"
echo ""

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}

echo -e "Server IP: ${YELLOW}$HETZNER_IP${NC}"
echo -e "Username: ${YELLOW}$HETZNER_USER${NC}"
echo -e "Forcing IPv4 connection"
echo ""

# Test IPv4 connection
echo -e "${BLUE}Testing IPv4 connection...${NC}"
if ping -4 -c 3 -W 5 $HETZNER_IP > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Server is reachable via IPv4 ping${NC}"
else
  echo -e "${RED}✗ Cannot ping the server via IPv4${NC}"
  echo -e "  This could mean:"
  echo -e "  - The server is offline"
  echo -e "  - The IP address is incorrect"
  echo -e "  - ICMP (ping) is blocked by a firewall"
  echo ""
  echo -e "Trying SSH connection anyway..."
fi

# Try SSH connection with IPv4 only
echo ""
echo -e "${BLUE}Attempting SSH connection via IPv4...${NC}"
ssh -4 -v -o ConnectTimeout=10 ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ SSH connection successful${NC}"
  echo ""
  echo -e "${BLUE}=== Next Steps ===${NC}"
  echo ""
  echo -e "1. Now that you can connect to your Hetzner server, you can run:"
  echo -e "   ./sync-data.sh"
  echo -e "   ./setup-git-repo.sh"
  echo -e "   ./setup-dashboard.sh"
  echo ""
  echo -e "2. To always force IPv4 connections, you can add this to your ~/.ssh/config file:"
  echo -e "   Host $HETZNER_IP"
  echo -e "       AddressFamily inet"
  echo -e "       User $HETZNER_USER"
else
  echo -e "${RED}✗ SSH connection failed${NC}"
  echo ""
  echo -e "${BLUE}=== Alternative Options ===${NC}"
  echo ""
  echo -e "Option 1: Use the local script instead of Hetzner"
  echo -e "  Run: ./sync-data-local.sh"
  echo ""
  echo -e "Option 2: Use GitHub for repository hosting"
  echo -e "  git remote add origin git@github.com:PaulieB14/substreams-contract-reviewer.git"
  echo -e "  git push -u origin master"
fi
