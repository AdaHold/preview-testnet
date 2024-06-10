use adahold/tests as hTests
use adahold/types.{
  ActionRedeemer, BurnAction, CollateralData, CollateralScriptData, FinAction,
  InitAction, MintAction, TreasuryData, TreasuryScriptData,
}
use adahold/utils as hUtils
use aiken/builtin as aBuiltin
use aiken/bytearray as aBytes
use aiken/dict as aDict
use aiken/list as aList
use aiken/transaction.{
  InlineDatum, Input, Mint, Output, OutputReference, Publish, ScriptContext,
  Spend, Transaction, WithdrawFrom,
} as aTX
use aiken/transaction/certificate.{
  CredentialDelegation, CredentialDeregistration, CredentialRegistration,
}
use aiken/transaction/credential.{
  Address, Inline, ScriptCredential, VerificationKeyCredential,
}
use aiken/transaction/value as aVal

validator(param_utxo_ref: OutputReference) {
  /// stake, withdrawal and token policy multivalidator
  fn multi(redeemer: ActionRedeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext {
      transaction: Transaction { mint: tx_mint_value, .. },
      purpose,
    } = ctx

    when purpose is {
      Mint(_) -> {
        let ScriptContext {
          transaction: Transaction {
            inputs: tx_input_list,
            outputs: tx_output_list,
            certificates: tx_cert_list,
            withdrawals: tx_withdrawals,
            ..
          },
          ..
        } = ctx

        // (100)
        let nft_label = #"000643b0"

        // (333)
        let pubkey_label = #"0014df10"

        // (444)
        let script_label = #"001bc280"

        expect [_, Pair(minting_policy, mint_dict)] =
          tx_mint_value |> aVal.minted_to_dict |> aDict.to_pairs

        let treasury_nft_name = aBytes.concat(nft_label, minting_policy)

        let mint_token_list = mint_dict |> aDict.to_pairs

        let treasury_credential = ScriptCredential(minting_policy)

        when redeemer is {
          MintAction -> {
            let script_input_list =
              hUtils.get_script_input_list(tx_input_list, treasury_credential)

            expect [treasury_out, collateral_out, ..] = tx_output_list

            let Output {
              address: treasury_out_addr,
              value: treasury_out_value,
              datum: treasury_out_datum,
              ..
            } = treasury_out

            // TODO The withdrawal code needs to be optimized, coz in fact we don't need to withdraw rewards in every transaction.
            expect [Pair(withdrawal_stake_cred, withdrawal_amount)] =
              tx_withdrawals

            expect Inline(inline_withdrawal_stake_cred) = withdrawal_stake_cred

            expect [
              Pair(_, treasury_out_ada_dict),
              Pair(treasury_out_token_policy, treasury_out_token_dict),
            ] = treasury_out_value |> aVal.to_dict |> aDict.to_pairs

            expect [Pair(_, treasury_out_tvl)] =
              treasury_out_ada_dict |> aDict.to_pairs

            expect [Pair(treasury_out_nft_name, 1)] =
              treasury_out_token_dict |> aDict.to_pairs

            expect InlineDatum(treasury_out_inline_datum) = treasury_out_datum

            expect treasury_out_data: TreasuryData = treasury_out_inline_datum

            let TreasuryData {
              token_metadata: treasury_out_data_meta,
              version: treasury_out_data_version,
              script_data: TreasuryScriptData {
                quantity: treasury_out_data_hold,
                total_quantity: treasury_out_data_total_hold,
                total_value_locked: treasury_out_data_total_locked,
              },
            } = treasury_out_data

            let Output {
              address: collateral_out_addr,
              value: collateral_out_value,
              datum: collateral_out_datum,
              ..
            } = collateral_out

            expect [
              CredentialDeregistration { delegator: dereg_stake_cred },
              CredentialRegistration { delegator: reg_stake_cred },
              CredentialDelegation { delegator: deleg_stake_cred, .. },
            ] = tx_cert_list

            let Address {
              payment_credential: collateral_out_addr_paym_cred,
              stake_credential: collateral_out_addr_stake_cred,
            } = collateral_out_addr

            let (treasury_input, mint_hold_qty, collateral_tvl_change) =
              if collateral_out_addr_paym_cred == treasury_credential {
                expect Some(Inline(inline_collateral_out_addr_stake_cred)) =
                  collateral_out_addr_stake_cred

                let (token_label, collateral_out_addr_stake_cred_hash) =
                  when inline_collateral_out_addr_stake_cred is {
                    VerificationKeyCredential(
                      pubkey_collateral_out_addr_stake_cred,
                    ) -> (pubkey_label, pubkey_collateral_out_addr_stake_cred)
                    ScriptCredential(script_collateral_out_addr_stake_cred) ->
                      (script_label, script_collateral_out_addr_stake_cred)
                  }

                let (
                  treasury_input,
                  mint_hold_name,
                  mint_hold_qty,
                  collateral_in_tvl,
                  collateral_in_qty,
                ) =
                  when script_input_list is {
                    [script_input] -> {
                      expect [Pair(_, 1), Pair(mint_hold_name, mint_hold_qty)] =
                        mint_token_list

                      (script_input, mint_hold_name, mint_hold_qty, 0, 0)
                    }
                    _ -> {
                      expect [fst_script_input, snd_script_input] =
                        script_input_list

                      expect [Pair(mint_hold_name, mint_hold_qty)] =
                        mint_token_list

                      let Input {
                        output_reference: OutputReference {
                          output_index: fst_script_input_out_idx,
                          ..
                        },
                        ..
                      } = fst_script_input

                      let (treasury_input, collateral_input) =
                        if fst_script_input_out_idx == 0 {
                          (fst_script_input, snd_script_input)
                        } else {
                          (snd_script_input, fst_script_input)
                        }

                      let Input {
                        output: Output {
                          address: collateral_in_addr,
                          value: collateral_in_value,
                          datum: collateral_in_datum,
                          ..
                        },
                        ..
                      } = collateral_input

                      expect [Pair(_, collateral_in_ada_dict), _] =
                        collateral_in_value |> aVal.to_dict |> aDict.to_pairs

                      expect [Pair(_, collateral_in_tvl)] =
                        collateral_in_ada_dict |> aDict.to_pairs

                      expect InlineDatum(collateral_in_inline_datum) =
                        collateral_in_datum

                      expect collateral_in_data: CollateralData =
                        collateral_in_inline_datum

                      let CollateralData {
                        script_data: CollateralScriptData {
                          quantity: collateral_in_qty,
                        },
                        ..
                      } = collateral_in_data

                      expect collateral_in_addr == collateral_out_addr

                      (
                        treasury_input,
                        mint_hold_name,
                        mint_hold_qty,
                        collateral_in_tvl,
                        collateral_in_qty,
                      )
                    }
                  }

                expect [
                  Pair(_, collateral_out_ada_dict),
                  Pair(collateral_out_token_policy, collateral_out_token_dict),
                ] = collateral_out_value |> aVal.to_dict |> aDict.to_pairs

                expect [Pair(_, collateral_out_tvl)] =
                  collateral_out_ada_dict |> aDict.to_pairs

                expect [Pair(collateral_out_nft_name, 1)] =
                  collateral_out_token_dict |> aDict.to_pairs

                expect InlineDatum(collateral_out_inline_datum) =
                  collateral_out_datum

                expect collateral_out_data: CollateralData =
                  collateral_out_inline_datum

                let CollateralData {
                  token_metadata: collateral_out_data_meta,
                  version: collateral_out_data_version,
                  script_data: CollateralScriptData {
                    quantity: collateral_out_qty,
                  },
                } = collateral_out_data

                expect and {
                    inline_collateral_out_addr_stake_cred != treasury_credential,
                    collateral_out_nft_name == aBytes.concat(
                      nft_label,
                      collateral_out_addr_stake_cred_hash,
                    ),
                    collateral_out_token_policy == minting_policy,
                    mint_hold_name == aBytes.concat(
                      token_label,
                      collateral_out_addr_stake_cred_hash,
                    ),
                    mint_hold_qty == collateral_out_qty - collateral_in_qty,
                    treasury_out_data_meta == collateral_out_data_meta,
                    treasury_out_data_version == collateral_out_data_version,
                  }

                (
                  treasury_input,
                  mint_hold_qty,
                  collateral_out_tvl - collateral_in_tvl,
                )
              } else {
                expect [treasury_input] = script_input_list

                expect [Pair(mint_hold_name, mint_hold_qty)] = mint_token_list

                expect
                  mint_hold_name == aBytes.concat(script_label, minting_policy)

                (treasury_input, mint_hold_qty, 0)
              }

            let Input {
              output: Output {
                address: treasury_in_addr,
                value: treasury_in_value,
                datum: treasury_in_datum,
                ..
              },
              ..
            } = treasury_input

            expect [Pair(_, treasury_in_ada_dict), _] =
              treasury_in_value
                |> aVal.to_dict
                |> aDict.to_pairs

            expect [Pair(_, treasury_in_tvl)] =
              treasury_in_ada_dict |> aDict.to_pairs

            expect InlineDatum(treasury_in_inline_datum) = treasury_in_datum

            expect treasury_in_data: TreasuryData = treasury_in_inline_datum

            let TreasuryData {
              token_metadata: treasury_in_data_meta,
              version: treasury_in_data_version,
              script_data: TreasuryScriptData {
                quantity: treasury_in_data_hold,
                total_quantity: treasury_total_hold,
                total_value_locked: treasury_in_data_total_locked,
              },
            } = treasury_in_data

            let treasury_total_locked =
              treasury_in_data_total_locked + withdrawal_amount

            let treasury_tvl = treasury_in_tvl + withdrawal_amount

            let value_locked =
              mint_hold_qty * treasury_total_locked / treasury_total_hold

            and {
              mint_hold_qty > 0,
              treasury_in_addr == treasury_out_addr,
              treasury_out_token_policy == minting_policy,
              treasury_out_nft_name == treasury_nft_name,
              treasury_out_data_meta == treasury_in_data_meta,
              treasury_out_data_version == treasury_in_data_version,
              treasury_out_data_total_hold == treasury_total_hold + mint_hold_qty,
              treasury_out_data_total_locked == treasury_total_locked + value_locked,
              withdrawal_stake_cred == dereg_stake_cred,
              withdrawal_stake_cred == reg_stake_cred,
              withdrawal_stake_cred == deleg_stake_cred,
              inline_withdrawal_stake_cred == treasury_credential,
              if collateral_out_addr_paym_cred == treasury_credential {
                and {
                  value_locked == collateral_tvl_change,
                  treasury_out_tvl == treasury_tvl,
                  treasury_out_data_hold == treasury_in_data_hold,
                }
              } else {
                and {
                  treasury_out_tvl == treasury_tvl + value_locked,
                  treasury_out_data_hold == treasury_in_data_hold + mint_hold_qty,
                }
              },
            }
          }

          BurnAction -> {
            let script_input_list =
              hUtils.get_script_input_list(tx_input_list, treasury_credential)

            // TODO The withdrawal code needs to be optimized, coz in fact we don't need to withdraw rewards in every transaction.
            expect [Pair(withdrawal_stake_cred, withdrawal_amount)] =
              tx_withdrawals

            expect Inline(inline_withdrawal_stake_cred) = withdrawal_stake_cred

            expect [
              CredentialDeregistration { delegator: dereg_stake_cred },
              CredentialRegistration { delegator: reg_stake_cred },
              CredentialDelegation { delegator: deleg_stake_cred, .. },
            ] = tx_cert_list

            when script_input_list is {
              [treasury_input] -> {
                let Input {
                  output: Output {
                    address: treasury_in_addr,
                    value: treasury_in_value,
                    datum: treasury_in_datum,
                    ..
                  },
                  ..
                } = treasury_input

                expect [treasury_out, ..] = tx_output_list

                let Output {
                  address: treasury_out_addr,
                  value: treasury_out_value,
                  datum: treasury_out_datum,
                  ..
                } = treasury_out

                expect [Pair(_, treasury_in_ada_dict), _] =
                  treasury_in_value
                    |> aVal.to_dict
                    |> aDict.to_pairs

                expect [Pair(_, treasury_in_tvl)] =
                  treasury_in_ada_dict |> aDict.to_pairs

                expect [
                  Pair(_, treasury_out_ada_dict),
                  Pair(treasury_out_token_policy, treasury_out_token_dict),
                ] = treasury_out_value |> aVal.to_dict |> aDict.to_pairs

                expect [Pair(_, treasury_out_tvl)] =
                  treasury_out_ada_dict |> aDict.to_pairs

                expect [Pair(treasury_out_nft_name, 1)] =
                  treasury_out_token_dict |> aDict.to_pairs

                expect InlineDatum(treasury_in_inline_datum) = treasury_in_datum

                expect treasury_in_data: TreasuryData = treasury_in_inline_datum

                let TreasuryData {
                  token_metadata: treasury_in_data_meta,
                  version: treasury_in_data_version,
                  script_data: TreasuryScriptData {
                    quantity: treasury_in_data_hold,
                    total_quantity: treasury_in_data_total_hold,
                    total_value_locked: treasury_in_data_total_locked,
                  },
                } = treasury_in_data

                expect InlineDatum(treasury_out_inline_datum) =
                  treasury_out_datum

                expect treasury_out_data: TreasuryData =
                  treasury_out_inline_datum

                let TreasuryData {
                  token_metadata: treasury_out_data_meta,
                  version: treasury_out_data_version,
                  script_data: TreasuryScriptData {
                    quantity: treasury_out_data_hold,
                    total_quantity: treasury_out_data_total_hold,
                    total_value_locked: treasury_out_data_total_locked,
                  },
                } = treasury_out_data

                expect [Pair(mint_hold_name, mint_hold_qty)] = mint_token_list

                let treasury_total_locked =
                  treasury_in_data_total_locked + withdrawal_amount

                let value_unlocked =
                  -mint_hold_qty * treasury_total_locked / treasury_in_data_total_hold

                and {
                  mint_hold_name == aBytes.concat(script_label, minting_policy),
                  mint_hold_qty < 0,
                  treasury_out_addr == treasury_in_addr,
                  treasury_out_token_policy == minting_policy,
                  treasury_out_nft_name == treasury_nft_name,
                  treasury_out_data_meta == treasury_in_data_meta,
                  treasury_out_data_version == treasury_in_data_version,
                  treasury_out_tvl == treasury_in_tvl + withdrawal_amount - value_unlocked,
                  treasury_out_data_hold == treasury_in_data_hold + mint_hold_qty,
                  treasury_out_data_total_hold == treasury_in_data_total_hold + mint_hold_qty,
                  treasury_out_data_total_locked == treasury_total_locked - value_unlocked,
                  withdrawal_stake_cred == dereg_stake_cred,
                  withdrawal_stake_cred == reg_stake_cred,
                  withdrawal_stake_cred == deleg_stake_cred,
                  inline_withdrawal_stake_cred == treasury_credential,
                }
              }
              _ -> {
                expect [fst_script_input, snd_script_input] = script_input_list

                let Input {
                  output_reference: OutputReference {
                    output_index: fst_script_input_out_idx,
                    ..
                  },
                  ..
                } = fst_script_input

                let (treasury_input, collateral_input) =
                  if fst_script_input_out_idx == 0 {
                    (fst_script_input, snd_script_input)
                  } else {
                    (snd_script_input, fst_script_input)
                  }

                let Input {
                  output: Output {
                    address: treasury_in_addr,
                    value: treasury_in_value,
                    datum: treasury_in_datum,
                    ..
                  },
                  ..
                } = treasury_input

                expect [treasury_out, ..] = tx_output_list

                let Output {
                  address: treasury_out_addr,
                  value: treasury_out_value,
                  datum: treasury_out_datum,
                  ..
                } = treasury_out

                expect [Pair(_, treasury_in_ada_dict), _] =
                  treasury_in_value
                    |> aVal.to_dict
                    |> aDict.to_pairs

                expect [Pair(_, treasury_in_tvl)] =
                  treasury_in_ada_dict |> aDict.to_pairs

                expect [
                  Pair(_, treasury_out_ada_dict),
                  Pair(treasury_out_token_policy, treasury_out_token_dict),
                ] = treasury_out_value |> aVal.to_dict |> aDict.to_pairs

                expect [Pair(_, treasury_out_tvl)] =
                  treasury_out_ada_dict |> aDict.to_pairs

                expect [Pair(treasury_out_nft_name, 1)] =
                  treasury_out_token_dict |> aDict.to_pairs

                expect InlineDatum(treasury_in_inline_datum) = treasury_in_datum

                expect treasury_in_data: TreasuryData = treasury_in_inline_datum

                let TreasuryData {
                  token_metadata: treasury_in_data_meta,
                  version: treasury_in_data_version,
                  script_data: TreasuryScriptData {
                    quantity: treasury_in_data_hold,
                    total_quantity: treasury_in_data_total_hold,
                    total_value_locked: treasury_in_data_total_locked,
                  },
                } = treasury_in_data

                let Input {
                  output: Output {
                    address: collateral_in_addr,
                    value: collateral_in_value,
                    datum: collateral_in_datum,
                    ..
                  },
                  ..
                } = collateral_input

                let Address {
                  stake_credential: collateral_in_addr_stake_cred,
                  ..
                } = collateral_in_addr

                expect Some(Inline(inline_collateral_in_addr_stake_cred)) =
                  collateral_in_addr_stake_cred

                let (token_label, collateral_in_addr_stake_cred_hash) =
                  when inline_collateral_in_addr_stake_cred is {
                    VerificationKeyCredential(
                      pubkey_collateral_in_addr_stake_cred,
                    ) -> (pubkey_label, pubkey_collateral_in_addr_stake_cred)
                    ScriptCredential(script_collateral_in_addr_stake_cred) ->
                      (script_label, script_collateral_in_addr_stake_cred)
                  }

                expect [Pair(_, collateral_in_ada_dict), _] =
                  collateral_in_value |> aVal.to_dict |> aDict.to_pairs

                expect [Pair(_, collateral_in_tvl)] =
                  collateral_in_ada_dict |> aDict.to_pairs

                expect InlineDatum(collateral_in_inline_datum) =
                  collateral_in_datum

                expect collateral_in_data: CollateralData =
                  collateral_in_inline_datum

                let CollateralData {
                  script_data: CollateralScriptData {
                    quantity: collateral_in_qty,
                  },
                  ..
                } = collateral_in_data

                expect InlineDatum(treasury_out_inline_datum) =
                  treasury_out_datum

                expect treasury_out_data: TreasuryData =
                  treasury_out_inline_datum

                let TreasuryData {
                  token_metadata: treasury_out_data_meta,
                  version: treasury_out_data_version,
                  script_data: TreasuryScriptData {
                    quantity: treasury_out_data_hold,
                    total_quantity: treasury_out_data_total_hold,
                    total_value_locked: treasury_out_data_total_locked,
                  },
                } = treasury_out_data

                let collateral_nft_name =
                  aBytes.concat(nft_label, collateral_in_addr_stake_cred_hash)

                let (mint_hold_name, mint_hold_qty, collateral_value_left) =
                  when mint_token_list is {
                    [Pair(mint_hold_name, mint_hold_qty)] -> {
                      let collateral_qty_left =
                        collateral_in_qty + mint_hold_qty

                      // TODO
                      // let collateral_value_left =
                      //   collateral_qty_left * collateral_in_tvl / collateral_in_qty
                      let collateral_value_left =
                        collateral_qty_left * treasury_in_data_total_locked / treasury_in_data_total_hold

                      expect [_, collateral_out, ..] = tx_output_list

                      let Output {
                        address: collateral_out_addr,
                        value: collateral_out_value,
                        datum: collateral_out_datum,
                        ..
                      } = collateral_out

                      expect [
                        Pair(_, collateral_out_ada_dict),
                        Pair(collateral_out_token_policy,
                        collateral_out_token_dict),
                      ] = collateral_out_value |> aVal.to_dict |> aDict.to_pairs

                      expect [Pair(_, collateral_out_tvl)] =
                        collateral_out_ada_dict |> aDict.to_pairs

                      expect [Pair(collateral_out_nft_name, 1)] =
                        collateral_out_token_dict |> aDict.to_pairs

                      expect InlineDatum(collateral_out_inline_datum) =
                        collateral_out_datum

                      expect collateral_out_data: CollateralData =
                        collateral_out_inline_datum

                      let CollateralData {
                        script_data: CollateralScriptData {
                          quantity: collateral_out_qty,
                        },
                        ..
                      } = collateral_out_data

                      expect and {
                          collateral_out_addr == collateral_in_addr,
                          collateral_out_token_policy == minting_policy,
                          collateral_out_nft_name == collateral_nft_name,
                          collateral_qty_left > 0,
                          collateral_value_left == collateral_out_tvl,
                          collateral_qty_left == collateral_out_qty,
                        }

                      (mint_hold_name, mint_hold_qty, collateral_value_left)
                    }
                    _ -> {
                      expect [
                        Pair(mint_nft_name, -1),
                        Pair(mint_hold_name, mint_hold_qty),
                      ] = mint_token_list

                      expect and {
                          mint_nft_name == collateral_nft_name,
                          collateral_in_qty == -mint_hold_qty,
                        }

                      (mint_hold_name, mint_hold_qty, 0)
                    }
                  }

                let treasury_total_locked =
                  treasury_in_data_total_locked + withdrawal_amount

                let value_unlocked =
                  -mint_hold_qty * treasury_total_locked * 97 / (
                    treasury_in_data_total_hold * 100
                  )

                let collateral_value_unlocked =
                  collateral_in_tvl - collateral_value_left

                let treasury_value_unlocked =
                  value_unlocked - collateral_value_unlocked

                and {
                  mint_hold_name == aBytes.concat(
                    token_label,
                    collateral_in_addr_stake_cred_hash,
                  ),
                  mint_hold_qty < 0,
                  treasury_out_addr == treasury_in_addr,
                  treasury_out_token_policy == minting_policy,
                  treasury_out_nft_name == treasury_nft_name,
                  treasury_out_data_meta == treasury_in_data_meta,
                  treasury_out_data_version == treasury_in_data_version,
                  treasury_out_tvl == treasury_in_tvl + withdrawal_amount - treasury_value_unlocked,
                  treasury_out_data_hold == treasury_in_data_hold,
                  treasury_out_data_total_hold == treasury_in_data_total_hold + mint_hold_qty,
                  treasury_out_data_total_locked == treasury_total_locked - value_unlocked,
                  withdrawal_stake_cred == dereg_stake_cred,
                  withdrawal_stake_cred == reg_stake_cred,
                  withdrawal_stake_cred == deleg_stake_cred,
                  inline_withdrawal_stake_cred == treasury_credential,
                }
              }
            }
          }

          InitAction -> {
            let Output {
              address: treasury_out_addr,
              value: treasury_out_value,
              datum: treasury_out_datum,
              ..
            } = tx_output_list |> aBuiltin.head_list

            expect [Pair(_, 1), Pair(mint_hold_name, mint_hold_qty)] =
              mint_token_list

            expect [
              CredentialRegistration { delegator: reg_stake_cred },
              CredentialDelegation { delegator: deleg_stake_cred, .. },
            ] = tx_cert_list

            expect Address {
              payment_credential: treasury_out_addr_paym_cred,
              stake_credential: Some(treasury_out_addr_stake_cred),
            } = treasury_out_addr

            expect Inline(inline_treasury_out_addr_stake_cred) =
              treasury_out_addr_stake_cred

            expect [
              Pair(_, treasury_out_ada_dict),
              Pair(treasury_out_nft_policy, treasury_out_token_dict),
            ] = treasury_out_value |> aVal.to_dict |> aDict.to_pairs

            expect [Pair(_, treasury_out_locked)] =
              treasury_out_ada_dict |> aDict.to_pairs

            expect [Pair(treasury_out_nft_name, 1)] =
              treasury_out_token_dict |> aDict.to_pairs

            expect InlineDatum(treasury_out_inline_datum) = treasury_out_datum

            expect treasury_out_data: TreasuryData = treasury_out_inline_datum

            let TreasuryData {
              script_data: TreasuryScriptData {
                quantity: treasury_out_data_hold,
                total_quantity: treasury_out_data_total_hold,
                total_value_locked: treasury_out_data_total_locked,
              },
              ..
            } = treasury_out_data

            and {
              aList.any(
                tx_input_list,
                fn(input) { input.output_reference == param_utxo_ref },
              ),
              treasury_out_addr_paym_cred == treasury_credential,
              inline_treasury_out_addr_stake_cred == treasury_credential,
              reg_stake_cred == treasury_out_addr_stake_cred,
              deleg_stake_cred == treasury_out_addr_stake_cred,
              treasury_out_nft_policy == minting_policy,
              treasury_out_nft_name == treasury_nft_name,
              treasury_out_locked == treasury_out_data_total_locked,
              mint_hold_qty == treasury_out_data_hold,
              mint_hold_qty == treasury_out_data_total_hold,
              mint_hold_name == aBytes.concat(script_label, minting_policy),
            }
          }

          FinAction -> {
            let script_input_list =
              hUtils.get_script_input_list(tx_input_list, treasury_credential)

            // TODO The withdrawal code needs to be optimized, coz in fact we don't need to withdraw rewards in every transaction.
            expect [Pair(withdrawal_stake_cred, _)] = tx_withdrawals

            expect Inline(inline_withdrawal_stake_cred) = withdrawal_stake_cred

            expect [CredentialDeregistration { delegator: dereg_stake_cred }] =
              tx_cert_list

            expect [treasury_input] = script_input_list
            let Input { output: Output { datum: treasury_in_datum, .. }, .. } =
              treasury_input

            expect InlineDatum(treasury_in_inline_datum) = treasury_in_datum

            expect treasury_in_data: TreasuryData = treasury_in_inline_datum

            let TreasuryData {
              script_data: TreasuryScriptData {
                quantity: treasury_in_data_hold,
                total_quantity: treasury_in_data_total_hold,
                ..
              },
              ..
            } = treasury_in_data

            expect [
              Pair(mint_nft_name, -1),
              Pair(mint_hold_name, mint_hold_qty),
            ] = mint_token_list

            and {
              mint_nft_name == treasury_nft_name,
              mint_hold_name == aBytes.concat(script_label, minting_policy),
              treasury_in_data_hold == -mint_hold_qty,
              treasury_in_data_hold == treasury_in_data_total_hold,
              withdrawal_stake_cred == dereg_stake_cred,
              inline_withdrawal_stake_cred == treasury_credential,
            }
          }
        }
      }
      _ -> {
        expect [_, Pair(minting_policy, _)] =
          tx_mint_value |> aVal.minted_to_dict |> aDict.to_pairs

        expect Inline(ScriptCredential(stake_hash)) =
          when purpose is {
            WithdrawFrom(delegator) -> delegator
            _ -> {
              expect Publish(cert) = purpose
              when cert is {
                // TODO CredentialRegistration is for testing purpose only. We must remove the next line in production, since stake key registration doesn't need stake key witness
                CredentialRegistration { delegator } -> delegator
                CredentialDeregistration { delegator } -> delegator
                _ -> {
                  expect CredentialDelegation { delegator, .. } = cert

                  delegator
                }
              }
            }
          }

        minting_policy == stake_hash
      }
    }
  }

  /// remember when building a transaction, redeemer for spend multivalidator needs to be wrapped in an extra key 1 (tag 122) constructor
  fn spend(_datum: Data, _redeemer: Data, ctx: ScriptContext) -> Bool {
    let ScriptContext {
      transaction: Transaction {
        mint: tx_mint_value,
        inputs: tx_input_list,
        ..
      },
      purpose,
    } = ctx

    // Note that because of historical reasons, MintedValue always holds a null quantity of Ada
    expect [_, Pair(minting_policy, _)] =
      tx_mint_value |> aVal.minted_to_dict |> aDict.to_pairs

    expect Spend(own_ref) = purpose

    let Output { address: own_addr, .. } =
      hUtils.resolve_input(tx_input_list, own_ref)

    expect Address {
      payment_credential: ScriptCredential(own_addr_paym_hash),
      ..
    } = own_addr

    own_addr_paym_hash == minting_policy
  }
}

fn test_tx(transaction: Transaction, redeemer: ActionRedeemer) -> Bool {
  let test_hash = hTests.get_test_script_hash()

  let utxo_ref = hTests.get_param_utxo_ref()

  aList.all(
    transaction.certificates,
    fn(certificate) {
      when certificate is {
        CredentialDeregistration{delegator: Inline(ScriptCredential(
          addr_script_hash,
        ))} as cert ->
          if addr_script_hash == test_hash {
            multi(
              utxo_ref,
              redeemer,
              ScriptContext { purpose: Publish(cert), transaction },
            )
          } else {
            True
          }
        CredentialRegistration{delegator: Inline(ScriptCredential(
          addr_script_hash,
        ))} as cert ->
          if addr_script_hash == test_hash {
            multi(
              utxo_ref,
              redeemer,
              ScriptContext { purpose: Publish(cert), transaction },
            )
          } else {
            True
          }
        CredentialDelegation {
          delegator: Inline(ScriptCredential(addr_script_hash)),
          ..
        } as cert ->
          if addr_script_hash == test_hash {
            multi(
              utxo_ref,
              redeemer,
              ScriptContext { purpose: Publish(cert), transaction },
            )
          } else {
            True
          }
        _ -> True
      }
    },
  ) && aList.all(
    transaction.inputs,
    fn(input) {
      when input.output.address.payment_credential is {
        ScriptCredential(addr_script_hash) ->
          if addr_script_hash == test_hash {
            spend(
              utxo_ref,
              "",
              redeemer,
              ScriptContext {
                purpose: Spend(input.output_reference),
                transaction,
              },
            )
          } else {
            True
          }
        _ -> True
      }
    },
  ) && aList.all(
    transaction.mint |> aVal.from_minted_value |> aVal.policies,
    fn(policy) {
      if policy == test_hash {
        multi(
          utxo_ref,
          redeemer,
          ScriptContext { purpose: Mint(policy), transaction },
        )
      } else {
        True
      }
    },
  ) && aList.all(
    transaction.withdrawals,
    fn(withdrawal) {
      when withdrawal is {
        Pair(Inline(ScriptCredential(addr_script_hash)) as stake_cred, _) ->
          if addr_script_hash == test_hash {
            multi(
              utxo_ref,
              redeemer,
              ScriptContext { purpose: WithdrawFrom(stake_cred), transaction },
            )
          } else {
            True
          }
        _ -> True
      }
    },
  )
}

test init_test() {
  hTests.get_init_tx() |> test_tx(InitAction)
}

test mint_test() {
  hTests.get_mint_tx() |> test_tx(MintAction)
}

test mint_more_test() {
  hTests.get_mint_more_tx() |> test_tx(MintAction)
}

test mint_0fee_test() {
  hTests.get_mint_0fee_tx() |> test_tx(MintAction)
}

test burn_test() {
  hTests.get_burn_tx() |> test_tx(BurnAction)
}

test burn_all_test() {
  hTests.get_burn_all_tx() |> test_tx(BurnAction)
}

test burn_0fee_test() {
  hTests.get_burn_0fee_tx() |> test_tx(BurnAction)
}

test fin_test() {
  hTests.get_fin_tx() |> test_tx(FinAction)
}
