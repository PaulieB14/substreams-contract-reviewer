import { NextResponse } from 'next/server';
import fs from 'fs';
import path from 'path';
import { ContractAnalysis } from '@/lib/data';

export async function GET() {
  try {
    // Path to the results directory (relative to the project root)
    const resultsPath = path.join(process.cwd(), 'public', 'results', 'latest_analysis.json');
    
    // Read the file
    const data = fs.readFileSync(resultsPath, 'utf8');
    
    // Parse the JSON
    const contractData = JSON.parse(data) as ContractAnalysis;
    
    // Return the data as JSON
    return NextResponse.json(contractData);
  } catch (error) {
    console.error('Error loading contract data:', error);
    
    // Return empty data structure if file can't be read
    return NextResponse.json({
      most_active_contracts: [],
      most_popular_contracts: [],
      most_intensive_contracts: [],
      newest_contracts: [],
      total_contracts_analyzed: 0,
      analysis_timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}
