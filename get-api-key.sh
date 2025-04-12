#!/bin/bash
# Script to help users get a Substreams API key

echo "=== Substreams API Key Helper ==="
echo ""
echo "This script will guide you through the process of obtaining a Substreams API key."
echo ""
echo "Options:"
echo "1. StreamingFast (recommended)"
echo "2. Pinax"
echo ""
read -p "Select an option (1-2): " option

case $option in
  1)
    echo ""
    echo "=== StreamingFast API Key ==="
    echo ""
    echo "To get a StreamingFast API key:"
    echo "1. Visit https://app.streamingfast.io/"
    echo "2. Create an account or log in"
    echo "3. Navigate to the API Keys section"
    echo "4. Create a new API key"
    echo ""
    echo "Once you have your API key, add it to your .env file:"
    echo "SUBSTREAMS_API_KEY=your_api_key_here"
    ;;
  2)
    echo ""
    echo "=== Pinax API Key ==="
    echo ""
    echo "To get a Pinax API key:"
    echo "1. Visit https://app.pinax.network/"
    echo "2. Create an account or log in"
    echo "3. Navigate to the API Keys section"
    echo "4. Create a new API key"
    echo ""
    echo "Once you have your API key, add it to your .env file:"
    echo "SUBSTREAMS_API_KEY=your_api_key_here"
    ;;
  *)
    echo "Invalid option selected."
    ;;
esac

echo ""
echo "After adding your API key to the .env file, your Substreams scripts will automatically use it."
