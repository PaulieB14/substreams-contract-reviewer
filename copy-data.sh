#!/bin/bash

# Create the results directory in the dashboard-improved directory if it doesn't exist
mkdir -p dashboard-improved/public/results

# Copy the latest analysis file to the dashboard-improved directory
cp results/latest_analysis.json dashboard-improved/public/results/

echo "Data copied to dashboard-improved/public/results/"
