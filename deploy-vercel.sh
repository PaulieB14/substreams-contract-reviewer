#!/bin/bash

# This script deploys the project to Vercel with the correct configuration

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

# Deploy to Vercel from the project root with environment variables
echo "Deploying to Vercel with environment variables..."
vercel --prod -e NEXT_PUBLIC_BASE_URL=https://substreams-contract-reviewer.vercel.app

echo ""
echo "===== DEPLOYMENT COMPLETE ====="
echo "Your application should now be deployed to Vercel."
echo ""
echo "If you still see a 404 error, try the following diagnostic URLs:"
echo "1. https://substreams-contract-reviewer.vercel.app/test.html"
echo "2. https://substreams-contract-reviewer.vercel.app/api/health"
echo ""
echo "You can also check the Vercel dashboard for deployment logs:"
echo "https://vercel.com/dashboard"
echo "============================================"
