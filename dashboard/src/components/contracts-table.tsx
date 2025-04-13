import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ContractAddress } from "@/components/contract-address";
import { Contract } from "@/lib/data";
import { formatNumber } from "@/lib/data";

interface ContractsTableProps {
  contracts: Contract[];
  title: string;
  showNewFlag?: boolean;
}

export function ContractsTable({ contracts, title, showNewFlag = true }: ContractsTableProps) {
  // Format timestamp to readable date
  const formatTimestamp = (timestamp?: number) => {
    if (!timestamp) return "-";
    return new Date(timestamp * 1000).toLocaleDateString();
  };

  // Estimate block timestamp based on current block and average block time
  // Ethereum mainnet has ~13 second block time
  const estimateBlockTimestamp = (blockNumber: number) => {
    // Get the current block from the first contract's last_interaction_block
    const currentBlock = contracts[0]?.last_interaction_block || 0;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    
    // Calculate the timestamp based on block difference and average block time (13 seconds)
    const blockDifference = currentBlock - blockNumber;
    const estimatedTimestamp = currentTimestamp - (blockDifference * 13);
    
    return new Date(estimatedTimestamp * 1000).toLocaleDateString();
  };

  // Mobile card view for each contract
  const MobileContractCard = ({ contract }: { contract: Contract }) => (
    <div className={`p-4 border rounded-md mb-4 ${contract.is_new_contract ? "bg-green-50 dark:bg-green-900/20" : "bg-white dark:bg-gray-800"}`}>
      <div className="flex justify-between items-start mb-3">
        <div>
          <ContractAddress address={contract.address} />
        </div>
        {showNewFlag && (
          <div>
            {contract.is_new_contract ? 
              <span className="px-2 py-1 bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300 rounded-full text-xs font-medium">New</span> : 
              <span className="px-2 py-1 bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300 rounded-full text-xs font-medium">Returning</span>
            }
          </div>
        )}
      </div>
      
      <div className="grid grid-cols-2 gap-2 text-sm">
        <div className="space-y-2">
          <div>
            <p className="text-gray-500 dark:text-gray-400">First Block</p>
            <p className="font-medium">{formatNumber(contract.first_interaction_block)}</p>
          </div>
          <div>
            <p className="text-gray-500 dark:text-gray-400">First Seen</p>
            <p className="font-medium">{estimateBlockTimestamp(contract.first_interaction_block)}</p>
          </div>
          <div>
            <p className="text-gray-500 dark:text-gray-400">Last Block</p>
            <p className="font-medium">{formatNumber(contract.last_interaction_block)}</p>
          </div>
        </div>
        
        <div className="space-y-2">
          <div>
            <p className="text-gray-500 dark:text-gray-400">Total Calls</p>
            <p className="font-medium">{formatNumber(contract.total_calls)}</p>
          </div>
          <div>
            <p className="text-gray-500 dark:text-gray-400">Unique Wallets</p>
            <p className="font-medium">{formatNumber(contract.unique_wallets)}</p>
          </div>
          <div>
            <p className="text-gray-500 dark:text-gray-400">Avg Calls/Wallet</p>
            <p className="font-medium">{contract.avg_calls_per_wallet.toFixed(2)}</p>
          </div>
        </div>
      </div>
      
      <div className="mt-3 text-right text-xs text-gray-500 dark:text-gray-400">
        Analysis: {contract.day_timestamp ? formatTimestamp(contract.day_timestamp) : "Today"}
      </div>
    </div>
  );

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold">{title}</h2>
      
      {/* Mobile view (card layout) */}
      <div className="md:hidden">
        {contracts.length === 0 ? (
          <div className="text-center p-4 border rounded-md">
            No contracts found
          </div>
        ) : (
          <div className="space-y-4">
            {contracts.map((contract) => (
              <MobileContractCard 
                key={`mobile-${contract.address}-${contract.first_interaction_block}`} 
                contract={contract} 
              />
            ))}
          </div>
        )}
      </div>
      
      {/* Desktop view (table layout) */}
      <div className="hidden md:block rounded-md border">
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  <span title="Ethereum contract address (click to view on Etherscan)">
                    Contract Address
                  </span>
                </TableHead>
                {showNewFlag && <TableHead className="text-center">
                  <span title="Indicates if this is a new contract or one that has been seen before">
                    New?
                  </span>
                </TableHead>}
                <TableHead className="text-right">
                  <span title="Ethereum block number when this contract was first observed in the analysis period">
                    First Block #
                  </span>
                </TableHead>
                <TableHead className="text-right">
                  <span title="Estimated calendar date when this contract was first observed">
                    First Seen Date
                  </span>
                </TableHead>
                <TableHead className="text-right">
                  <span title="Most recent Ethereum block number where this contract was observed">
                    Last Block #
                  </span>
                </TableHead>
                <TableHead className="text-right">
                  <span title="Total number of times this contract was called during the analysis period">
                    Total Calls
                  </span>
                </TableHead>
                <TableHead className="text-right">
                  <span title="Number of different wallet addresses that interacted with this contract">
                    Unique Wallets
                  </span>
                </TableHead>
                <TableHead className="text-right">
                  <span title="Average number of calls per unique wallet (Total Calls ÷ Unique Wallets)">
                    Avg Calls/Wallet
                  </span>
                </TableHead>
                <TableHead className="text-right">
                  <span title="Date when this data was recorded">
                    Analysis Date
                  </span>
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {contracts.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={showNewFlag ? 9 : 8} className="text-center">
                    No contracts found
                  </TableCell>
                </TableRow>
              ) : (
                contracts.map((contract) => (
                  <TableRow 
                    key={`${contract.address}-${contract.first_interaction_block}`}
                    className={contract.is_new_contract ? "bg-green-50 dark:bg-green-900/20" : ""}
                  >
                    <TableCell>
                      <ContractAddress address={contract.address} />
                    </TableCell>
                    {showNewFlag && (
                      <TableCell className="text-center">
                        {contract.is_new_contract ? 
                          <span className="px-2 py-1 bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300 rounded-full text-xs font-medium">New</span> : 
                          <span className="px-2 py-1 bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300 rounded-full text-xs font-medium">Returning</span>
                        }
                      </TableCell>
                    )}
                    <TableCell className="text-right">
                      <span title="Block number when this contract was first observed">
                        {formatNumber(contract.first_interaction_block)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <span title="Estimated date when this contract was first observed">
                        {estimateBlockTimestamp(contract.first_interaction_block)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <span title="Most recent block number where this contract was observed">
                        {formatNumber(contract.last_interaction_block)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <span title="Total number of times this contract was called">
                        {formatNumber(contract.total_calls)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <span title="Number of different wallet addresses that interacted with this contract">
                        {formatNumber(contract.unique_wallets)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <span title="Average number of calls per unique wallet">
                        {contract.avg_calls_per_wallet.toFixed(2)}
                      </span>
                    </TableCell>
                    <TableCell className="text-right">
                      <span title="Date when this data was recorded">
                        {contract.day_timestamp ? formatTimestamp(contract.day_timestamp) : "Today"}
                      </span>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>
      </div>
    </div>
  );
}
