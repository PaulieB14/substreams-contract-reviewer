#!/bin/bash
# Comprehensive script to troubleshoot and fix Hetzner connection issues

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

echo -e "${BLUE}=== Hetzner Connection Troubleshooter ===${NC}"
echo ""

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}
HETZNER_PASS=${HETZNER_PASSWORD:-"password"}

echo -e "Current Hetzner Configuration:"
echo -e "  IP Address: ${YELLOW}$HETZNER_IP${NC}"
echo -e "  Username: ${YELLOW}$HETZNER_USER${NC}"
echo -e "  Password: ${YELLOW}${HETZNER_PASS:0:1}*****${NC}"
echo ""

# Step 1: Verify IP address format
echo -e "${BLUE}Step 1: Verifying IP address format${NC}"
if [[ $HETZNER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${GREEN}✓ IP address format is valid${NC}"
else
  echo -e "${RED}✗ IP address format is invalid${NC}"
  echo -e "  Please enter a valid IPv4 address in the .env file"
  echo -e "  Example: 123.456.789.012"
  exit 1
fi
echo ""

# Step 2: Check if the server is reachable via ping
echo -e "${BLUE}Step 2: Testing basic connectivity${NC}"
echo -e "Pinging $HETZNER_IP..."
if ping -c 1 -W 5 $HETZNER_IP > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Server is reachable via ping${NC}"
  PING_SUCCESS=true
else
  echo -e "${RED}✗ Cannot ping the server${NC}"
  echo -e "  This could mean:"
  echo -e "  - The server is offline"
  echo -e "  - The IP address is incorrect"
  echo -e "  - ICMP (ping) is blocked by a firewall"
  PING_SUCCESS=false
fi
echo ""

# Step 3: Check if port 22 is open
echo -e "${BLUE}Step 3: Checking if SSH port (22) is open${NC}"
if command -v nc &> /dev/null; then
  if nc -z -w 5 $HETZNER_IP 22 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ SSH port (22) is open${NC}"
    PORT_SUCCESS=true
  else
    echo -e "${RED}✗ SSH port (22) is closed or blocked${NC}"
    echo -e "  This could mean:"
    echo -e "  - SSH service is not running on the server"
    echo -e "  - A firewall is blocking port 22"
    echo -e "  - The server is using a non-standard SSH port"
    PORT_SUCCESS=false
  fi
else
  echo -e "${YELLOW}! Cannot check port 22 (nc command not available)${NC}"
  PORT_SUCCESS=false
fi
echo ""

# Step 4: Try SSH connection with timeout
echo -e "${BLUE}Step 4: Attempting SSH connection${NC}"
echo -e "Trying to connect via SSH (timeout: 5 seconds)..."
ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ${HETZNER_USER}@${HETZNER_IP} "echo 'Connection successful'" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ SSH connection successful${NC}"
  SSH_SUCCESS=true
else
  echo -e "${RED}✗ SSH connection failed${NC}"
  echo -e "  This could mean:"
  echo -e "  - The username or password is incorrect"
  echo -e "  - SSH key authentication is required"
  echo -e "  - The server is not accepting connections"
  SSH_SUCCESS=false
fi
echo ""

# Step 5: Check Hetzner Cloud Console
echo -e "${BLUE}Step 5: Hetzner Cloud Console Check${NC}"
echo -e "Please verify the following in your Hetzner Cloud Console:"
echo -e "1. The server is running (not stopped or deleted)"
echo -e "2. The correct IP address is being used"
echo -e "3. The firewall allows SSH connections from your IP"
echo -e "4. The server has SSH enabled"
echo ""
echo -e "Hetzner Cloud Console URL: ${YELLOW}https://console.hetzner.cloud/${NC}"
echo ""

# Step 6: Verify your current IP
echo -e "${BLUE}Step 6: Verifying your current IP address${NC}"
echo -e "Your current IPv4 address:"
CURRENT_IPV4=$(curl -s -4 ifconfig.me)
echo -e "${YELLOW}$CURRENT_IPV4${NC}"
echo ""
echo -e "Your current IPv6 address:"
CURRENT_IPV6=$(curl -s -6 ifconfig.me)
echo -e "${YELLOW}$CURRENT_IPV6${NC}"
echo ""
echo -e "Make sure your IP address is allowed in the Hetzner firewall rules."
echo ""

# Step 7: Provide recommendations
echo -e "${BLUE}=== Recommendations ===${NC}"
echo ""

if [ "$PING_SUCCESS" = false ] && [ "$PORT_SUCCESS" = false ] && [ "$SSH_SUCCESS" = false ]; then
  echo -e "${RED}Major connectivity issues detected${NC}"
  echo -e "Recommended actions:"
  echo -e "1. Verify the server is running in Hetzner Cloud Console"
  echo -e "2. Double-check the IP address in your .env file"
  echo -e "3. Create a new server if the current one is inaccessible"
  echo -e "4. Contact Hetzner support if issues persist"
  echo ""
  
  echo -e "${YELLOW}Would you like to update your Hetzner IP address? (y/n)${NC}"
  read -p "" -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "Please enter the new Hetzner IP address:"
    read NEW_IP
    if [[ $NEW_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      # Update .env file with new IP
      sed -i '' "s/HETZNER_IP=.*/HETZNER_IP=$NEW_IP/" .env
      echo -e "${GREEN}✓ Updated Hetzner IP to $NEW_IP in .env file${NC}"
      echo -e "Please run this script again to test the new IP."
    else
      echo -e "${RED}✗ Invalid IP address format${NC}"
    fi
  fi
elif [ "$SSH_SUCCESS" = false ]; then
  echo -e "${YELLOW}SSH authentication issues detected${NC}"
  echo -e "Recommended actions:"
  echo -e "1. Verify the username in your .env file (typically 'root' for new servers)"
  echo -e "2. Try password authentication:"
  echo -e "   sshpass -p \"$HETZNER_PASS\" ssh $HETZNER_USER@$HETZNER_IP"
  echo -e "3. Set up SSH key authentication:"
  echo -e "   ssh-copy-id $HETZNER_USER@$HETZNER_IP"
  echo ""
  
  echo -e "${YELLOW}Would you like to update your Hetzner username? (y/n)${NC}"
  read -p "" -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "Please enter the new Hetzner username:"
    read NEW_USER
    # Update .env file with new username
    sed -i '' "s/HETZNER_USERNAME=.*/HETZNER_USERNAME=$NEW_USER/" .env
    echo -e "${GREEN}✓ Updated Hetzner username to $NEW_USER in .env file${NC}"
    echo -e "Please run this script again to test the new username."
  fi
else
  echo -e "${GREEN}No major issues detected${NC}"
  echo -e "If you're still experiencing problems, consider:"
  echo -e "1. Checking server logs: ssh $HETZNER_USER@$HETZNER_IP 'tail -f /var/log/auth.log'"
  echo -e "2. Verifying SSH configuration: ssh $HETZNER_USER@$HETZNER_IP 'cat /etc/ssh/sshd_config'"
  echo -e "3. Restarting SSH service: ssh $HETZNER_USER@$HETZNER_IP 'systemctl restart sshd'"
fi

echo ""
echo -e "${BLUE}=== Additional Options ===${NC}"
echo ""
echo -e "1. Create a new Hetzner server:"
echo -e "   - Log in to Hetzner Cloud Console: https://console.hetzner.cloud/"
echo -e "   - Create a new server with SSH key authentication"
echo -e "   - Update the .env file with the new server details"
echo ""
echo -e "2. Use a different VPS provider:"
echo -e "   - DigitalOcean: https://www.digitalocean.com/"
echo -e "   - Linode: https://www.linode.com/"
echo -e "   - AWS EC2: https://aws.amazon.com/ec2/"
echo ""
echo -e "3. Use GitHub for code storage and a different storage solution:"
echo -e "   - GitHub: git@github.com:PaulieB14/substreams-contract-reviewer.git"
echo -e "   - AWS S3: https://aws.amazon.com/s3/"
echo -e "   - Google Cloud Storage: https://cloud.google.com/storage"
echo ""
