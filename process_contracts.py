#!/usr/bin/env python3
"""
Simplified script to demonstrate the GitHub Actions workflow.
This script creates mock contract data for demonstration purposes.
In a real implementation, this would use the Substreams CLI to process Ethereum data.
"""

import json
import os
import random
import time
from datetime import datetime, timedelta

# Create output directory if it doesn't exist
os.makedirs("output", exist_ok=True)
os.makedirs("results", exist_ok=True)

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

# Generate a list of mock contracts
contracts = [generate_mock_contract() for _ in range(50)]

# Save to output file
with open("output/contracts.json", "w") as f:
    json.dump(contracts, f, indent=2)

print(f"Generated {len(contracts)} mock contracts and saved to output/contracts.json")

# Create a timestamped copy in the results directory
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
result_file = f"results/contracts_{timestamp}.json"

with open(result_file, "w") as f:
    json.dump(contracts, f, indent=2)

print(f"Created timestamped copy at {result_file}")

print("Processing complete!")
