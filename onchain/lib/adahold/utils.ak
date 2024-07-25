use adahold/types.{
  BurnAction, CollateralData, CollateralScriptData, FinAction, InitAction,
  MintAction, TreasuryData, TreasuryScriptData, WrappedRedeemer,
}
use aiken/builtin as aBuiltin
use aiken/bytearray as aBytes
use aiken/cbor as aCBOR
use aiken/list as aList
use aiken/transaction.{Input, Output, OutputReference}
use aiken/transaction/credential.{Address, PaymentCredential}

pub fn resolve_input(
  input_list: List<Input>,
  out_ref: OutputReference,
) -> Output {
  let Input { output_reference, output } = input_list |> aBuiltin.head_list()

  if output_reference == out_ref {
    output
  } else {
    let tail_input_list = input_list |> aBuiltin.tail_list()

    resolve_input(tail_input_list, out_ref)
  }
}

pub fn get_script_input_list(
  tx_input_list: List<Input>,
  treasury_credential: PaymentCredential,
) -> List<Input> {
  aList.filter(
    tx_input_list,
    fn(input) {
      let Input {
        output: Output { address: Address { payment_credential, .. }, .. },
        ..
      } = input
      payment_credential == treasury_credential
    },
  )
}

pub fn get_cbor_datum() -> (String, String) {
  let token_metadata =
    [
      Pair(aBuiltin.b_data("name"), aBuiltin.b_data("AdaHold")),
      Pair(aBuiltin.b_data("description"),
      aBuiltin.b_data("Algorithmic Price-Can-Only-Go-Up Token")),
      Pair(aBuiltin.b_data("ticker"), aBuiltin.b_data("HOLD")),
      Pair(aBuiltin.b_data("image"),
      aBuiltin.b_data("ar://KYDrF-xorXpMk6O4bE-LyNGjJvXs_7ujamq68U9N9OQ")),
      Pair(aBuiltin.b_data("url"), aBuiltin.b_data("https://adahold.com/")),
      Pair(aBuiltin.b_data("decimals"), aBuiltin.i_data(6)),
    ]

  let treasury_datum =
    TreasuryData {
      token_metadata,
      version: 2,
      script_data: TreasuryScriptData {
        quantity: 100_000_000,
        total_quantity: 100_000_000,
        total_value_locked: 100_000_000,
      },
    }

  let collateral_datum =
    CollateralData {
      token_metadata,
      version: 2,
      script_data: CollateralScriptData { quantity: 100_000_000 },
    }

  (
    treasury_datum |> aCBOR.serialise |> aBytes.to_hex,
    collateral_datum |> aCBOR.serialise |> aBytes.to_hex,
  )
}

pub fn get_cbor_redeemer() -> (String, String, String, String) {
  (
    MintAction |> aCBOR.serialise |> aBytes.to_hex,
    BurnAction |> aCBOR.serialise |> aBytes.to_hex,
    InitAction |> aCBOR.serialise |> aBytes.to_hex,
    FinAction |> aCBOR.serialise |> aBytes.to_hex,
  )
}

pub fn get_cbor_wrapped_redeemer() -> String {
  WrappedRedeemer(Void) |> aCBOR.serialise |> aBytes.to_hex
}
