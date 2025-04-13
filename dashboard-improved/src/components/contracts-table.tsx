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
}

export function ContractsTable({ contracts, title }: ContractsTableProps) {
  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold">{title}</h2>
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Contract Address</TableHead>
              <TableHead className="text-right">First Block</TableHead>
              <TableHead className="text-right">Last Block</TableHead>
              <TableHead className="text-right">Total Calls</TableHead>
              <TableHead className="text-right">Unique Wallets</TableHead>
              <TableHead className="text-right">Avg Calls/Wallet</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {contracts.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center">
                  No contracts found
                </TableCell>
              </TableRow>
            ) : (
              contracts.map((contract) => (
                <TableRow key={`${contract.address}-${contract.first_interaction_block}`}>
                  <TableCell>
                    <ContractAddress address={contract.address} />
                  </TableCell>
                  <TableCell className="text-right">
                    {formatNumber(contract.first_interaction_block)}
                  </TableCell>
                  <TableCell className="text-right">
                    {formatNumber(contract.last_interaction_block)}
                  </TableCell>
                  <TableCell className="text-right">
                    {formatNumber(contract.total_calls)}
                  </TableCell>
                  <TableCell className="text-right">
                    {formatNumber(contract.unique_wallets)}
                  </TableCell>
                  <TableCell className="text-right">
                    {contract.avg_calls_per_wallet.toFixed(2)}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
