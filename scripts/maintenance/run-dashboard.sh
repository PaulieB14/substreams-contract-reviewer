#!/bin/bash

# Change to the dashboard directory
cd dashboard

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Run the development server
echo "Starting Next.js development server..."
npm run dev
