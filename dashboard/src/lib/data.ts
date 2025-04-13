export interface Contract {
  address: string;
  first_interaction_block: number;
  last_interaction_block: number;
  total_calls: number;
  unique_wallets: number;
  avg_calls_per_wallet: number;
  interacting_wallets: string[];
}

export interface ContractAnalysis {
  most_active_contracts: Contract[];
  most_popular_contracts: Contract[];
  most_intensive_contracts: Contract[];
  newest_contracts: Contract[];
  total_contracts_analyzed: number;
  analysis_timestamp: string;
}

export async function getContractData(): Promise<ContractAnalysis> {
  try {
    // Get the base URL from environment variables or use an empty string for relative paths
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || '';
    
    // Fetch data from a static JSON file in the public directory
    const response = await fetch(`${baseUrl}/results/latest_analysis.json`);
    
    if (!response.ok) {
      throw new Error(`Failed to fetch data: ${response.status} ${response.statusText}`);
    }
    
    // Parse the JSON response
    return await response.json() as ContractAnalysis;
  } catch (error) {
    console.error('Error loading contract data:', error);
    
    // Return empty data structure if API call fails
    return {
      most_active_contracts: [],
      most_popular_contracts: [],
      most_intensive_contracts: [],
      newest_contracts: [],
      total_contracts_analyzed: 0,
      analysis_timestamp: new Date().toISOString()
    };
  }
}

// Helper function to format addresses for display
export function formatAddress(address: string): string {
  if (!address) return '-';
  return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
}

// Helper function to format numbers with commas
export function formatNumber(num: number): string {
  // For integers, just add commas
  if (Number.isInteger(num)) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }
  
  // For decimals, limit to 2 decimal places
  return num.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
