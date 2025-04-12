# Substreams Contract Reviewer

A "Catch-All Contract Reviewer" using Substreams that monitors and analyzes contract usage on Ethereum, and stores the output securely using Hetzner's infrastructure.

## Project Overview

This Substreams project tracks all smart contract addresses that receive transactions on Ethereum. For each contract, it stores:

- First and last interaction block
- Total number of calls
- Total unique wallets interacting
- List of interacting wallets

## Why Substreams?

- Processes entire chain efficiently
- Doesn't require hardcoding contract addresses
- Better performance and scalability compared to subgraphs
- Easy to deploy on decentralized infra like Pinax

## Prerequisites

- **Rust and Cargo**: Required for building the Substreams WASM module
- **WebAssembly Target**: The `wasm32-unknown-unknown` target for Rust
- **Substreams CLI**: For running the Substreams module
- **jq**: Required for JSON processing in the scripts
- **rclone**: Required for Hetzner Storage Box integration
- **AWS CLI**: Required for Hetzner Object Storage (S3) integration

Don't worry if you don't have these installed - the setup script will check for and install missing dependencies.

## Setup

### Quick Setup

Run the automated setup script to install all dependencies and build the project:

```bash
./setup.sh
```

This script will:
1. Check and install Rust if needed
2. Add the WebAssembly target (`wasm32-unknown-unknown`)
3. Install Substreams CLI and other dependencies
4. Set up environment variables
5. Make all scripts executable
6. Build the Substreams WASM module

### Manual Setup

If you prefer to set up manually:

1. Install Rust and Cargo:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source $HOME/.cargo/env
   ```

2. Add the WebAssembly target:
   ```bash
   rustup target add wasm32-unknown-unknown
   ```

3. Install Substreams CLI:
   ```bash
   brew tap streamingfast/tap
   brew install substreams
   ```

4. Configure environment variables:
   ```bash
   # Copy the example .env file and edit it with your credentials
   cp .env.example .env
   nano .env
   ```

5. Build the Substreams WASM module:
   ```bash
   cargo build --target wasm32-unknown-unknown --release
   ```

## Hetzner Storage Integration

### Option A: Storage Box

1. Set your Hetzner credentials in the .env file:
   ```
   HETZNER_USERNAME=your_username
   HETZNER_PASSWORD=your_password
   ```

2. Run the sync script:
   ```bash
   ./sync-data.sh
   ```
   
   The script will automatically configure rclone if needed.

### Option B: Object Storage (S3)

1. Set your S3 credentials in the .env file:
   ```
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   HETZNER_BUCKET_NAME=your_bucket_name
   ```

2. Run the upload script:
   ```bash
   ./upload-s3.sh
   ```
   
   The script will automatically configure the AWS CLI if needed.

### Incremental Processing

For incremental processing that keeps track of the last processed block:

```bash
./sync-incremental.sh
```

This script maintains a state file and processes blocks in chunks, which is ideal for regular scheduled runs.

## Customization

- Modify the block range in the scripts to process different parts of the chain
- Adjust the output format or fields in the Rust code
- Set up cron jobs for regular syncing

## Maintenance Tips

- Schedule runs via cronjob or systemd timer for regular syncs
- Monitor data volume and set thresholds for archival
- Consider compressing outputs before upload (e.g., gzip)
- Set up basic retry logic for uploads to Hetzner

## Additional Scripts

### Git Repository Setup

You can store your code repository on Hetzner using the provided script:

```bash
./setup-git-repo.sh
```

This will:
1. Set up a bare Git repository on your Hetzner server
2. Configure SSH keys for authentication
3. Add the Hetzner repository as a remote
4. Initialize your local Git repository if needed

### Web Dashboard

To set up a simple web dashboard to visualize your contract data:

```bash
./setup-dashboard.sh
```

This will:
1. Create a Bootstrap/Chart.js dashboard
2. Set up Apache and PHP on your Hetzner server
3. Configure automatic data updates via cron
4. Make the dashboard accessible via http://your-hetzner-ip/

### API Key Helper

If you need to obtain a Substreams API key:

```bash
./get-api-key.sh
```

This interactive script will guide you through the process of obtaining an API key from either StreamingFast or Pinax.

### Monitoring

To check the status of your Substreams Contract Reviewer setup:

```bash
./monitor.sh
```

This script will:
1. Verify your local environment (Rust, Substreams CLI, etc.)
2. Check project files and build artifacts
3. Test connectivity to your Hetzner server
4. Report on storage usage and web dashboard status
