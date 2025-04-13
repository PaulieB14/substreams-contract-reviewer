#!/bin/bash

# Create the results directory in the dashboard directory if it doesn't exist
mkdir -p dashboard/public/results

# Copy the latest analysis file to the dashboard directory
cp results/latest_analysis.json dashboard/public/results/

echo "Data copied to dashboard/public/results/"
