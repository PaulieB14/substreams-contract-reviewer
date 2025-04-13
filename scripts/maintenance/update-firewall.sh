#!/bin/bash
# Script to help update Hetzner firewall rules

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Hetzner Firewall Update Helper ===${NC}"
echo ""

# Get current IP addresses
IPV4=$(curl -s -4 ifconfig.me)
IPV6=$(curl -s -6 ifconfig.me)

echo -e "Your current IPv4 address: ${YELLOW}$IPV4${NC}"
echo -e "Your current IPv6 address: ${YELLOW}$IPV6${NC}"
echo ""

echo -e "${BLUE}=== Current Firewall Rules ===${NC}"
echo ""
echo -e "Inbound Rules:"
echo -e "- 174.57.69.98 (IPv4) - TCP port 22 (SSH)"
echo -e "- 2601:83:201:3ed0:b413:87a6:977e:dbc7 (IPv6) - TCP port 22 (SSH)"
echo -e "- Any IPv4/IPv6 - ICMP"
echo -e "- Any IPv4/IPv6 - TCP port 30303"
echo -e "- 174.57.69.98 (IPv4) - UDP port 30303"
echo -e "- Any IPv4 - TCP port 8545"
echo -e "- Any IPv4 - TCP port 3000"
echo ""

echo -e "${BLUE}=== Instructions to Update Firewall ===${NC}"
echo ""
echo -e "To update your Hetzner firewall rules:"
echo ""
echo -e "1. Log in to your Hetzner Cloud Console: https://console.hetzner.cloud/"
echo -e "2. Select your project and navigate to the 'Firewalls' section"
echo -e "3. Select your firewall and click 'Edit'"
echo -e "4. Add a new inbound rule with the following settings:"
echo -e "   - Direction: Inbound"
echo -e "   - Protocol: TCP"
echo -e "   - Port: 22"
echo -e "   - Source IP: $IPV4 (for IPv4) or $IPV6 (for IPv6)"
echo -e "5. Save the changes"
echo ""

echo -e "${BLUE}=== Alternative Options ===${NC}"
echo ""
echo -e "Option 1: Use the local script instead of Hetzner"
echo -e "  Run: ./sync-data-local.sh"
echo -e "  This will process and store data locally without requiring Hetzner access."
echo ""
echo -e "Option 2: Use GitHub for repository hosting"
echo -e "  Run the following commands to push your code to GitHub:"
echo -e "  git init (if not already initialized)"
echo -e "  git add ."
echo -e "  git commit -m \"Initial commit\""
echo -e "  git remote add origin git@github.com:PaulieB14/substreams-contract-reviewer.git"
echo -e "  git push -u origin master"
echo ""
echo -e "Option 3: Use a different server or VPS"
echo -e "  You can set up the project on any server with SSH access."
echo -e "  Update the .env file with the new server details."
echo ""

echo -e "${BLUE}=== Next Steps ===${NC}"
echo ""
echo -e "After updating your firewall or choosing an alternative option:"
echo ""
echo -e "1. Make the local script executable:"
echo -e "   chmod +x sync-data-local.sh"
echo ""
echo -e "2. Run the script to collect contract data:"
echo -e "   ./sync-data-local.sh"
echo ""
echo -e "3. Check the output directory for results:"
echo -e "   ls -la output/"
echo ""
