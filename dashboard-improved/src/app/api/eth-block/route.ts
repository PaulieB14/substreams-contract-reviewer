import { NextResponse } from 'next/server';

// Function to estimate the current Ethereum block number
function estimateCurrentBlock(): number {
  // This is a reliable estimation method based on known block times
  // Block 16,900,000 was around April 1, 2023
  const now = new Date();
  const april2023 = new Date('2023-04-01');
  const secondsSince = Math.floor((now.getTime() - april2023.getTime()) / 1000);
  
  // Ethereum averages 1 block every 12 seconds
  const blocksPerSecond = 1 / 12;
  const blocksSince = Math.floor(secondsSince * blocksPerSecond);
  
  return 16900000 + blocksSince;
}

export async function GET() {
  const blockNumber = estimateCurrentBlock();
  
  // Also calculate some useful stats
  const blocksPerDay = 24 * 60 * 60 / 12; // ~7200 blocks per day
  const blocksPerMonth = blocksPerDay * 30; // ~216,000 blocks per month
  const threeMonthsAgo = blockNumber - (blocksPerMonth * 3);
  
  return NextResponse.json({
    blockNumber,
    threeMonthsAgo: Math.floor(threeMonthsAgo),
    timestamp: new Date().toISOString()
  });
}
