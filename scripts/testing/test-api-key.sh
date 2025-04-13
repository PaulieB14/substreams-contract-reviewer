#!/bin/bash

# Set the API key
export SUBSTREAMS_API_KEY="server_9dc03b3b92c9802bd3346befc0f6c0ab"
export SUBSTREAMS_API_TOKEN="server_9dc03b3b92c9802bd3346befc0f6c0ab"

# Check if substreams is installed
if ! command -v substreams &> /dev/null; then
    echo "Substreams CLI is not installed. Please install it first."
    exit 1
fi

# Print the version
echo "Substreams CLI version:"
substreams --version

# Try a simple command to test the API key
echo -e "\nTesting API key with a simple command..."
substreams -e mainnet.eth.streamingfast.io:443 info

# If the above command succeeds, the API key is valid
if [ $? -eq 0 ]; then
    echo -e "\nAPI key is valid!"
else
    echo -e "\nAPI key is invalid or there's an issue with the connection."
fi
