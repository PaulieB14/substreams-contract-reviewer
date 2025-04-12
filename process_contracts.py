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

def run_substreams(start_block=16000000, block_count=1000):
    """Run Substreams CLI and return the output."""
    try:
        # Try to run the actual Substreams CLI if available
        print("Attempting to run Substreams CLI...")
        result = subprocess.run(
            [
                "substreams", "run", 
                "-e", "mainnet.eth.streamingfast.io:443",
                "substreams.yaml", "map_contract_usage",
                "--start-block", str(start_block),
                "--stop-block", f"+{block_count}"
            ],
            capture_output=True,
            text=True,
            check=True
        )
        print("Substreams CLI executed successfully!")
        return json.loads(result.stdout)
    except (subprocess.SubprocessError, FileNotFoundError) as e:
        print(f"Substreams CLI not available: {e}")
        print("Falling back to mock data...")
        return None

# Generate mock contract data
def generate_mock_contract():
    """Generate a mock contract with random data."""
    # Random contract address
    address = "0x" + "".join(random.choice("0123456789abcdef") for _ in range(40))
    
    # Random block numbers
    first_block = random.randint(16000000, 16100000)
    last_block = first_block + random.randint(1000, 10000)
    
    # Random stats
    total_calls = random.randint(100, 10000)
    unique_wallets = random.randint(10, 1000)
    
    # Generate some random wallet addresses
    wallets = [
        "0x" + "".join(random.choice("0123456789abcdef") for _ in range(40))
        for _ in range(min(unique_wallets, 20))  # Limit to 20 for brevity
    ]
    
    return {
        "address": address,
        "first_interaction_block": first_block,
        "last_interaction_block": last_block,
        "total_calls": total_calls,
        "unique_wallets": unique_wallets,
        "interacting_wallets": wallets
    }

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

# Try to get data from Substreams, fall back to mock data if needed
substreams_data = run_substreams()
if substreams_data:
    contracts = substreams_data.get("contracts", [])
    print(f"Retrieved {len(contracts)} contracts from Substreams")
else:
    # Generate a list of mock contracts
    contracts = [generate_mock_contract() for _ in range(50)]
    print(f"Generated {len(contracts)} mock contracts")

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
