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

# Check if vercel.json exists in the dashboard directory
if [ -f "vercel.json" ]; then
    echo "vercel.json found in dashboard directory."
else
    echo "WARNING: vercel.json not found in dashboard directory. This may cause deployment issues."
    echo "Consider creating a vercel.json file with proper configuration."
fi

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
echo "5. Set the following environment variables in Vercel:"
echo "   - NEXT_PUBLIC_BASE_URL: https://substreams-contract-reviewer.vercel.app"
echo "     (or your custom domain if you have one)"
echo "6. Click 'Deploy'"
echo ""
echo "Your dashboard will be live at the URL provided by Vercel."
echo "You can view your deployments at https://vercel.com/dashboard"
echo ""
echo "If you encounter a 404 error after deployment:"
echo "1. Check that the results/latest_analysis.json file exists in the dashboard/public directory"
echo "2. Verify that the vercel.json file is properly configured"
echo "3. Ensure the NEXT_PUBLIC_BASE_URL environment variable is set correctly"
echo "============================================"
