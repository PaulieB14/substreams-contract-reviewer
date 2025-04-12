use substreams_ethereum::pb::eth::v2::Block;
use std::collections::HashMap;

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
}

#[derive(Clone, PartialEq, prost::Message)]
pub struct ContractUsages {
    #[prost(message, repeated, tag = "1")]
    pub contracts: Vec<ContractUsage>,
}

#[substreams::handlers::map]
fn map_contract_usage(block: Block) -> Result<ContractUsages, substreams::errors::Error> {
    let mut contract_map: HashMap<String, ContractUsage> = HashMap::new();

    for trx in block.transactions() {
        // Only process transactions that have a 'to' address (contract calls)
        if !trx.to.is_empty() {
            let contract_addr = hex::encode(&trx.to);
            let from_addr = hex::encode(&trx.from);

            let usage = contract_map.entry(contract_addr.clone()).or_insert(ContractUsage {
                address: contract_addr.clone(),
                first_interaction_block: block.number,
                last_interaction_block: block.number,
                total_calls: 0,
                unique_wallets: 0,
                interacting_wallets: vec![],
            });

            usage.total_calls += 1;
            usage.last_interaction_block = block.number;

            if !usage.interacting_wallets.contains(&from_addr) {
                usage.interacting_wallets.push(from_addr);
                usage.unique_wallets += 1;
            }
        }
    }

    Ok(ContractUsages {
        contracts: contract_map.into_values().collect(),
    })
}
