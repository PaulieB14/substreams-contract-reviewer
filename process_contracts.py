#!/usr/bin/env python3
"""
Enhanced script for the Substreams Contract Reviewer.
This script attempts to use the Substreams CLI if available,
otherwise falls back to generating mock data.
"""

import json
import os
import random
import subprocess
import time
from datetime import datetime, timedelta

# Create output directory if it doesn't exist
os.makedirs("output", exist_ok=True)
os.makedirs("results", exist_ok=True)
os.makedirs("dashboard", exist_ok=True)

def run_substreams(start_block=17500000, block_count=50):
    """Run Substreams CLI and return the output."""
    print("Running Substreams CLI to get real blockchain data...")
    print(f"Processing {block_count} blocks starting from block {start_block}")
    
    # Check if the JWT token is set in the environment
    jwt_token = os.environ.get("SUBSTREAMS_API_TOKEN")
    if not jwt_token:
        # Try to load from .env file if not in environment
        try:
            with open('.env', 'r') as f:
                for line in f:
                    if line.strip() and not line.startswith('#'):
                        key, value = line.strip().split('=', 1)
                        if key == "SUBSTREAMS_API_TOKEN":
                            jwt_token = value
                            break
        except Exception as e:
            print(f"Error loading .env file: {e}")
    
    if not jwt_token:
        raise ValueError("SUBSTREAMS_API_TOKEN environment variable is required")
    
    # Set up environment variables for the subprocess
    env = os.environ.copy()
    env["SUBSTREAMS_API_TOKEN"] = jwt_token
    
    # Prepare command according to Substreams documentation
    cmd = [
        "substreams", "run", 
        "-e", "mainnet.eth.streamingfast.io:443",  # Ethereum mainnet endpoint
        "substreams.yaml", "map_contract_usage",   # Substreams package and module
        "--start-block", str(start_block),         # Starting block
        "--stop-block", f"+{block_count}"          # Number of blocks to process
    ]
    
    # Run the command with a timeout
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            timeout=300,  # 5-minute timeout
            env=env  # Pass the environment variables with the API token
        )
        print("Substreams CLI executed successfully!")
        return json.loads(result.stdout)
    except subprocess.SubprocessError as e:
        print(f"Error running Substreams CLI: {e}")
        print(f"Command output: {e.stdout if hasattr(e, 'stdout') else 'No output'}")
        print(f"Command error: {e.stderr if hasattr(e, 'stderr') else 'No error'}")
        raise RuntimeError("Failed to get real data from Substreams") from e
    except FileNotFoundError as e:
        print(f"Substreams CLI not found: {e}")
        raise RuntimeError("Substreams CLI is not installed") from e

def analyze_contracts(contracts):
    """Analyze contract data to extract insights."""
    # Sort contracts by total calls
    most_active = sorted(contracts, key=lambda x: x["total_calls"], reverse=True)[:10]
    
    # Find contracts with most unique wallets
    most_popular = sorted(contracts, key=lambda x: x["unique_wallets"], reverse=True)[:10]
    
    # Calculate average calls per wallet
    for contract in contracts:
        contract["avg_calls_per_wallet"] = contract["total_calls"] / max(1, contract["unique_wallets"])
    
    # Find contracts with highest average calls per wallet
    most_intensive = sorted(contracts, key=lambda x: x["avg_calls_per_wallet"], reverse=True)[:10]
    
    # Find newest contracts (highest first_interaction_block)
    newest_contracts = sorted(contracts, key=lambda x: x["first_interaction_block"], reverse=True)[:10]
    
    return {
        "most_active_contracts": most_active,
        "most_popular_contracts": most_popular,
        "most_intensive_contracts": most_intensive,
        "newest_contracts": newest_contracts,
        "total_contracts_analyzed": len(contracts),
        "analysis_timestamp": datetime.now().isoformat()
    }

# Get real data from Substreams
substreams_data = run_substreams()
contracts = substreams_data.get("contracts", [])
print(f"Retrieved {len(contracts)} contracts from Substreams")

# Ensure we have data
if not contracts:
    raise RuntimeError("No contract data retrieved from Substreams")

# Save to output file
with open("output/contracts.json", "w") as f:
    json.dump(contracts, f, indent=2)

print(f"Saved contract data to output/contracts.json")

# Create a timestamped copy in the results directory
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
result_file = f"results/contracts_{timestamp}.json"

with open(result_file, "w") as f:
    json.dump(contracts, f, indent=2)

print(f"Created timestamped copy at {result_file}")

# Analyze the contract data
analysis = analyze_contracts(contracts)

# Save analysis to a separate file
analysis_file = f"results/analysis_{timestamp}.json"
with open(analysis_file, "w") as f:
    json.dump(analysis, f, indent=2)

# Also save a copy without timestamp for easy access
with open("results/latest_analysis.json", "w") as f:
    json.dump(analysis, f, indent=2)

print(f"Analysis complete! Found {analysis['total_contracts_analyzed']} contracts.")
print(f"Most active contract: {analysis['most_active_contracts'][0]['address']} with {analysis['most_active_contracts'][0]['total_calls']} calls")
print(f"Most popular contract: {analysis['most_popular_contracts'][0]['address']} with {analysis['most_popular_contracts'][0]['unique_wallets']} unique wallets")

print("Processing complete!")
