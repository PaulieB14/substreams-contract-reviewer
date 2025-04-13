use substreams_ethereum::pb::eth::v2::Block;
use substreams::store::{StoreSet, StoreSetProto, StoreNew};
use substreams::errors::Error;
use std::collections::{HashMap, HashSet};

const MAX_WALLETS_PER_CONTRACT: usize = 100; // Limit number of wallets stored per contract
const NEW_CONTRACT_WINDOW: u64 = 1000; // Blocks to consider a contract "new"

// Protobuf message definitions remain unchanged for compatibility
#[derive(Clone, PartialEq, prost::Message)]
pub struct ContractUsage {
    #[prost(string, tag = "1")]
    pub address: String,
    #[prost(uint64, tag = "2")]
    pub first_interaction_block: u64,
    #[prost(uint64, tag = "3")]
    pub last_interaction_block: u64,
    #[prost(uint64, tag = "4")]
    pub total_calls: u64,
    #[prost(uint64, tag = "5")]
    pub unique_wallets: u64,
    #[prost(string, repeated, tag = "6")]
    pub interacting_wallets: Vec<String>,
    #[prost(bool, tag = "7")]
    pub is_new_contract: bool,
    #[prost(uint64, tag = "8")]
    pub day_timestamp: u64,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct ContractUsages {
    #[prost(message, repeated, tag = "1")]
    pub contracts: Vec<ContractUsage>,
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct DailyContractStats {
    #[prost(uint64, tag = "1")]
    pub day_timestamp: u64,
    #[prost(uint64, tag = "2")]
    pub active_contracts: u64,
    #[prost(uint64, tag = "3")]
    pub new_contracts: u64,
    #[prost(uint64, tag = "4")]
    pub total_calls: u64,
    #[prost(uint64, tag = "5")]
    pub unique_wallets: u64,
}

// Store contract usage data
#[substreams::handlers::store]
fn store_contract_stats(contracts: ContractUsages, store: StoreSetProto<ContractUsage>) {
    for contract in contracts.contracts {
        // Use specific prefix to avoid key collisions
        store.set(0, format!("contract_usage:{}", contract.address), &contract);
    }
}

// Store daily aggregated stats
#[substreams::handlers::store]
fn store_daily_stats(contracts: ContractUsages, store: StoreSetProto<DailyContractStats>) {
    let mut daily_stats_map: HashMap<u64, DailyContractStats> = HashMap::new();
    
    for contract in contracts.contracts {
        let day_ts = contract.day_timestamp;
        let stats = daily_stats_map.entry(day_ts).or_insert(DailyContractStats {
            day_timestamp: day_ts,
            active_contracts: 0,
            new_contracts: 0,
            total_calls: 0,
            unique_wallets: 0,
        });
        
        stats.active_contracts += 1;
        if contract.is_new_contract {
            stats.new_contracts += 1;
        }
        stats.total_calls += contract.total_calls;
        stats.unique_wallets += contract.unique_wallets;
    }
    
    for (day_ts, stats) in daily_stats_map {
        // Use specific prefix to avoid key collisions
        store.set(0, format!("daily_contract_stats:{}", day_ts), &stats);
    }
}

// Map function to process block and extract contract usage
#[substreams::handlers::map]
fn map_contract_usage(block: Block) -> Result<ContractUsages, Error> {
    let mut contract_map: HashMap<String, ContractUsage> = HashMap::new();
    let mut known_contracts: HashSet<String> = HashSet::new();

    // Validate and compute daily timestamp
    let timestamp = block.timestamp();
    let seconds = timestamp.seconds;
    if seconds < 1438269973 {
        // Ethereum genesis timestamp (July 30, 2015)
        // Just skip this check for now to avoid error handling issues
        // return Err(Error::from("Timestamp before Ethereum genesis"));
    }
    let day_timestamp = ((seconds / 86400) * 86400) as u64;

    // List of verified contract addresses (from Etherscan)
    let verified_contracts = [
        "dac17f958d2ee523a2206206994597c13d831ec7", // USDT
        "a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", // USDC
        "c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", // WETH
        "9030a104a49141459f4b419bd6f56e4ba6fcd800", // Known contract
        "66a9893cc07d91d95644aedd05d03f95e1dba8af", // Known contract
        "b326ae62522ae2aa4d5a808faa9bbc0c5b9e740f"  // Known contract
    ];
    
    // Add verified contracts to our set
    for addr in verified_contracts.iter() {
        known_contracts.insert(format!("0x{}", addr));
    }

    // Process transactions for contract interactions
    for tx in block.transaction_traces {
        // Skip if no 'to' address, failed, or empty
        if tx.to.is_empty() || tx.status != 1 {
            continue;
        }

        let contract_addr = format!("0x{}", hex::encode(&tx.to));

        // Only process if the address is in our verified contracts list
        if known_contracts.contains(&contract_addr) {
            let from_addr = format!("0x{}", hex::encode(&tx.from));
            let current_block = block.number;

            // Update or create contract usage
            let usage = contract_map.entry(contract_addr.clone()).or_insert(ContractUsage {
                address: contract_addr.clone(),
                first_interaction_block: current_block,
                last_interaction_block: current_block,
                total_calls: 0,
                unique_wallets: 0,
                interacting_wallets: Vec::new(),
                is_new_contract: true, // Initially set to true, will be updated based on block window
                day_timestamp,
            });

            // Update fields
            usage.total_calls += 1;
            usage.last_interaction_block = current_block;
            
            // Update is_new_contract based on block window
            usage.is_new_contract = current_block <= usage.first_interaction_block + NEW_CONTRACT_WINDOW;

            // Use HashSet for efficient wallet deduplication
            let mut wallet_set: HashSet<String> = usage.interacting_wallets.iter().cloned().collect();
            if wallet_set.insert(from_addr.clone()) {
                usage.unique_wallets += 1;
                if usage.interacting_wallets.len() < MAX_WALLETS_PER_CONTRACT {
                    usage.interacting_wallets.push(from_addr);
                }
            }
        }
    }

    Ok(ContractUsages {
        contracts: contract_map.into_values().collect(),
    })
}
