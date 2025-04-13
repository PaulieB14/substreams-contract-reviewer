#!/bin/bash

# This script deploys the improved dashboard to Vercel

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "Vercel CLI is not installed. Installing..."
    npm install -g vercel
fi

# Process the latest blockchain data
echo "Processing blockchain data..."
python3 process_contracts.py

# Copy the data to the dashboard's public directory
echo "Copying data to dashboard..."
./scripts/maintenance/copy-data.sh

# Change to the dashboard directory
cd dashboard

# Instructions for manual deployment to Vercel
echo "===== MANUAL DEPLOYMENT INSTRUCTIONS ====="
echo "To deploy to Vercel, follow these steps:"
echo "1. Go to https://vercel.com/new"
echo "2. Import your GitHub repository (if not already connected)"
echo "3. Select the 'dashboard' directory as the root directory"
echo "4. Configure the following settings:"
echo "   - Framework Preset: Next.js"
echo "   - Root Directory: dashboard"
echo "   - Build Command: next build"
echo "   - Output Directory: .next"
echo "5. Click 'Deploy'"
echo ""
echo "Your dashboard will be live at the URL provided by Vercel."
echo "You can view your deployments at https://vercel.com/dashboard"
echo "============================================"
