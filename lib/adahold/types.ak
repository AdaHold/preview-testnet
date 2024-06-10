pub type Lovelace =
  Int

pub type HoldQty =
  Int

pub type ActionRedeemer {
  MintAction
  BurnAction
  InitAction
  FinAction
}

pub type TreasuryScriptData {
  quantity: HoldQty,
  total_quantity: HoldQty,
  total_value_locked: Lovelace,
}

pub type CollateralScriptData {
  quantity: HoldQty,
}

pub type TreasuryData {
  token_metadata: Pairs<Data, Data>,
  version: Int,
  script_data: TreasuryScriptData,
}

pub type CollateralData {
  token_metadata: Pairs<Data, Data>,
  version: Int,
  script_data: CollateralScriptData,
}

pub type WrappedRedeemer<a> {
  UnusedWrappedRedeemer
  WrappedRedeemer(a)
}
