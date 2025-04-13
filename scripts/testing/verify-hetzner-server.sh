#!/bin/bash
# Script to verify if the Hetzner server is running and check the correct IP address

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Hetzner Server Verification ===${NC}"
echo ""

echo -e "This script will help you verify if your Hetzner server is actually running"
echo -e "and check if you're using the correct IP address."
echo ""

# Load current Hetzner IP from .env
if [ -f .env ]; then
  CURRENT_IP=$(grep "HETZNER_IP" .env | cut -d '=' -f2)
  echo -e "Current Hetzner IP in .env file: ${YELLOW}$CURRENT_IP${NC}"
else
  CURRENT_IP="5.161.70.165"
  echo -e "No .env file found. Using default IP: ${YELLOW}$CURRENT_IP${NC}"
fi
echo ""

echo -e "${BLUE}=== Manual Verification Steps ===${NC}"
echo ""
echo -e "1. Log in to your Hetzner Cloud Console:"
echo -e "   ${YELLOW}https://console.hetzner.cloud/${NC}"
echo ""
echo -e "2. Check if your server is running:"
echo -e "   - Look for a green status indicator next to your server name"
echo -e "   - If it's not green, your server might be stopped or deleted"
echo ""
echo -e "3. Verify the correct IP address:"
echo -e "   - Click on your server name to view its details"
echo -e "   - Look for the 'IPv4' address in the server details"
echo -e "   - Compare it with the IP in your .env file: ${YELLOW}$CURRENT_IP${NC}"
echo ""

echo -e "${BLUE}=== Automatic IP Verification ===${NC}"
echo ""
echo -e "Enter the IP address shown in your Hetzner Cloud Console:"
read -p "" CONSOLE_IP

if [ -z "$CONSOLE_IP" ]; then
  echo -e "${RED}No IP address entered. Skipping verification.${NC}"
else
  if [ "$CONSOLE_IP" = "$CURRENT_IP" ]; then
    echo -e "${GREEN}✓ The IP addresses match!${NC}"
    echo -e "Your .env file has the correct Hetzner IP address."
  else
    echo -e "${RED}✗ The IP addresses don't match!${NC}"
    echo -e "Your .env file has: ${YELLOW}$CURRENT_IP${NC}"
    echo -e "Hetzner Console shows: ${YELLOW}$CONSOLE_IP${NC}"
    
    echo -e "${YELLOW}Would you like to update the IP address in your .env file? (y/n)${NC}"
    read -p "" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Update .env file with new IP
      sed -i '' "s/HETZNER_IP=.*/HETZNER_IP=$CONSOLE_IP/" .env
      echo -e "${GREEN}✓ Updated Hetzner IP to $CONSOLE_IP in .env file${NC}"
      echo -e "Please run the connectivity tests again with the new IP."
    fi
  fi
fi
echo ""

echo -e "${BLUE}=== Server Status Verification ===${NC}"
echo ""
echo -e "Is your server showing as 'Running' in the Hetzner Cloud Console? (y/n)"
read -p "" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}✓ Server is running${NC}"
  echo -e "If you're still having connection issues, try the following:"
  echo -e "1. Run the advanced connectivity tests:"
  echo -e "   ${YELLOW}./test-hetzner-advanced.sh${NC}"
  echo -e "2. Check if your server has a firewall enabled in Hetzner Cloud Console"
  echo -e "3. Verify that port 22 (SSH) is open in the firewall rules"
else
  echo -e "${RED}✗ Server is not running${NC}"
  echo -e "Please start your server in the Hetzner Cloud Console:"
  echo -e "1. Select your server"
  echo -e "2. Click 'Power' and then 'Power On'"
  echo -e "3. Wait a few minutes for the server to start"
  echo -e "4. Run the connectivity tests again"
fi
echo ""

echo -e "${BLUE}=== Firewall Verification ===${NC}"
echo ""
echo -e "Does your server have a firewall enabled in Hetzner Cloud Console? (y/n)"
read -p "" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}! Firewall is enabled${NC}"
  echo -e "Please verify that your firewall rules allow:"
  echo -e "1. SSH (TCP port 22) from your IP address: $(curl -s ifconfig.me)"
  echo -e "2. Any other ports needed by your application"
  echo ""
  echo -e "To add a firewall rule in Hetzner Cloud Console:"
  echo -e "1. Go to 'Firewalls' section"
  echo -e "2. Select your firewall"
  echo -e "3. Click 'Add Rule'"
  echo -e "4. Direction: 'Inbound'"
  echo -e "5. Protocol: 'TCP'"
  echo -e "6. Port: '22'"
  echo -e "7. Source: 'Your IP address' ($(curl -s ifconfig.me))"
else
  echo -e "${GREEN}✓ No firewall enabled${NC}"
  echo -e "If you're still having connection issues, try the following:"
  echo -e "1. Check if your server has SSH enabled"
  echo -e "2. Verify that your SSH credentials are correct"
  echo -e "3. Try connecting with a different SSH client"
fi
echo ""

echo -e "${BLUE}=== Next Steps ===${NC}"
echo ""
echo -e "After verifying your server status and IP address:"
echo ""
echo -e "1. Run the advanced connectivity tests:"
echo -e "   ${YELLOW}./test-hetzner-advanced.sh${NC}"
echo ""
echo -e "2. If tests fail, try restarting your server in Hetzner Cloud Console:"
echo -e "   - Select your server"
echo -e "   - Click 'Power' and then 'Power Cycle' (restart)"
echo -e "   - Wait a few minutes and try connecting again"
echo ""
echo -e "3. If all else fails, consider creating a support ticket with Hetzner:"
echo -e "   ${YELLOW}https://www.hetzner.com/support${NC}"
echo ""
