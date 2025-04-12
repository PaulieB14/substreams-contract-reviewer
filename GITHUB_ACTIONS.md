# Running Substreams Contract Reviewer on GitHub Actions

This guide explains how to run the Substreams Contract Reviewer using GitHub Actions instead of a Hetzner server or local storage.

## Benefits of Using GitHub Actions

- **No Local Storage Usage**: All processing happens on GitHub's servers
- **Automated Daily Runs**: Data is collected automatically on a schedule
- **Version Control**: All results are stored in Git with timestamps
- **No Server Management**: No need to maintain or troubleshoot a server
- **Free Tier**: GitHub Actions is free for public repositories

## Setup Instructions

### 1. Run the Setup Script

```bash
./setup-github-actions.sh
```

This interactive script will:
- Set up your GitHub repository
- Configure the necessary files and directories
- Guide you through pushing your code to GitHub

### 2. Add Your Substreams API Key as a GitHub Secret

1. Go to your GitHub repository: https://github.com/PaulieB14/substreams-contract-reviewer
2. Click on 'Settings' tab
3. In the left sidebar, click on 'Secrets and variables' > 'Actions'
4. Click on 'New repository secret'
5. Name: `SUBSTREAMS_API_KEY`
6. Value: Your Substreams API key (e.g., `server_9dc03b3b92c9802bd3346befc0f6c0ab`)
7. Click 'Add secret'

### 3. Trigger the Workflow

1. Go to your GitHub repository
2. Click on 'Actions' tab
3. Select the 'Substreams Contract Reviewer' workflow
4. Click on 'Run workflow' > 'Run workflow'

### 4. View the Results

After the workflow completes:
1. Go to your GitHub repository
2. Navigate to the 'results' directory
3. You'll find JSON files with timestamps containing the contract data

## How It Works

The GitHub Actions workflow (`.github/workflows/substreams.yml`) does the following:

1. **Builds the Substreams WASM Module**: Compiles your Rust code to WebAssembly
2. **Runs the Substreams**: Processes Ethereum contract data using your API key
3. **Saves the Results**: Stores the output in the 'results' directory
4. **Commits and Pushes**: Automatically commits the results back to your repository

## Scheduled Runs

The workflow is configured to run automatically every day at midnight UTC. You can modify the schedule in the workflow file:

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Run daily at midnight UTC
```

## Troubleshooting

If you encounter issues with the GitHub Actions workflow:

1. Check the workflow run logs in the 'Actions' tab
2. Verify that your Substreams API key is correctly set as a GitHub secret
3. Make sure the repository has the correct permissions for GitHub Actions
4. Check that the 'results' directory is not ignored in your .gitignore file

## Customization

You can customize the workflow by editing the `.github/workflows/substreams.yml` file:

- Change the schedule for automated runs
- Modify the block range for data collection
- Adjust the output format or location
- Add additional processing steps

## Reverting to Hetzner or Local Processing

If you want to switch back to using Hetzner or local processing:

- For Hetzner: Use the troubleshooting scripts to fix connection issues
  - `./verify-hetzner-server.sh`
  - `./test-hetzner-advanced.sh`
  - `./fix-hetzner.sh`

- For local processing: Use the local script
  - `./sync-data-local.sh`
