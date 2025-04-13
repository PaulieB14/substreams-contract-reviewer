#!/usr/bin/env python3
"""
Simple script to test if a Substreams API key is valid.
"""

import os
import subprocess
import sys
import time

# The API key to test
API_KEY = "server_9dc03b3b92c9802bd3346befc0f6c0ab"

def test_api_key():
    """Test if the API key is valid by trying different environment variables and commands."""
    print("Testing Substreams API key:", API_KEY)
    
    # Check if substreams is installed
    try:
        version_result = subprocess.run(
            ["substreams", "--version"],
            capture_output=True,
            text=True,
            check=True
        )
        print(f"Substreams CLI version: {version_result.stdout.strip()}")
    except (subprocess.SubprocessError, FileNotFoundError) as e:
        print(f"Error checking Substreams CLI version: {e}")
        print("Please make sure Substreams CLI is installed.")
        return False
    
    # Try different environment variable names for the API key
    env_var_names = [
        "SUBSTREAMS_API_KEY",
        "SUBSTREAMS_API_TOKEN",
        "SF_API_KEY",
        "SF_API_TOKEN",
        "STREAMINGFAST_API_KEY",
        "STREAMINGFAST_API_TOKEN"
    ]
    
    # Try different commands
    commands = [
        # Help commands (don't require authentication)
        ["substreams", "--help"],
        
        # Commands that require authentication
        ["substreams", "run", "substreams.yaml", "map_contract_usage", "--start-block", "17500000", "--stop-block", "+10"],
        ["substreams", "info", "substreams.yaml"]
    ]
    
    # Try each environment variable with each command
    for env_var in env_var_names:
        print(f"\n\nTrying with environment variable: {env_var}")
        
        # Set up environment with this variable
        env = os.environ.copy()
        env[env_var] = API_KEY
        
        for cmd in commands:
            cmd_str = " ".join(cmd)
            print(f"\nRunning command: {cmd_str}")
            
            try:
                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    check=True,
                    env=env,
                    timeout=10
                )
                print("Command succeeded!")
                print("Output:")
                print(result.stdout[:500] + "..." if len(result.stdout) > 500 else result.stdout)
            except subprocess.SubprocessError as e:
                print(f"Command failed: {e}")
                print(f"Error output: {e.stderr if hasattr(e, 'stderr') else 'No error output'}")
            
            # Small delay between commands
            time.sleep(1)
    
    print("\nAPI key testing complete. Check the output above to see if any commands succeeded.")
    return True

if __name__ == "__main__":
    test_api_key()
