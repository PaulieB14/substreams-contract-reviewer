"use client";

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ContractsTable } from "@/components/contracts-table";
import { ContractAnalysis } from "@/lib/data";

interface ContractTabsProps {
  data: ContractAnalysis;
}

export function ContractTabs({ data }: ContractTabsProps) {
  return (
    <Tabs defaultValue="most-active" className="space-y-6">
      <div className="border-b overflow-x-auto">
        <TabsList className="w-full justify-start rounded-none border-b-0 bg-transparent p-0 flex-nowrap">
          <TabsTrigger 
            value="most-active" 
            className="rounded-t-lg border-b-2 border-transparent data-[state=active]:border-indigo-600 data-[state=active]:bg-indigo-50 data-[state=active]:text-indigo-700 dark:data-[state=active]:bg-indigo-950 dark:data-[state=active]:text-indigo-300 px-3 sm:px-6 py-3 whitespace-nowrap"
          >
            Most Active
          </TabsTrigger>
          <TabsTrigger 
            value="most-popular" 
            className="rounded-t-lg border-b-2 border-transparent data-[state=active]:border-red-600 data-[state=active]:bg-red-50 data-[state=active]:text-red-700 dark:data-[state=active]:bg-red-950 dark:data-[state=active]:text-red-300 px-3 sm:px-6 py-3 whitespace-nowrap"
          >
            Most Popular
          </TabsTrigger>
          <TabsTrigger 
            value="most-intensive" 
            className="rounded-t-lg border-b-2 border-transparent data-[state=active]:border-purple-600 data-[state=active]:bg-purple-50 data-[state=active]:text-purple-700 dark:data-[state=active]:bg-purple-950 dark:data-[state=active]:text-purple-300 px-3 sm:px-6 py-3 whitespace-nowrap"
          >
            Most Intensive
          </TabsTrigger>
          <TabsTrigger 
            value="newest" 
            className="rounded-t-lg border-b-2 border-transparent data-[state=active]:border-green-600 data-[state=active]:bg-green-50 data-[state=active]:text-green-700 dark:data-[state=active]:bg-green-950 dark:data-[state=active]:text-green-300 px-3 sm:px-6 py-3 whitespace-nowrap"
          >
            Newest
          </TabsTrigger>
        </TabsList>
      </div>
      <TabsContent value="most-active" className="pt-4">
        <ContractsTable 
          contracts={data.most_active_contracts} 
          title="Most Active Smart Contracts (by Total Calls)" 
        />
      </TabsContent>
      <TabsContent value="most-popular" className="pt-4">
        <ContractsTable 
          contracts={data.most_popular_contracts} 
          title="Most Popular Smart Contracts (by Unique Wallets)" 
        />
      </TabsContent>
      <TabsContent value="most-intensive" className="pt-4">
        <ContractsTable 
          contracts={data.most_intensive_contracts} 
          title="Most Intensive Smart Contracts (by Avg Calls/Wallet)" 
        />
      </TabsContent>
      <TabsContent value="newest" className="pt-4">
        <ContractsTable 
          contracts={data.newest_contracts} 
          title="Newest Smart Contracts (by First Interaction)" 
        />
      </TabsContent>
    </Tabs>
  );
}
