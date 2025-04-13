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

def estimate_blocks_for_timeframe(days=90):
    """Estimate the number of blocks for a given timeframe."""
    # Ethereum averages ~12 second blocks
    blocks_per_day = 24 * 60 * 60 / 12  # ~7,200 blocks per day
    return int(blocks_per_day * days)

def run_substreams(start_block=22000000, block_count=None, days=None):
    """Run Substreams CLI and return the output."""
    print("Running Substreams CLI to get real blockchain data...")
    
    # If days is specified, calculate block_count
    if days and not block_count:
        block_count = estimate_blocks_for_timeframe(days)
        print(f"Analyzing approximately {days} days of data ({block_count} blocks)")
    else:
        # Default to 50 blocks if neither is specified
        block_count = block_count or 50
        print(f"Processing {block_count} blocks starting from block {start_block}")
    
    # For demonstration, we'll use a larger number of blocks
    # but still explain the limitation
    if block_count > 1000:
        print(f"Note: A full {days}-day analysis would require processing {block_count} blocks.")
        print("For demonstration purposes, we're limiting to 1000 blocks.")
        print("This will provide data across approximately 3.5 hours of blockchain activity.")
        print("In a production environment, you would:")
        print("1. Process data incrementally (e.g., daily batches)")
        print("2. Store results in a database for efficient querying")
        print("3. Use distributed processing for larger datasets")
        block_count = 1000
    
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
        
        # Print the first 500 characters of the output for debugging
        print("Output preview:")
        print(result.stdout[:500] + "..." if len(result.stdout) > 500 else result.stdout)
        
        # Try to parse the non-standard JSON output
        try:
            # First, try standard JSON parsing
            return json.loads(result.stdout)
        except json.JSONDecodeError as e:
            print(f"Error parsing standard JSON: {e}")
            print("Attempting to parse non-standard JSON format...")
            
            # Extract the real contract data from the Substreams output
            contracts = []
            
            # Find the contracts array in the output
            output_lines = result.stdout.split('\n')
            in_contracts = False
            current_contract = {}
            
            for line in output_lines:
                line = line.strip()
                
                # Check if we're in the contracts array
                if '"contracts": [' in line:
                    in_contracts = True
                    continue
                
                # Check if we're at the end of the contracts array
                if in_contracts and line == ']':
                    if current_contract:
                        contracts.append(current_contract)
                        current_contract = {}
                    in_contracts = False
                    continue
                
                # Check if we're starting a new contract
                if in_contracts and line == '{':
                    current_contract = {}
                    continue
                
                # Check if we're ending a contract
                if in_contracts and line == '}':
                    contracts.append(current_contract)
                    current_contract = {}
                    continue
                
                # Parse contract properties
                if in_contracts and ':' in line:
                    # Remove trailing comma if present
                    if line.endswith(','):
                        line = line[:-1]
                    
                    # Split by colon
                    parts = line.split(':', 1)
                    if len(parts) == 2:
                        key = parts[0].strip().strip('"')
                        value = parts[1].strip()
                        
                        # Handle arrays
                        if value.startswith('[') and value.endswith(']'):
                            # Parse array values
                            array_values = value[1:-1].split(',')
                            array_values = [v.strip().strip('"') for v in array_values if v.strip()]
                            current_contract[key] = array_values
                        else:
                            # Handle regular values
                            current_contract[key] = value.strip('"')
            
            if contracts:
                print(f"Successfully parsed {len(contracts)} contracts from non-standard JSON")
                
                # Convert string values to appropriate types
                for contract in contracts:
                    if "firstInteractionBlock" in contract:
                        contract["first_interaction_block"] = int(contract["firstInteractionBlock"])
                        del contract["firstInteractionBlock"]
                    
                    if "lastInteractionBlock" in contract:
                        contract["last_interaction_block"] = int(contract["lastInteractionBlock"])
                        del contract["lastInteractionBlock"]
                    
                    if "totalCalls" in contract:
                        contract["total_calls"] = int(contract["totalCalls"])
                        del contract["totalCalls"]
                    
                    if "uniqueWallets" in contract:
                        contract["unique_wallets"] = int(contract["uniqueWallets"])
                        del contract["uniqueWallets"]
                    
                    if "interactingWallets" in contract:
                        contract["interacting_wallets"] = contract["interactingWallets"]
                        del contract["interactingWallets"]
                    
                    # Handle new fields
                    if "isNewContract" in contract:
                        contract["is_new_contract"] = contract["isNewContract"].lower() == "true"
                        del contract["isNewContract"]
                    else:
                        contract["is_new_contract"] = False
                    
                    if "dayTimestamp" in contract:
                        contract["day_timestamp"] = int(contract["dayTimestamp"])
                        del contract["dayTimestamp"]
                    else:
                        # Approximate day timestamp from block number if not available
                        block_timestamp = contract["last_interaction_block"] * 12  # ~12 seconds per block
                        contract["day_timestamp"] = (block_timestamp // 86400) * 86400
                
                return {"contracts": contracts}
            
            print("Failed to parse JSON output from Substreams.")
            raise RuntimeError("Could not parse Substreams output and no fallback to mock data is allowed")
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
    
    # Group contracts by day for time-based analysis
    daily_stats = {}
    for contract in contracts:
        # If day_timestamp is not present, calculate it from block timestamp (approximate)
        day_timestamp = contract.get("day_timestamp", 0)
        if not day_timestamp and "last_interaction_block" in contract:
            # Rough estimate: each block is ~12 seconds
            block_timestamp = contract["last_interaction_block"] * 12
            day_timestamp = (block_timestamp // 86400) * 86400
            contract["day_timestamp"] = day_timestamp
        
        if day_timestamp not in daily_stats:
            daily_stats[day_timestamp] = {
                "day_timestamp": day_timestamp,
                "active_contracts": 0,
                "new_contracts": 0,
                "total_calls": 0,
                "unique_wallets": 0
            }
        
        daily_stats[day_timestamp]["active_contracts"] += 1
        daily_stats[day_timestamp]["total_calls"] += contract["total_calls"]
        daily_stats[day_timestamp]["unique_wallets"] += contract["unique_wallets"]
        
        # Check if this is a new contract
        is_new = contract.get("is_new_contract", False)
        if is_new:
            daily_stats[day_timestamp]["new_contracts"] += 1
    
    # Convert daily_stats to a list and sort by timestamp
    daily_stats_list = list(daily_stats.values())
    daily_stats_list.sort(key=lambda x: x["day_timestamp"])
    
    # Count new vs returning contracts
    new_contracts = sum(1 for c in contracts if c.get("is_new_contract", False))
    returning_contracts = len(contracts) - new_contracts
    
    return {
        "most_active_contracts": most_active,
        "most_popular_contracts": most_popular,
        "most_intensive_contracts": most_intensive,
        "newest_contracts": newest_contracts,
        "total_contracts_analyzed": len(contracts),
        "analysis_timestamp": datetime.now().isoformat(),
        "daily_stats": daily_stats_list,
        "new_vs_returning_contracts": {
            "new_contracts": new_contracts,
            "returning_contracts": returning_contracts
        }
    }

# Get real data from Substreams with a time-based approach
# Use a 3-month (90-day) timeframe for more meaningful analysis
substreams_data = run_substreams(days=90)
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
