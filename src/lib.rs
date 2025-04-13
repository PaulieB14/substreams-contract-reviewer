use substreams_ethereum::pb::eth::v2::{Block, Transaction};
use substreams_ethereum::pb::eth::v2::transaction::TransactionTraceStatus;
use std::collections::HashMap;
use substreams::store::{StoreGet, StoreGetProto, StoreSetProto};
use std::cmp::min;
use substreams_ethereum::Function;

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
    let day_timestamp = (block.timestamp().seconds / 86400) * 86400; // Normalize to day

    // First pass: identify contract creations to build a set of known contracts
    let mut known_contracts: std::collections::HashSet<String> = std::collections::HashSet::new();
    
    // Add contract creations from this block
    for tx in block.transactions() {
        // Check if this is a contract creation (to is empty)
        if tx.to.is_empty() && tx.status == 1 { // 1 = Success
            if let Some(receipt) = &tx.receipt {
                if !receipt.contract_address.is_empty() {
                    let addr = hex::encode(&receipt.contract_address);
                    known_contracts.insert(addr);
                }
            }
        }
    }
    
    // Process call traces for contract interactions
    for call in block.calls() {
        // Only process CALL type (not delegatecall, create, etc.)
        if call.r#type != 0 {
            continue;
        }
        
        // Skip if no 'to' address
        if call.to.is_empty() {
            continue;
        }
        
        let contract_addr = hex::encode(&call.to);
        
        // More strict contract verification:
        // 1. Address is in our known contracts set from this block, OR
        // 2. The call has function selector (input > 4 bytes) AND was successful
        let is_likely_contract = known_contracts.contains(&contract_addr) || 
                                 (call.input.len() > 4 && call.success);
        
        if is_likely_contract {
            let from_addr = hex::encode(&call.from);
            
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
