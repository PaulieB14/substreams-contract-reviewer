use substreams_ethereum::pb::eth::v2::Block;
use std::collections::HashMap;
use substreams::store::{StoreSet, StoreSetProto, StoreNew};

const MAX_WALLETS_PER_CONTRACT: usize = 100; // Limit number of wallets stored per contract
const NEW_CONTRACT_WINDOW: u64 = 1000; // Number of blocks to consider a contract "new"

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
pub struct WalletInteraction {
    #[prost(string, tag = "1")]
    pub wallet_address: String,
    #[prost(uint64, tag = "2")]
    pub interaction_count: u64,
    #[prost(uint64, tag = "3")]
    pub first_interaction_block: u64,
    #[prost(uint64, tag = "4")]
    pub last_interaction_block: u64,
    #[prost(bool, tag = "5")]
    pub is_repeat_user: bool,
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

#[substreams::handlers::store]
fn store_contract_stats(contracts: ContractUsages, store: StoreSetProto<ContractUsage>) {
    for contract in contracts.contracts {
        store.set(0, format!("contract:{}", contract.address).into_bytes(), &contract);
    }
}

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
        store.set(0, format!("daily:{}", day_ts).into_bytes(), &stats);
    }
}

#[substreams::handlers::map]
fn map_contract_usage(block: Block) -> Result<ContractUsages, substreams::errors::Error> {
    let mut contract_map: HashMap<String, ContractUsage> = HashMap::new();
    let day_timestamp = ((block.timestamp().seconds / 86400) * 86400) as u64; // Normalize to day and convert to u64

    // First pass: identify contract creations to build a set of known contracts
    let mut known_contracts: std::collections::HashSet<String> = std::collections::HashSet::new();
    
    // For simplicity, we'll use a list of known contract addresses
    // In a production environment, you would use a more robust method to identify contracts
    let known_contract_addresses = [
        "dac17f958d2ee523a2206206994597c13d831ec7", // USDT
        "a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48", // USDC
        "c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", // WETH
        "68d3a973e7272eb388022a5c6518d9b2a2e66fbf", // Known contract
        "9030a104a49141459f4b419bd6f56e4ba6fcd800", // Known contract
        "66a9893cc07d91d95644aedd05d03f95e1dba8af", // Known contract
        "b326ae62522ae2aa4d5a808faa9bbc0c5b9e740f"  // Known contract
    ];
    
    // Add known contracts to our set
    for addr in known_contract_addresses.iter() {
        known_contracts.insert(addr.to_string());
    }
    
    // Process transactions for contract interactions
    for tx in block.transactions() {
        // Skip if no 'to' address or if it's empty
        if tx.to.is_empty() {
            continue;
        }
        
        let contract_addr = hex::encode(&tx.to);
        
        // More strict contract verification:
        // 1. Address is in our known contracts set from this block, OR
        // 2. The transaction has function selector (input > 4 bytes) AND was successful
        let is_likely_contract = known_contracts.contains(&contract_addr) || 
                                 (tx.input.len() > 4 && tx.status == 1);
        
        if is_likely_contract {
            let from_addr = hex::encode(&tx.from);
            
            // Check if contract exists in our map
            if let Some(usage) = contract_map.get_mut(&contract_addr) {
                // Contract already seen in this block
                usage.total_calls += 1;
                
                // Check if this wallet has interacted before
                if !usage.interacting_wallets.contains(&from_addr) {
                    // Limit the number of wallets we store
                    if usage.interacting_wallets.len() < MAX_WALLETS_PER_CONTRACT {
                        usage.interacting_wallets.push(from_addr);
                    }
                    usage.unique_wallets += 1;
                }
            } else {
                // New contract in this block
                contract_map.insert(contract_addr.clone(), ContractUsage {
                    address: contract_addr.clone(),
                    first_interaction_block: block.number,
                    last_interaction_block: block.number,
                    total_calls: 1,
                    unique_wallets: 1,
                    interacting_wallets: vec![from_addr],
                    is_new_contract: true,
                    day_timestamp,
                });
            }
        }
    }

    Ok(ContractUsages {
        contracts: contract_map.into_values().collect(),
    })
}
