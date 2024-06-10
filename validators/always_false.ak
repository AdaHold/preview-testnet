use adahold/utils as hUtils
use aiken/string as aString

validator {
  fn spend(_datum: Data, _redeemer: Data, _ctx: Data) -> Bool {
    False
  }
}

test always_false_test() fail {
  let (treasury, collateral) = hUtils.get_cbor_datum()
  let (mint, burn, init, fin) = hUtils.get_cbor_redeemer()
  let wrapped = hUtils.get_cbor_wrapped_redeemer()

  trace aString.concat(@"TreasuryData: ", treasury)
  trace aString.concat(@"CollateralData: ", collateral)

  trace aString.concat(@"MintAction: ", mint)
  trace aString.concat(@"BurnAction: ", burn)
  trace aString.concat(@"InitAction: ", init)
  trace aString.concat(@"FinAction: ", fin)

  trace aString.concat(@"Wrapped: ", wrapped)

  spend("", "", "")
}
