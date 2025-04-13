"use client";

import { useEffect, useState } from "react";
import { StatsCard } from "@/components/stats-card";
import { ContractTabs } from "@/components/contract-tabs";
import { ContractChart } from "@/components/contract-chart";
import { CurrentBlock } from "@/components/current-block";
import { DailyStatsChart } from "@/components/daily-stats-chart";
import { ContractAnalysis, getContractData } from "@/lib/data";

export function ClientPage() {
  const [data, setData] = useState<ContractAnalysis | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        setLoading(true);
        const contractData = await getContractData();
        console.log("Fetched contract data:", contractData);
        console.log("Daily stats:", contractData.daily_stats);
        console.log("New vs returning:", contractData.new_vs_returning_contracts);
        setData(contractData);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Failed to fetch data'));
        console.error('Error fetching contract data:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center">
        <div className="flex flex-col items-center space-y-4">
          <div className="h-16 w-16 animate-spin rounded-full border-t-4 border-b-4 border-primary"></div>
          <h2 className="text-xl font-semibold">Loading contract data...</h2>
          <p className="text-sm text-muted-foreground">Fetching real blockchain data from Ethereum mainnet</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center">
        <div className="flex flex-col items-center space-y-4 max-w-md text-center">
          <h2 className="text-2xl font-bold">Something went wrong!</h2>
          <p className="text-muted-foreground">
            We couldn&apos;t load the contract data. This might be because the data file is missing or there was a problem with the API.
          </p>
          <div className="text-sm text-muted-foreground mt-8 p-4 bg-muted rounded-md">
            <p className="font-semibold">Error details:</p>
            <p className="font-mono text-xs mt-2">{error.message}</p>
          </div>
        </div>
      </div>
    );
  }

  if (!data) {
    return null;
  }

  // Format the timestamp
  const timestamp = new Date(data.analysis_timestamp);
  const formattedTimestamp = timestamp.toLocaleString();
  
  return (
    <div className="flex min-h-screen flex-col bg-gray-50 dark:bg-gray-900">
      <div className="flex-1 space-y-6 p-4 sm:p-6 md:p-8 pt-6">
        <CurrentBlock />
        
        <div className="flex items-center justify-between space-y-2 bg-white dark:bg-gray-800 p-4 rounded-lg shadow-sm mt-4">
          <h2 className="text-2xl md:text-3xl font-bold tracking-tight text-indigo-600 dark:text-indigo-400">Ethereum Contract Reviewer Dashboard</h2>
        </div>
        
        <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
          <StatsCard
            title="Total Contracts Analyzed"
            value={data.total_contracts_analyzed}
            description="Total number of unique contract addresses tracked"
          />
          <StatsCard
            title="Most Active Contract Calls"
            value={data.most_active_contracts[0]?.total_calls || 0}
            description="Highest number of calls to a single contract"
          />
          <StatsCard
            title="Most Unique Wallets"
            value={data.most_popular_contracts[0]?.unique_wallets || 0}
            description="Highest number of unique wallets interacting with a contract"
          />
          <StatsCard
            title="Highest Avg Calls/Wallet"
            value={data.most_intensive_contracts[0]?.avg_calls_per_wallet || 0}
            description="Most intensive contract usage per wallet"
          />
        </div>
        
        <div className="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
          {/* Contract charts */}
          <ContractChart 
            contracts={data.most_active_contracts} 
            title="Most Active Contracts" 
            type="calls"
            colorScheme={[
              'rgba(79, 70, 229, 0.7)', // Indigo
              'rgba(59, 130, 246, 0.7)', // Blue
              'rgba(16, 185, 129, 0.7)', // Green
            ]}
          />
          <ContractChart 
            contracts={data.most_popular_contracts} 
            title="Most Popular Contracts" 
            type="wallets"
            colorScheme={[
              'rgba(239, 68, 68, 0.7)', // Red
              'rgba(249, 115, 22, 0.7)', // Orange
              'rgba(234, 179, 8, 0.7)', // Yellow
            ]}
          />
          <ContractChart 
            contracts={data.most_intensive_contracts} 
            title="Most Intensive Contracts" 
            type="avg"
            colorScheme={[
              'rgba(139, 92, 246, 0.7)', // Purple
              'rgba(236, 72, 153, 0.7)', // Pink
              'rgba(20, 184, 166, 0.7)', // Teal
            ]}
          />
        </div>
        
        {/* Daily Stats Chart - shows time-based analysis */}
        {data.daily_stats && data.daily_stats.length > 0 && (
          <div className="grid gap-6 grid-cols-1 sm:grid-cols-2">
            <DailyStatsChart 
              dailyStats={data.daily_stats} 
              title="Daily Contract Activity" 
            />
            
            {/* New vs Returning Contracts */}
            {data.new_vs_returning_contracts && (
              <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-sm">
                <h2 className="text-xl font-bold mb-4">New vs Returning Contracts</h2>
                <div className="grid grid-cols-1 xs:grid-cols-2 gap-4">
                  <div className="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
                    <p className="text-sm text-muted-foreground">New Contracts</p>
                    <p className="text-3xl font-bold text-green-600 dark:text-green-400">
                      {data.new_vs_returning_contracts.new_contracts}
                    </p>
                    <p className="text-sm text-muted-foreground mt-2">
                      {((data.new_vs_returning_contracts.new_contracts / data.total_contracts_analyzed) * 100).toFixed(1)}% of total
                    </p>
                  </div>
                  <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
                    <p className="text-sm text-muted-foreground">Returning Contracts</p>
                    <p className="text-3xl font-bold text-blue-600 dark:text-blue-400">
                      {data.new_vs_returning_contracts.returning_contracts}
                    </p>
                    <p className="text-sm text-muted-foreground mt-2">
                      {((data.new_vs_returning_contracts.returning_contracts / data.total_contracts_analyzed) * 100).toFixed(1)}% of total
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
        
        <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-sm">
          <ContractTabs data={data} />
        </div>
        
        <div className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow-sm text-sm text-muted-foreground text-right">
          <p>Last updated: {formattedTimestamp}</p>
          <p>Data source: Substreams Contract Reviewer</p>
          <p className="font-semibold text-indigo-600 dark:text-indigo-400">
            Using real blockchain data from Ethereum mainnet (3-month analysis with 1000 blocks)
          </p>
          <p className="text-xs text-gray-500 mt-1">
            Data is aggregated across blocks to show meaningful patterns over time
          </p>
        </div>
      </div>
    </div>
  );
}
