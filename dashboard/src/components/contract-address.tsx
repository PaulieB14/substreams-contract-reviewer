"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { 
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Copy, ExternalLink, MoreHorizontal, Wallet, FileCode } from "lucide-react";

interface ContractAddressProps {
  address: string;
}

export function ContractAddress({ address }: ContractAddressProps) {
  const [copied, setCopied] = useState(false);
  const [isContract, setIsContract] = useState<boolean | null>(null);

  useEffect(() => {
    // Check if this is a contract or wallet address using Etherscan API
    // This is a simplified check - in production you would use a proper API with rate limiting
    const checkAddressType = async () => {
      try {
        // We're not actually making the API call here to avoid rate limits
        // In a real implementation, you would use the Etherscan API or similar
        
        // For now, we'll use a simple heuristic based on address patterns
        // This is just for demonstration - not reliable in production
        const knownContracts = [
          "dac17f958d2ee523a2206206994597c13d831ec7", // USDT
          "a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", // USDC
          "c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", // WETH
          "68d3a973e7272eb388022a5c6518d9b2a2e66fbf", // Known contract
          "9030a104a49141459f4b419bd6f56e4ba6fcd800", // Known contract
          "66a9893cc07d91d95644aedd05d03f95e1dba8af", // Known contract
          "b326ae62522ae2aa4d5a808faa9bbc0c5b9e740f"  // Known contract
        ];
        
        // Check if address is in our known contracts list
        setIsContract(knownContracts.includes(address.toLowerCase()));
      } catch (error) {
        console.error("Error checking address type:", error);
        setIsContract(null);
      }
    };
    
    checkAddressType();
  }, [address]);

  const copyToClipboard = () => {
    navigator.clipboard.writeText(address);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const openEtherscan = () => {
    window.open(`https://etherscan.io/address/${address}`, '_blank');
  };

  // Format address for display
  const formatAddress = (address: string, isMobile: boolean = false) => {
    if (!address) return '-';
    if (isMobile) {
      return `${address.substring(0, 6)}...${address.substring(address.length - 4)}`;
    }
    return address;
  };

  return (
    <div className="relative group">
      <div className="flex items-center space-x-2">
        {/* Address type indicator */}
        {isContract !== null && (
          <div className="text-xs" title={isContract ? "Contract Address" : "Wallet Address"}>
            {isContract ? (
              <FileCode className="h-4 w-4 text-purple-500" />
            ) : (
              <Wallet className="h-4 w-4 text-blue-500" />
            )}
          </div>
        )}
        
        {/* Mobile view: Truncated address */}
        <div className="md:hidden font-mono text-sm bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded flex items-center">
          {formatAddress(address, true)}
          {isContract !== null && (
            <span className="ml-1 text-xs px-1 rounded" title={isContract ? "Contract Address" : "Wallet Address"}>
              {isContract ? "Contract" : "Wallet"}
            </span>
          )}
        </div>
        
        {/* Desktop view: Full address */}
        <div className="hidden md:block font-mono text-sm bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded flex items-center">
          {address}
          {isContract !== null && (
            <span className="ml-2 text-xs px-1 rounded" title={isContract ? "Contract Address" : "Wallet Address"}>
              {isContract ? "Contract" : "Wallet"}
            </span>
          )}
        </div>
        
        <div className="flex gap-1">
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-8 w-8 md:opacity-0 md:group-hover:opacity-100 transition-opacity" 
            onClick={copyToClipboard}
            title="Copy to clipboard"
          >
            <Copy className="h-4 w-4" />
          </Button>
          <Button 
            variant="ghost" 
            size="icon" 
            className="h-8 w-8 md:opacity-0 md:group-hover:opacity-100 transition-opacity" 
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
            className="h-6 w-6 md:opacity-0 md:group-hover:opacity-100 absolute right-0 top-1/2 transform -translate-y-1/2"
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
