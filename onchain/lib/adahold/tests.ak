use adahold/types.{
  CollateralData, CollateralScriptData, TreasuryData, TreasuryScriptData,
}
use aiken/builtin as aBuiltin
use aiken/bytearray as aBytes
use aiken/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
  TransactionId,
} as aTX
use aiken/transaction/certificate.{
  CredentialDelegation, CredentialDeregistration, CredentialRegistration,
}
use aiken/transaction/credential.{Address, Inline, ScriptCredential}
use aiken/transaction/value as aVal

pub fn get_param_utxo_ref() {
  OutputReference {
    transaction_id: TransactionId(
      #"9a5897497452f6807c202637281ac03ed03a0ca5389b3990462b4cda03ac9a8b",
    ),
    output_index: 1,
  }
}

pub fn get_test_script_hash() {
  #"00000000000000000000000000000000000000000000000000000000"
}

pub fn get_init_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [
          Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1),
          Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 100),
        ]),
      ],
    )
      |> aVal.to_minted_value

  let input_value =
    minted_value
      |> aVal.from_minted_value
      |> aVal.add(aVal.ada_policy_id, aVal.ada_asset_name, 40)

  let inputs =
    [
      Input {
        output_reference: get_param_utxo_ref(),
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: input_value,
          datum: NoDatum,
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000001",
          ),
          output_index: 199,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: input_value,
          datum: NoDatum,
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000002",
          ),
          output_index: 199,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(
              #"00000000000000000000000000000000000000000000000000000002",
            ),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000002",
                ),
              ),
            ),
          },
          value: input_value,
          datum: NoDatum,
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: input_value
          |> aVal.add(
              get_test_script_hash(),
              aBytes.concat(#"001bc280", get_test_script_hash()),
              -100,
            ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 100,
              total_quantity: 100,
              total_value_locked: 40,
            },
          },
        ),
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
  }
}

pub fn get_mint_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [
          Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
          1),
          Pair(#"001bc28000000000000000000000000000000000000000000000000000000001",
          100),
        ]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 200)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 200,
                total_quantity: 200,
                total_value_locked: 200,
              },
            },
          ),
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 250)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
          ],
        ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 200,
              total_quantity: 300,
              total_value_locked: 375,
            },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 125)]),
            Pair(get_test_script_hash(),
            [
              Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
              1),
            ]),
          ],
        ),
        datum: InlineDatum(
          CollateralData {
            token_metadata: [],
            version: 2,
            script_data: CollateralScriptData { quantity: 100 },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 100)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 100)]),
          ],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}

pub fn get_mint_more_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [
          Pair(#"001bc28000000000000000000000000000000000000000000000000000000001",
          100),
        ]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 200)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 200,
                total_quantity: 200,
                total_value_locked: 200,
              },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 100)]),
              Pair(get_test_script_hash(),
              [
                Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
                1),
              ]),
            ],
          ),
          datum: InlineDatum(
            CollateralData {
              token_metadata: [],
              version: 2,
              script_data: CollateralScriptData { quantity: 100 },
            },
          ),
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 250)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
          ],
        ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 200,
              total_quantity: 300,
              total_value_locked: 375,
            },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 225)]),
            Pair(get_test_script_hash(),
            [
              Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
              1),
            ]),
          ],
        ),
        datum: InlineDatum(
          CollateralData {
            token_metadata: [],
            version: 2,
            script_data: CollateralScriptData { quantity: 200 },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 100)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 100)]),
          ],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}

pub fn get_mint_0fee_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 100)]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 200)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 200,
                total_quantity: 200,
                total_value_locked: 200,
              },
            },
          ),
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 375)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
          ],
        ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 300,
              total_quantity: 300,
              total_value_locked: 375,
            },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 100)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 100)]),
          ],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}

pub fn get_burn_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [
          Pair(#"001bc28000000000000000000000000000000000000000000000000000000001",
          -66),
        ]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 200)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 200,
                total_quantity: 300,
                total_value_locked: 300,
              },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 1,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 100)]),
              Pair(get_test_script_hash(),
              [
                Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
                1),
              ]),
            ],
          ),
          datum: InlineDatum(
            CollateralData {
              token_metadata: [],
              version: 2,
              script_data: CollateralScriptData { quantity: 100 },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 2,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 1)]),
              Pair(get_test_script_hash(),
              [
                Pair(#"001bc28000000000000000000000000000000000000000000000000000000001",
                100),
              ]),
            ],
          ),
          datum: NoDatum,
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 242)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
          ],
        ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 200,
              total_quantity: 234,
              total_value_locked: 276,
            },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 34)]),
            Pair(get_test_script_hash(),
            [
              Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
              1),
            ]),
          ],
        ),
        datum: InlineDatum(
          CollateralData {
            token_metadata: [],
            version: 2,
            script_data: CollateralScriptData { quantity: 34 },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 74)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}

pub fn get_burn_all_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [
          Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
          -1),
          Pair(#"001bc28000000000000000000000000000000000000000000000000000000001",
          -100),
        ]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 200)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 200,
                total_quantity: 300,
                total_value_locked: 300,
              },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 1,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 100)]),
              Pair(get_test_script_hash(),
              [
                Pair(#"000643b000000000000000000000000000000000000000000000000000000001",
                1),
              ]),
            ],
          ),
          datum: InlineDatum(
            CollateralData {
              token_metadata: [],
              version: 2,
              script_data: CollateralScriptData { quantity: 100 },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 2,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 1)]),
              Pair(get_test_script_hash(),
              [
                Pair(#"001bc28000000000000000000000000000000000000000000000000000000001",
                100),
              ]),
            ],
          ),
          datum: NoDatum,
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 237)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
          ],
        ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 200,
              total_quantity: 200,
              total_value_locked: 237,
            },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 97)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}

pub fn get_burn_0fee_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), -100)]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 300)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [
                Pair(aBuiltin.b_data("name"), aBuiltin.b_data("AdaHold")),
              ],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 300,
                total_quantity: 300,
                total_value_locked: 300,
              },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 1,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 1)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 100)]),
            ],
          ),
          datum: NoDatum,
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(get_test_script_hash()),
          stake_credential: Some(
            Inline(ScriptCredential(get_test_script_hash())),
          ),
        },
        value: aVal.from_asset_list(
          [
            Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 234)]),
            Pair(get_test_script_hash(),
            [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
          ],
        ),
        datum: InlineDatum(
          TreasuryData {
            token_metadata: [
              Pair(aBuiltin.b_data("name"), aBuiltin.b_data("AdaHold")),
            ],
            version: 2,
            script_data: TreasuryScriptData {
              quantity: 200,
              total_quantity: 200,
              total_value_locked: 234,
            },
          },
        ),
        reference_script: None,
      },
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 101)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialRegistration(Inline(ScriptCredential(get_test_script_hash()))),
      CredentialDelegation {
        delegator: Inline(ScriptCredential(get_test_script_hash())),
        delegatee: #"",
      },
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}

pub fn get_fin_tx() {
  let minted_value =
    aVal.from_asset_list(
      [
        Pair(get_test_script_hash(),
        [
          Pair(aBytes.concat(#"000643b0", get_test_script_hash()), -1),
          Pair(aBytes.concat(#"001bc280", get_test_script_hash()), -300),
        ]),
      ],
    )
      |> aVal.to_minted_value

  let inputs =
    [
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 0,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(get_test_script_hash()),
            stake_credential: Some(
              Inline(ScriptCredential(get_test_script_hash())),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 300)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"000643b0", get_test_script_hash()), 1)]),
            ],
          ),
          datum: InlineDatum(
            TreasuryData {
              token_metadata: [],
              version: 2,
              script_data: TreasuryScriptData {
                quantity: 300,
                total_quantity: 300,
                total_value_locked: 300,
              },
            },
          ),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference {
          transaction_id: TransactionId(
            #"0000000000000000000000000000000000000000000000000000000000000000",
          ),
          output_index: 1,
        },
        output: Output {
          address: Address {
            payment_credential: ScriptCredential(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            stake_credential: Some(
              Inline(
                ScriptCredential(
                  #"00000000000000000000000000000000000000000000000000000001",
                ),
              ),
            ),
          },
          value: aVal.from_asset_list(
            [
              Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 1)]),
              Pair(get_test_script_hash(),
              [Pair(aBytes.concat(#"001bc280", get_test_script_hash()), 300)]),
            ],
          ),
          datum: NoDatum,
          reference_script: None,
        },
      },
    ]

  let outputs =
    [
      Output {
        address: Address {
          payment_credential: ScriptCredential(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          stake_credential: Some(
            Inline(
              ScriptCredential(
                #"00000000000000000000000000000000000000000000000000000001",
              ),
            ),
          ),
        },
        value: aVal.from_asset_list(
          [Pair(aVal.ada_policy_id, [Pair(aVal.ada_asset_name, 301)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  Transaction {
    ..aTX.placeholder(),
    inputs: inputs,
    mint: minted_value,
    outputs: outputs,
    certificates: [
      CredentialDeregistration(Inline(ScriptCredential(get_test_script_hash()))),
    ],
    withdrawals: [Pair(Inline(ScriptCredential(get_test_script_hash())), 50)],
  }
}
