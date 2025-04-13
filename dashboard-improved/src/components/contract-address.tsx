"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { 
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Copy, ExternalLink, MoreHorizontal } from "lucide-react";

interface ContractAddressProps {
  address: string;
}

export function ContractAddress({ address }: ContractAddressProps) {
  const [copied, setCopied] = useState(false);

  const copyToClipboard = () => {
    navigator.clipboard.writeText(address);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const openEtherscan = () => {
    window.open(`https://etherscan.io/address/${address}`, '_blank');
  };

  return (
    <div className="relative group">
      <div className="flex items-center space-x-2">
        <div className="font-mono text-sm bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded">
          {address}
        </div>
        <div className="flex gap-1">
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity" 
            onClick={copyToClipboard}
            title="Copy to clipboard"
          >
            <Copy className="h-4 w-4" />
          </Button>
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity" 
            onClick={openEtherscan}
            title="View on Etherscan"
          >
            <ExternalLink className="h-4 w-4" />
          </Button>
        </div>
      </div>
      {copied && (
        <div className="absolute top-full left-0 text-xs text-green-600 mt-1">
          Copied to clipboard!
        </div>
      )}

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-6 w-6 opacity-0 group-hover:opacity-100 absolute right-0 top-1/2 transform -translate-y-1/2"
          >
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={copyToClipboard}>
            <Copy className="mr-2 h-4 w-4" />
            <span>Copy address</span>
          </DropdownMenuItem>
          <DropdownMenuItem onClick={openEtherscan}>
            <ExternalLink className="mr-2 h-4 w-4" />
            <span>View on Etherscan</span>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
}
