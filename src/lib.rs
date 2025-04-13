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

// Helper function to check if an address is a contract
fn is_contract_address(trx: &Transaction) -> bool {
    // Check if the transaction has trace status
    if let Some(trace_status) = &trx.trace_status {
        // Check if it's a contract call (has function calls)
        match trace_status {
            TransactionTraceStatus::Success(_) => {
                // If the transaction has call data (beyond just a value transfer), it's likely a contract
                return !trx.input.is_empty() && trx.input.len() > 4; // At least function selector (4 bytes)
            }
            _ => return false,
        }
    }
    
    // If no trace status, check if input data exists (contract interaction)
    !trx.input.is_empty() && trx.input.len() > 4
}

#[substreams::handlers::map]
fn map_contract_usage(block: Block, store: StoreGetProto<ContractUsage>) -> Result<ContractUsages, substreams::errors::Error> {
    let mut contract_map: HashMap<String, ContractUsage> = HashMap::new();
    let day_timestamp = (block.timestamp().seconds / 86400) * 86400; // Normalize to day

    for trx in block.transactions() {
    // Only process transactions that have a 'to' address and are contract calls
    // Skip regular wallet-to-wallet transfers
    if !trx.to.is_empty() && is_contract_address(&trx) {
            let contract_addr = hex::encode(&trx.to);
            let from_addr = hex::encode(&trx.from);
            
            // Check if contract exists in store
            let store_key = format!("contract:{}", contract_addr).into_bytes();
            let is_new_contract = match store.get_last(store_key.as_slice()) {
                Some(existing) => {
                    // Contract exists in store
                    let mut usage = contract_map.entry(contract_addr.clone()).or_insert(ContractUsage {
                        address: contract_addr.clone(),
                        first_interaction_block: existing.first_interaction_block,
                        last_interaction_block: block.number,
                        total_calls: existing.total_calls,
                        unique_wallets: existing.unique_wallets,
                        interacting_wallets: existing.interacting_wallets,
                        is_new_contract: false,
                        day_timestamp,
                    });
                    
                    usage.total_calls += 1;
                    usage.last_interaction_block = block.number;
                    
                    // Check if this wallet has interacted before
                    if !usage.interacting_wallets.contains(&from_addr) {
                        // Limit the number of wallets we store
                        if usage.interacting_wallets.len() < MAX_WALLETS_PER_CONTRACT {
                            usage.interacting_wallets.push(from_addr);
                        }
                        usage.unique_wallets += 1;
                    }
                    
                    // Check if contract is considered "new" (within NEW_CONTRACT_WINDOW blocks)
                    block.number - existing.first_interaction_block < NEW_CONTRACT_WINDOW
                },
                None => {
                    // New contract not in store
                    let usage = contract_map.entry(contract_addr.clone()).or_insert(ContractUsage {
                        address: contract_addr.clone(),
                        first_interaction_block: block.number,
                        last_interaction_block: block.number,
                        total_calls: 1,
                        unique_wallets: 1,
                        interacting_wallets: vec![from_addr],
                        is_new_contract: true,
                        day_timestamp,
                    });
                    true
                }
            };
            
            // Update is_new_contract flag
            if let Some(usage) = contract_map.get_mut(&contract_addr) {
                usage.is_new_contract = is_new_contract;
            }
        }
    }

    Ok(ContractUsages {
        contracts: contract_map.into_values().collect(),
    })
}
