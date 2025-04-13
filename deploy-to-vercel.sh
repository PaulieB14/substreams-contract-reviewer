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
./copy-data.sh

# Change to the dashboard directory
cd dashboard-improved

# Deploy to Vercel
echo "Deploying to Vercel..."
vercel --prod

echo "Deployment complete! Your dashboard is now live on Vercel."
echo "You can view your deployments at https://vercel.com/dashboard"
