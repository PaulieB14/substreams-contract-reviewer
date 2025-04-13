# Ethereum Contract Reviewer Dashboard

A modern dashboard for analyzing Ethereum smart contract usage, built with Next.js and shadcn/ui.

## Features

- **Real Blockchain Data**: Displays real data from Ethereum mainnet via Substreams
- **Contract Analysis**: View the most active, popular, and intensive contracts
- **Interactive UI**: Modern interface with tabs, cards, and tables
- **Copy Functionality**: Easily copy contract addresses with a single click
- **Etherscan Integration**: Direct links to view contracts on Etherscan

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Substreams API token

### Installation

1. Install dependencies:

```bash
npm install
```

2. Make sure the contract data is available:

```bash
# From the project root
./copy-data.sh
```

3. Start the development server:

```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## Deployment

### Vercel Deployment

1. Install Vercel CLI:

```bash
npm i -g vercel
```

2. Deploy:

```bash
vercel
```

3. Set environment variables in Vercel dashboard if needed

### Static Export

1. Build the project:

```bash
npm run build
```

2. The static files will be in the `out` directory

## Data Source

The dashboard uses data from the Substreams Contract Reviewer, which analyzes contract usage on the Ethereum blockchain. The data is stored in JSON format and includes:

- Contract addresses
- First and last interaction blocks
- Total calls
- Unique wallets
- Average calls per wallet

## Technologies Used

- **Next.js**: React framework for server-rendered applications
- **shadcn/ui**: High-quality UI components built with Radix UI and Tailwind CSS
- **TypeScript**: Type-safe JavaScript
- **Tailwind CSS**: Utility-first CSS framework
