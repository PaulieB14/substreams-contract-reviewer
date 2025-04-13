"use client";

import { useEffect, useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { formatNumber } from "@/lib/data";

interface BlockData {
  blockNumber: number;
  threeMonthsAgo: number;
  timestamp: string;
}

export function CurrentBlock() {
  const [blockData, setBlockData] = useState<BlockData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    async function fetchBlockData() {
      try {
        setLoading(true);
        const response = await fetch('/api/eth-block');
        
        if (!response.ok) {
          throw new Error(`API returned ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        setBlockData(data);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Failed to fetch block data'));
        console.error('Error fetching block data:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchBlockData();
    
    // Refresh block data every 15 seconds
    const intervalId = setInterval(fetchBlockData, 15000);
    
    return () => clearInterval(intervalId);
  }, []);

  // Calculate blocks per day
  const blocksPerDay = 24 * 60 * 60 / 12; // ~7200 blocks per day

  return (
    <Card className="bg-gradient-to-r from-indigo-600 via-purple-600 to-indigo-800 text-white shadow-lg border-none overflow-hidden">
      <CardContent className="p-0">
        <div className="flex flex-col md:flex-row">
          {/* Network Status */}
          <div className="bg-black/20 p-4 flex items-center justify-center md:justify-start md:w-1/4">
            <div className="mr-3 h-3 w-3 rounded-full bg-green-400 animate-pulse"></div>
            <div>
              <div className="font-medium">Ethereum Mainnet</div>
              <div className="text-xs text-green-300">Connected</div>
            </div>
          </div>
          
          {/* Mobile view: Grid layout for the three data points */}
          <div className="grid grid-cols-1 sm:grid-cols-3 md:hidden w-full">
            {/* Current Block */}
            <div className="p-4 border-t border-white/10 flex flex-col items-center justify-center">
              <div className="text-xs uppercase tracking-wider text-indigo-200 text-center">Current Block</div>
              {loading ? (
                <div className="h-8 w-32 bg-white/20 animate-pulse rounded mt-1"></div>
              ) : error ? (
                <div className="text-red-300 font-medium">Error loading</div>
              ) : (
                <div className="font-mono text-xl font-bold mt-1">
                  {formatNumber(blockData?.blockNumber || 0)}
                </div>
              )}
            </div>
            
            {/* Analysis Range */}
            <div className="p-4 border-t border-white/10 flex flex-col items-center justify-center">
              <div className="text-xs uppercase tracking-wider text-indigo-200 text-center">Analysis Range</div>
              {loading ? (
                <div className="h-8 w-32 bg-white/20 animate-pulse rounded mt-1"></div>
              ) : error ? (
                <div className="text-red-300 font-medium">Error loading</div>
              ) : (
                <div className="font-mono text-xs font-medium mt-1 text-center">
                  {formatNumber(blockData?.threeMonthsAgo || 0)} → {formatNumber(blockData?.blockNumber || 0)}
                </div>
              )}
            </div>
            
            {/* Blocks Per Day */}
            <div className="p-4 border-t border-white/10 flex flex-col items-center justify-center">
              <div className="text-xs uppercase tracking-wider text-indigo-200 text-center">Blocks/Day</div>
              <div className="font-mono text-lg font-medium mt-1">
                ~{formatNumber(Math.round(blocksPerDay))}
              </div>
            </div>
          </div>
          
          {/* Desktop view: Horizontal layout */}
          <div className="hidden md:flex flex-1">
            {/* Current Block */}
            <div className="p-4 flex-1 flex items-center justify-start border-l border-white/10">
              <div className="text-left">
                <div className="text-xs uppercase tracking-wider text-indigo-200">Current Block</div>
                {loading ? (
                  <div className="h-8 w-32 bg-white/20 animate-pulse rounded mt-1"></div>
                ) : error ? (
                  <div className="text-red-300 font-medium">Error loading</div>
                ) : (
                  <div className="font-mono text-2xl font-bold">
                    {formatNumber(blockData?.blockNumber || 0)}
                  </div>
                )}
              </div>
            </div>
            
            {/* Analysis Range */}
            <div className="p-4 flex-1 flex items-center justify-start border-l border-white/10">
              <div className="text-left">
                <div className="text-xs uppercase tracking-wider text-indigo-200">3-Month Analysis Range</div>
                {loading ? (
                  <div className="h-8 w-48 bg-white/20 animate-pulse rounded mt-1"></div>
                ) : error ? (
                  <div className="text-red-300 font-medium">Error loading</div>
                ) : (
                  <div className="font-mono text-sm font-medium mt-1">
                    Block {formatNumber(blockData?.threeMonthsAgo || 0)} → {formatNumber(blockData?.blockNumber || 0)}
                  </div>
                )}
              </div>
            </div>
            
            {/* Blocks Per Day */}
            <div className="p-4 flex-1 flex items-center justify-start border-l border-white/10">
              <div className="text-left">
                <div className="text-xs uppercase tracking-wider text-indigo-200">Blocks Per Day</div>
                <div className="font-mono text-lg font-medium">
                  ~{formatNumber(Math.round(blocksPerDay))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
