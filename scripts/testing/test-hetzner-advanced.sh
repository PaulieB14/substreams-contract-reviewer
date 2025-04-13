#!/bin/bash
# Advanced script to test Hetzner server connectivity using curl and SSH

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

echo -e "${BLUE}=== Advanced Hetzner Connectivity Tests ===${NC}"
echo ""

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}
HETZNER_PASS=${HETZNER_PASSWORD:-"password"}

echo -e "Current Hetzner Configuration:"
echo -e "  IP Address: ${YELLOW}$HETZNER_IP${NC}"
echo -e "  Username: ${YELLOW}$HETZNER_USER${NC}"
echo ""

# Test 1: Basic curl test to port 80
echo -e "${BLUE}Test 1: Basic curl to port 80${NC}"
echo -e "Attempting to connect to http://$HETZNER_IP..."
curl -s --connect-timeout 5 http://$HETZNER_IP > /dev/null
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Successfully connected to port 80${NC}"
else
  echo -e "${RED}✗ Failed to connect to port 80${NC}"
fi
echo ""

# Test 2: Verbose curl test to port 80
echo -e "${BLUE}Test 2: Verbose curl to port 80${NC}"
echo -e "Attempting to connect to http://$HETZNER_IP with verbose output..."
curl -v --connect-timeout 5 http://$HETZNER_IP 2>&1 | grep -E "Connected to|Failed to connect"
echo ""

# Test 3: Curl test to port 22 (SSH)
echo -e "${BLUE}Test 3: Curl to port 22 (SSH)${NC}"
echo -e "Attempting to connect to port 22..."
curl -v --connect-timeout 5 telnet://$HETZNER_IP:22 2>&1 | grep -E "Connected to|Failed to connect"
echo ""

# Test 4: Telnet to port 22
echo -e "${BLUE}Test 4: Telnet to port 22${NC}"
echo -e "Attempting to connect to port 22 using telnet..."
if command -v telnet &> /dev/null; then
  timeout 5 telnet $HETZNER_IP 22 2>&1 | grep -E "Connected to|Connection refused|timed out"
else
  echo -e "${YELLOW}! Telnet command not available${NC}"
fi
echo ""

# Test 5: SSH with verbose output
echo -e "${BLUE}Test 5: SSH with verbose output${NC}"
echo -e "Attempting SSH connection with verbose output..."
ssh -v -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'" 2>&1 | grep -E "debug1:|Connection|Authentication|Permission denied"
echo ""

# Test 6: SSH with different options
echo -e "${BLUE}Test 6: SSH with different options${NC}"
echo -e "Attempting SSH connection with different options..."
echo -e "1. Force IPv4:"
ssh -4 -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'" 2>&1 | grep -E "debug1:|Connection|Authentication|Permission denied"
echo ""
echo -e "2. Force protocol version 2:"
ssh -2 -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'" 2>&1 | grep -E "debug1:|Connection|Authentication|Permission denied"
echo ""
echo -e "3. With password authentication:"
if command -v sshpass &> /dev/null; then
  sshpass -p "$HETZNER_PASS" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'" 2>&1 | grep -E "debug1:|Connection|Authentication|Permission denied"
else
  echo -e "${YELLOW}! sshpass command not available. Install with 'brew install hudochenkov/sshpass/sshpass' on macOS${NC}"
fi
echo ""

# Test 7: Check if server is behind a firewall
echo -e "${BLUE}Test 7: Checking if server is behind a firewall${NC}"
echo -e "Attempting to connect to common ports..."
for port in 21 22 25 80 443 3306 8080; do
  echo -n "Port $port: "
  nc -z -w 2 $HETZNER_IP $port 2>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Open${NC}"
  else
    echo -e "${RED}Closed${NC}"
  fi
done
echo ""

# Test 8: Traceroute to server
echo -e "${BLUE}Test 8: Traceroute to server${NC}"
echo -e "Tracing route to $HETZNER_IP..."
if command -v traceroute &> /dev/null; then
  traceroute -m 10 -w 2 $HETZNER_IP
else
  echo -e "${YELLOW}! traceroute command not available${NC}"
fi
echo ""

# Test 9: Check DNS resolution
echo -e "${BLUE}Test 9: Checking DNS resolution${NC}"
echo -e "Attempting to resolve $HETZNER_IP to hostname..."
host $HETZNER_IP 2>/dev/null || echo -e "${YELLOW}! No hostname found for $HETZNER_IP${NC}"
echo ""

echo -e "${BLUE}=== Recommendations ===${NC}"
echo ""
echo -e "Based on the test results, consider the following:"
echo ""
echo -e "1. If all connection attempts failed:"
echo -e "   - The server may be offline or the IP address is incorrect"
echo -e "   - There may be a firewall blocking all incoming connections"
echo -e "   - The network route to the server may be blocked"
echo ""
echo -e "2. If SSH connections specifically failed:"
echo -e "   - SSH service may not be running on the server"
echo -e "   - SSH may be configured to use a non-standard port"
echo -e "   - SSH may be configured to only allow key-based authentication"
echo ""
echo -e "3. Try these manual commands:"
echo -e "   - Direct SSH: ssh -v $HETZNER_USER@$HETZNER_IP"
echo -e "   - With timeout: ssh -v -o ConnectTimeout=10 $HETZNER_USER@$HETZNER_IP"
echo -e "   - With password: sshpass -p \"$HETZNER_PASS\" ssh $HETZNER_USER@$HETZNER_IP"
echo ""
echo -e "4. Contact Hetzner support with these test results"
echo -e "   - Support URL: https://www.hetzner.com/support"
echo ""
