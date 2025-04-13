# Substreams Contract Reviewer

A comprehensive solution for monitoring and analyzing contract usage on Ethereum, using Substreams for data processing and storing the output securely.

## Project Overview

This project consists of two main components:

1. **Substreams Data Processor**: Analyzes Ethereum blockchain data to track contract usage
2. **Dashboard**: Visualizes the contract data in an interactive web interface

## Features

- **Catch-All Contract Monitoring**: Tracks all smart contract addresses that receive transactions
- **Comprehensive Analytics**: Stores first/last interaction blocks, total calls, unique wallets, etc.
- **Real-Time Processing**: Uses Substreams for efficient blockchain data processing
- **Modern Dashboard**: Built with Next.js and shadcn/ui for a responsive user experience
- **Copy Functionality**: Easily copy contract addresses with a single click
- **Etherscan Integration**: Direct links to view contracts on Etherscan

## Getting Started

### Prerequisites

- Rust and Cargo
- Node.js 18+ and npm
- Substreams CLI
- Substreams API token

### Installation

1. **Clone the repository**:

```bash
git clone https://github.com/yourusername/substreams-contract-reviewer.git
cd substreams-contract-reviewer
```

2. **Set up environment variables**:

```bash
cp .env.example .env
# Edit .env to add your Substreams API token
```

3. **Process blockchain data**:

```bash
python3 process_contracts.py
```

4. **Copy data to the dashboard**:

```bash
./copy-data.sh
```

5. **Run the dashboard**:

```bash
./run-dashboard.sh
```

6. **Access the dashboard** at http://localhost:3000

## Project Structure

- `src/`: Rust code for the Substreams module
- `proto/`: Protocol Buffers schema definitions
- `process_contracts.py`: Python script to run Substreams and process data
- `dashboard/`: Original dashboard implementation
- `dashboard-improved/`: Enhanced dashboard with shadcn/ui components
- `results/`: Output data from Substreams processing

## Deployment Options

### Dashboard Deployment

The dashboard can be deployed to Vercel or exported as static files. See the [dashboard README](dashboard-improved/README.md) for details.

### Data Processing Deployment

The data processing can be deployed to:

1. **GitHub Actions**: Automated processing on a schedule
2. **Hetzner Server**: Self-hosted solution for continuous processing
3. **Local Machine**: For development and testing

## Data Flow

1. Substreams processes Ethereum blockchain data
2. `process_contracts.py` extracts contract usage information
3. Results are stored in JSON format
4. Dashboard reads the JSON data and visualizes it

## Technologies Used

- **Substreams**: For efficient blockchain data processing
- **Rust**: For the Substreams module implementation
- **Python**: For data processing scripts
- **Next.js**: React framework for the dashboard
- **shadcn/ui**: High-quality UI components
- **TypeScript**: Type-safe JavaScript
- **Tailwind CSS**: Utility-first CSS framework

## License

This project is licensed under the MIT License - see the LICENSE file for details.
