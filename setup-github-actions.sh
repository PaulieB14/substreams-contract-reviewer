#!/bin/bash
# Script to set up GitHub repository and configure GitHub Actions

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

GITHUB_REPO="git@github.com:PaulieB14/substreams-contract-reviewer.git"

echo -e "${BLUE}=== GitHub Repository and Actions Setup ===${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo -e "${RED}Error: git is not installed. Please install it first:${NC}"
  echo "  macOS: brew install git"
  echo "  Linux: sudo apt-get install git"
  exit 1
fi

# Step 1: Initialize Git repository if needed
echo -e "${BLUE}Step 1: Setting up Git repository${NC}"
if [ -d .git ]; then
  echo -e "${GREEN}✓ Git repository already initialized${NC}"
else
  echo -e "Initializing Git repository..."
  git init
  echo -e "${GREEN}✓ Git repository initialized${NC}"
fi
echo ""

# Step 2: Add GitHub remote
echo -e "${BLUE}Step 2: Adding GitHub remote${NC}"
if git remote | grep -q "origin"; then
  CURRENT_REMOTE=$(git remote get-url origin)
  echo -e "Remote 'origin' already exists: ${YELLOW}$CURRENT_REMOTE${NC}"
  
  if [ "$CURRENT_REMOTE" != "$GITHUB_REPO" ]; then
    echo -e "${YELLOW}Would you like to update it to $GITHUB_REPO? (y/n)${NC}"
    read -p "" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git remote remove origin
      git remote add origin $GITHUB_REPO
      echo -e "${GREEN}✓ Updated remote 'origin' to $GITHUB_REPO${NC}"
    fi
  else
    echo -e "${GREEN}✓ Remote is already set to the correct repository${NC}"
  fi
else
  git remote add origin $GITHUB_REPO
  echo -e "${GREEN}✓ Added remote 'origin' as $GITHUB_REPO${NC}"
fi
echo ""

# Step 3: Create .gitignore if it doesn't exist
echo -e "${BLUE}Step 3: Setting up .gitignore${NC}"
if [ -f .gitignore ]; then
  echo -e "${GREEN}✓ .gitignore file already exists${NC}"
  
  # Make sure results directory is not ignored
  if grep -q "results/" .gitignore; then
    echo -e "${YELLOW}! 'results/' is in .gitignore but we need to keep it for GitHub Actions${NC}"
    echo -e "Updating .gitignore to exclude results directory from being ignored..."
    sed -i '' '/results\//d' .gitignore
    echo -e "${GREEN}✓ Updated .gitignore${NC}"
  fi
else
  echo -e "Creating .gitignore file..."
  cat > .gitignore << EOF
# Rust build artifacts
/target/
**/*.rs.bk
Cargo.lock

# Environment variables and secrets
.env
*.pem
*.key

# Output files (except results directory)
/output/
*.log
last_block.txt

# Hetzner credentials
.rclone.conf
.aws/

# OS specific files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo
EOF
  echo -e "${GREEN}✓ Created .gitignore file${NC}"
fi
echo ""

# Step 4: Create results directory
echo -e "${BLUE}Step 4: Creating results directory${NC}"
if [ -d results ]; then
  echo -e "${GREEN}✓ Results directory already exists${NC}"
else
  mkdir -p results
  echo -e "${GREEN}✓ Created results directory${NC}"
fi
echo ""

# Step 5: Add Substreams API key to GitHub secrets
echo -e "${BLUE}Step 5: Setting up GitHub Secrets${NC}"
echo -e "You need to add your Substreams API key as a GitHub secret:"
echo -e "1. Go to your GitHub repository: https://github.com/PaulieB14/substreams-contract-reviewer"
echo -e "2. Click on 'Settings' tab"
echo -e "3. In the left sidebar, click on 'Secrets and variables' > 'Actions'"
echo -e "4. Click on 'New repository secret'"
echo -e "5. Name: ${YELLOW}SUBSTREAMS_API_KEY${NC}"

# Get API key from .env file
if [ -f .env ]; then
  API_KEY=$(grep "SUBSTREAMS_API_KEY" .env | cut -d '=' -f2)
  echo -e "6. Value: ${YELLOW}$API_KEY${NC}"
else
  echo -e "6. Value: ${YELLOW}(Your Substreams API key)${NC}"
fi

echo -e "7. Click 'Add secret'"
echo ""

# Step 6: Commit and push
echo -e "${BLUE}Step 6: Committing and pushing to GitHub${NC}"
echo -e "${YELLOW}Would you like to commit and push your code to GitHub now? (y/n)${NC}"
read -p "" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "Adding files to Git..."
  git add .
  
  echo -e "Committing changes..."
  git commit -m "Initial commit of Substreams Contract Reviewer"
  
  echo -e "Pushing to GitHub..."
  git push -u origin master
  
  echo -e "${GREEN}✓ Code pushed to GitHub${NC}"
  echo -e "You can now view your repository at: https://github.com/PaulieB14/substreams-contract-reviewer"
else
  echo -e "Skipping commit and push. You can do this manually later with:"
  echo -e "  git add ."
  echo -e "  git commit -m \"Initial commit\""
  echo -e "  git push -u origin master"
fi
echo ""

# Step 7: Trigger GitHub Actions workflow
echo -e "${BLUE}Step 7: Triggering GitHub Actions workflow${NC}"
echo -e "After pushing your code to GitHub, you can manually trigger the workflow:"
echo -e "1. Go to your GitHub repository: https://github.com/PaulieB14/substreams-contract-reviewer"
echo -e "2. Click on 'Actions' tab"
echo -e "3. Select the 'Substreams Contract Reviewer' workflow"
echo -e "4. Click on 'Run workflow' > 'Run workflow'"
echo ""
echo -e "The workflow will:"
echo -e "- Build your Substreams WASM module"
echo -e "- Run the Substreams to collect contract data"
echo -e "- Save the results in the 'results' directory"
echo -e "- Commit and push the results back to your repository"
echo ""
echo -e "This way, you don't need to use local storage or a Hetzner server!"
echo ""

echo -e "${BLUE}=== Setup Complete ===${NC}"
echo -e "Your project is now configured to run on GitHub Actions."
echo -e "The workflow will run daily at midnight UTC, or you can trigger it manually."
echo ""
