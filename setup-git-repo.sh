#!/bin/bash
# Script to set up a Git repository on Hetzner server

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Hetzner server details
HETZNER_IP=${HETZNER_IP:-5.161.70.165}
HETZNER_USER=${HETZNER_USERNAME:-root}
REPO_NAME=${1:-contract_reviewer}
REPO_PATH="/var/git/${REPO_NAME}.git"

echo "=== Setting up Git repository on Hetzner server ==="
echo "Server IP: $HETZNER_IP"
echo "Repository name: $REPO_NAME"
echo "Repository path: $REPO_PATH"
echo ""

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "SSH key not found. Creating a new one..."
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
  echo "SSH key created."
fi

# Copy SSH key to Hetzner server
echo "Copying SSH key to Hetzner server..."
ssh-copy-id -i ~/.ssh/id_rsa.pub ${HETZNER_USER}@${HETZNER_IP}

# Create bare Git repository on Hetzner server
echo "Creating bare Git repository on Hetzner server..."
ssh ${HETZNER_USER}@${HETZNER_IP} "mkdir -p $(dirname $REPO_PATH) && git init --bare $REPO_PATH"

# Add Hetzner as a remote repository
echo "Adding Hetzner as a remote repository..."
if git remote | grep -q "hetzner"; then
  git remote remove hetzner
fi
git remote add hetzner ${HETZNER_USER}@${HETZNER_IP}:${REPO_PATH}

# Initialize Git repository locally if not already initialized
if [ ! -d .git ]; then
  echo "Initializing local Git repository..."
  git init
  git add .
  git commit -m "Initial commit"
fi

echo ""
echo "=== Repository setup complete ==="
echo ""
echo "To push your code to Hetzner, run:"
echo "git push hetzner master"
echo ""
echo "To clone this repository on another machine:"
echo "git clone ${HETZNER_USER}@${HETZNER_IP}:${REPO_PATH}"
