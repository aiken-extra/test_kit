//// @hidden
//// ```
//// Aiken v1.1.9:
//// │ PASS [mem: 301.83 K, cpu:  98.11 M] testing_add_tx_input
//// │ PASS [mem:   5.25 K, cpu:   3.79 M] testing_new_tx_input
//// │ PASS [mem: 233.86 K, cpu:  72.24 M] testing_with_asset_of_tx_input
//// │ PASS [mem:  16.28 K, cpu:   7.91 M] testing_set_datum_of_tx_input
//// │ PASS [mem:  18.04 K, cpu:   8.18 M] testing_attach_ref_script_to_tx_input
//// │ PASS [mem: 306.48 K, cpu:  99.68 M] testing_add_tx_ref_input
//// │ PASS [mem: 275.27 K, cpu:  87.32 M] testing_add_tx_output
//// │ PASS [mem:   3.96 K, cpu:   2.85 M] testing_new_tx_output
//// │ PASS [mem: 213.18 K, cpu:  64.02 M] testing_add_asset_to_tx_output
//// │ PASS [mem:  10.87 K, cpu:   5.47 M] testing_set_datum_of_tx_output
//// │ PASS [mem:  12.63 K, cpu:   5.74 M] testing_attach_ref_script_to_tx_output
//// │ PASS [mem:  13.19 K, cpu:   7.68 M] testing_set_fee
//// │ PASS [mem:  391.5 K, cpu: 117.78 M] testing_add_mint
//// │ PASS [mem:  28.01 K, cpu:  13.52 M] testing_add_certificate
//// │ PASS [mem: 432.37 K, cpu: 191.57 M] testing_add_withdrawal
//// │ PASS [mem:  27.12 K, cpu:  12.28 M] testing_set_validity_range
//// │ PASS [mem:  52.23 K, cpu:  21.21 M] testing_add_signatory
//// │ PASS [mem: 309.48 K, cpu: 125.47 M] testing_add_redeemer
//// │ PASS [mem: 170.95 K, cpu:  59.23 M] testing_add_datum
//// │ PASS [mem:  32.33 K, cpu:  14.23 M] testing_set_id
//// │ PASS [mem: 137.74 K, cpu:  58.35 M] testing_add_vote
//// │ PASS [mem: 116.52 K, cpu:  44.39 M] testing_add_proposal_procedure
//// │ PASS [mem:  40.93 K, cpu:  17.30 M] testing_set_current_treasury_amount
//// │ PASS [mem:  41.80 K, cpu:  17.57 M] testing_set_treasury_donation
//// ```

use aiken/builtin.{b_data}
use aiken/collection/dict.{from_pairs}
use aiken/interval.{after}
use cardano/address.{from_script, from_verification_key}
use cardano/assets.{from_asset, from_asset_list, from_lovelace}
use cardano/certificate.{
  DelegateBoth, RegisterAndDelegateCredential, RetireFromConstitutionalCommittee,
}
use cardano/governance.{
  ConstitutionalCommitteeMember, DelegateRepresentative, GovernanceActionId,
  NicePoll, ProposalProcedure, StakePool,
}
use cardano/transaction.{InlineDatum, NoDatum, OutputReference, Transaction}
use test_kit/tx.{
  add_asset_to_tx_output, add_certificate, add_datum, add_mint,
  add_proposal_procedure, add_redeemer, add_signatory, add_tx_input,
  add_tx_output, add_tx_ref_input, add_vote, add_withdrawal,
  attach_ref_script_to_tx_input, attach_ref_script_to_tx_output, new_tx_input,
  new_tx_output, set_current_treasury_amount, set_datum_of_tx_input,
  set_datum_of_tx_output, set_fee, set_id, set_treasury_donation,
  set_validity_range, with_asset_of_tx_input,
}

const output_reference =
  OutputReference(
    #"0000000000000000000000000000000000000000000000000000000000000064",
    0,
  )

const address =
  from_verification_key(
    #"00000000000000000000000000000000000000000000000000000056",
  )

// ## Test Transaction Input

test testing_add_tx_input() {
  // Arrange:
  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        // TxInput1:
        transaction.Input {
          output_reference: OutputReference {
            transaction_id: #"0000000000000000000000000000000000000000000000000000000000000001",
            output_index: 0,
          },
          output: transaction.Output {
            address: from_verification_key(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            value: from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId1", [Pair("Nft1", 1), Pair("Token1", 3_000)]),
              ],
            ),
            datum: NoDatum,
            reference_script: None,
          },
        },
        // TxInput2:
        transaction.Input {
          output_reference: OutputReference {
            transaction_id: #"0000000000000000000000000000000000000000000000000000000000000002",
            output_index: 1,
          },
          output: transaction.Output {
            address: from_script(
              #"00000000000000000000000000000000000000000000000000000002",
            ),
            value: from_asset_list(
              [
                Pair("", [Pair("", 4_000_000)]),
                Pair("PolicyId2", [Pair("Nft2", 1)]),
              ],
            ),
            datum: InlineDatum(output_reference),
            reference_script: Some(
              #"00000000000000000000000000000000000000000000000000000056",
            ),
          },
        },
      ],
    }

  let txn_new =
    transaction.placeholder
      |> add_tx_input(
          new_tx_input(
            OutputReference {
              transaction_id: #"0000000000000000000000000000000000000000000000000000000000000001",
              output_index: 0,
            },
            from_verification_key(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
          )
            |> with_asset_of_tx_input(from_lovelace(2_000_000))
            |> with_asset_of_tx_input(from_asset("PolicyId1", "Nft1", 1))
            |> with_asset_of_tx_input(from_asset("PolicyId1", "Token1", 3_000)),
        )
      |> add_tx_input(
          new_tx_input(
            OutputReference {
              transaction_id: #"0000000000000000000000000000000000000000000000000000000000000002",
              output_index: 1,
            },
            from_script(
              #"00000000000000000000000000000000000000000000000000000002",
            ),
          )
            |> set_datum_of_tx_input(InlineDatum(output_reference))
            |> attach_ref_script_to_tx_input(
                #"00000000000000000000000000000000000000000000000000000056",
              )
            |> with_asset_of_tx_input(from_lovelace(4_000_000))
            |> with_asset_of_tx_input(from_asset("PolicyId2", "Nft2", 1)),
        )

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

test testing_new_tx_input() {
  // Arrange:
  let tx_in_raw =
    transaction.Input {
      output_reference,
      output: transaction.Output {
        address,
        value: assets.zero,
        datum: NoDatum,
        reference_script: None,
      },
    }

  let tx_in_new = new_tx_input(output_reference, address)

  // Trace:
  //   trace @"tx_in_raw": tx_in_raw
  //   trace @"tx_in_new": tx_in_new
  // Assert:
  (tx_in_raw == tx_in_new)?
}

test testing_with_asset_of_tx_input() {
  // Arrange:
  let tx_in_raw =
    transaction.Input {
      output_reference,
      output: transaction.Output {
        address,
        value: from_asset_list(
          [
            Pair("", [Pair("", 2_000_000)]),
            Pair("PolicyId1", [Pair("Nft1", 1), Pair("Token1", 3_000)]),
            Pair("PolicyId2", [Pair("Nft2", 1)]),
          ],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    }

  let tx_in_new =
    new_tx_input(output_reference, address)
      |> with_asset_of_tx_input(from_lovelace(2_000_000))
      |> with_asset_of_tx_input(from_asset("PolicyId1", "Nft1", 1))
      |> with_asset_of_tx_input(from_asset("PolicyId1", "Token1", 3_000))
      |> with_asset_of_tx_input(from_asset("PolicyId2", "Nft2", 1))

  // Trace:
  //   trace @"tx_in_raw": tx_in_raw
  //   trace @"tx_in_new": tx_in_new
  // Assert:
  (tx_in_raw == tx_in_new)?
}

test testing_set_datum_of_tx_input() {
  // Arrange:
  let datum = InlineDatum(output_reference)

  let tx_in_raw =
    transaction.Input {
      output_reference,
      output: transaction.Output {
        address,
        value: assets.zero,
        datum,
        reference_script: None,
      },
    }

  let tx_in_new =
    new_tx_input(output_reference, address)
      |> set_datum_of_tx_input(datum)

  // Trace:
  //   trace @"tx_in_raw": tx_in_raw
  //   trace @"tx_in_new": tx_in_new
  // Assert:
  (tx_in_raw == tx_in_new)?
}

test testing_attach_ref_script_to_tx_input() {
  // Arrange:
  let ref_script = #"00000000000000000000000000000000000000000000000000000056"

  let tx_in_raw =
    transaction.Input {
      output_reference,
      output: transaction.Output {
        address,
        value: assets.zero,
        datum: NoDatum,
        reference_script: Some(ref_script),
      },
    }

  let tx_in_new =
    new_tx_input(output_reference, address)
      |> attach_ref_script_to_tx_input(ref_script)

  // Trace:
  //   trace @"tx_in_raw": tx_in_raw
  //   trace @"tx_in_new": tx_in_new
  // Assert:
  (tx_in_raw == tx_in_new)?
}

// ## Test Reference Input

test testing_add_tx_ref_input() {
  // Arrange:
  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      reference_inputs: [
        // TxInput1:
        transaction.Input {
          output_reference: OutputReference {
            transaction_id: #"0000000000000000000000000000000000000000000000000000000000000001",
            output_index: 0,
          },
          output: transaction.Output {
            address: from_verification_key(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
            value: from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId1", [Pair("Nft1", 1), Pair("Token1", 3_000)]),
              ],
            ),
            datum: NoDatum,
            reference_script: None,
          },
        },
        // TxInput2:
        transaction.Input {
          output_reference: OutputReference {
            transaction_id: #"0000000000000000000000000000000000000000000000000000000000000002",
            output_index: 1,
          },
          output: transaction.Output {
            address: from_script(
              #"00000000000000000000000000000000000000000000000000000002",
            ),
            value: from_asset_list(
              [
                Pair("", [Pair("", 4_000_000)]),
                Pair("PolicyId2", [Pair("Nft2", 1)]),
              ],
            ),
            datum: InlineDatum(output_reference),
            reference_script: Some(
              #"00000000000000000000000000000000000000000000000000000056",
            ),
          },
        },
      ],
    }

  let txn_new =
    transaction.placeholder
      |> add_tx_ref_input(
          new_tx_input(
            OutputReference {
              transaction_id: #"0000000000000000000000000000000000000000000000000000000000000001",
              output_index: 0,
            },
            from_verification_key(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
          )
            |> with_asset_of_tx_input(from_lovelace(2_000_000))
            |> with_asset_of_tx_input(from_asset("PolicyId1", "Nft1", 1))
            |> with_asset_of_tx_input(from_asset("PolicyId1", "Token1", 3_000)),
        )
      |> add_tx_ref_input(
          new_tx_input(
            OutputReference {
              transaction_id: #"0000000000000000000000000000000000000000000000000000000000000002",
              output_index: 1,
            },
            from_script(
              #"00000000000000000000000000000000000000000000000000000002",
            ),
          )
            |> set_datum_of_tx_input(InlineDatum(output_reference))
            |> attach_ref_script_to_tx_input(
                #"00000000000000000000000000000000000000000000000000000056",
              )
            |> with_asset_of_tx_input(from_lovelace(4_000_000))
            |> with_asset_of_tx_input(from_asset("PolicyId2", "Nft2", 1)),
        )

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction Output

test testing_add_tx_output() {
  // Arrange:
  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      outputs: [
        // TxOutput1:
        transaction.Output {
          address: from_verification_key(
            #"00000000000000000000000000000000000000000000000000000001",
          ),
          value: from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId1", [Pair("Nft1", 1), Pair("Token1", 3_000)]),
            ],
          ),
          datum: NoDatum,
          reference_script: None,
        },
        // TxOutput2:
        transaction.Output {
          address: from_script(
            #"00000000000000000000000000000000000000000000000000000002",
          ),
          value: from_asset_list(
            [
              Pair("", [Pair("", 4_000_000)]),
              Pair("PolicyId2", [Pair("Nft2", 1)]),
            ],
          ),
          datum: InlineDatum(output_reference),
          reference_script: Some(
            #"00000000000000000000000000000000000000000000000000000056",
          ),
        },
      ],
    }

  let txn_new =
    transaction.placeholder
      |> add_tx_output(
          new_tx_output(
            from_verification_key(
              #"00000000000000000000000000000000000000000000000000000001",
            ),
          )
            |> add_asset_to_tx_output(from_lovelace(2_000_000))
            |> add_asset_to_tx_output(from_asset("PolicyId1", "Nft1", 1))
            |> add_asset_to_tx_output(from_asset("PolicyId1", "Token1", 3_000)),
        )
      |> add_tx_output(
          new_tx_output(
            from_script(
              #"00000000000000000000000000000000000000000000000000000002",
            ),
          )
            |> set_datum_of_tx_output(InlineDatum(output_reference))
            |> attach_ref_script_to_tx_output(
                #"00000000000000000000000000000000000000000000000000000056",
              )
            |> add_asset_to_tx_output(from_lovelace(4_000_000))
            |> add_asset_to_tx_output(from_asset("PolicyId2", "Nft2", 1)),
        )

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

test testing_new_tx_output() {
  // Arrange:
  let tx_out_raw =
    transaction.Output {
      address,
      value: assets.zero,
      datum: NoDatum,
      reference_script: None,
    }

  let tx_out_new = new_tx_output(address)

  // Trace:
  //   trace @"tx_out_raw": tx_out_raw
  //   trace @"tx_out_new": tx_out_new
  // Assert:
  (tx_out_raw == tx_out_new)?
}

test testing_add_asset_to_tx_output() {
  // Arrange:
  let tx_out_raw =
    transaction.Output {
      address,
      value: from_asset_list(
        [
          Pair("", [Pair("", 2_000_000)]),
          Pair("PolicyId1", [Pair("Nft1", 1), Pair("Token1", 3_000)]),
          Pair("PolicyId2", [Pair("Nft2", 1)]),
        ],
      ),
      datum: NoDatum,
      reference_script: None,
    }

  let tx_out_new =
    new_tx_output(address)
      |> add_asset_to_tx_output(from_lovelace(2_000_000))
      |> add_asset_to_tx_output(from_asset("PolicyId1", "Nft1", 1))
      |> add_asset_to_tx_output(from_asset("PolicyId1", "Token1", 3_000))
      |> add_asset_to_tx_output(from_asset("PolicyId2", "Nft2", 1))

  // Trace:
  //   trace @"tx_out_raw": tx_out_raw
  //   trace @"tx_out_new": tx_out_new
  // Assert:
  (tx_out_raw == tx_out_new)?
}

test testing_set_datum_of_tx_output() {
  // Arrange:
  let datum = InlineDatum(output_reference)

  let tx_out_raw =
    transaction.Output {
      address,
      value: assets.zero,
      datum,
      reference_script: None,
    }

  let tx_out_new =
    new_tx_output(address)
      |> set_datum_of_tx_output(datum)

  // Trace:
  //   trace @"tx_out_raw": tx_out_raw
  //   trace @"tx_out_new": tx_out_new
  // Assert:
  (tx_out_raw == tx_out_new)?
}

test testing_attach_ref_script_to_tx_output() {
  // Arrange:
  let ref_script = #"00000000000000000000000000000000000000000000000000000056"

  let tx_out_raw =
    transaction.Output {
      address,
      value: assets.zero,
      datum: NoDatum,
      reference_script: Some(ref_script),
    }

  let tx_out_new =
    new_tx_output(address)
      |> attach_ref_script_to_tx_output(ref_script)

  // Trace:
  //   trace @"tx_out_raw": tx_out_raw
  //   trace @"tx_out_new": tx_out_new
  // Assert:
  (tx_out_raw == tx_out_new)?
}

// ## Test Transaction Fees

test testing_set_fee() {
  // Arrange:
  let txn_raw = Transaction { ..transaction.placeholder, fee: 600_000 }
  let txn_new = transaction.placeholder |> set_fee(600_000)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction Mints

test testing_add_mint() {
  // Arrange:
  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      mint: from_asset_list(
        [
          Pair("PolicyId1", [Pair("Token1", 1_000), Pair("Token2", 200)]),
          Pair("PolicyId2", [Pair("Token1", 30), Pair("Token2", 4)]),
        ],
      ),
    }

  let txn_new =
    transaction.placeholder
      // Partially mint `${PolicyId1}${Token1}`:
      |> add_mint(from_asset("PolicyId1", "Token1", 500))
      |> add_mint(from_asset("PolicyId2", "Token1", 30))
      |> add_mint(from_asset("PolicyId1", "Token2", 200))
      |> add_mint(from_asset("PolicyId2", "Token2", 4))
      // Partially mint `${PolicyId1}${Token1}`:
      |> add_mint(from_asset("PolicyId1", "Token1", 250))
      |> add_mint(from_asset("PolicyId1", "Token1", 250))

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction Certificates

test testing_add_certificate() {
  // Arrange:
  let registered_drep = address.Script("ScriptHash") |> certificate.Registered
  let stake_pool_id = "StakePoolId"

  let certificate =
    RegisterAndDelegateCredential {
      credential: address.Script("ScriptHash"),
      delegate: DelegateBoth {
        stake_pool: stake_pool_id,
        delegate_representative: registered_drep,
      },
      deposit: 80_000_000,
    }

  let txn_raw =
    Transaction { ..transaction.placeholder, certificates: [certificate] }
  let txn_new = transaction.placeholder |> add_certificate(certificate)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction Withdrawals

test testing_add_withdrawal() {
  // Arrange:
  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      withdrawals: [
        Pair(address.Script("a"), 1),
        Pair(address.Script("b"), 2),
        Pair(address.Script("c"), 3),
        Pair(address.VerificationKey("d"), 4),
        Pair(address.VerificationKey("e"), 5),
        Pair(address.VerificationKey("f"), 6),
      ],
    }

  let txn_new =
    transaction.placeholder
      // Add withdrawals in any order with partial amount:
      |> add_withdrawal(address.Script("b"), 1)
      |> add_withdrawal(address.VerificationKey("e"), 5)
      |> add_withdrawal(address.Script("a"), 1)
      |> add_withdrawal(address.Script("c"), 3)
      |> add_withdrawal(address.VerificationKey("f"), 3)
      |> add_withdrawal(address.VerificationKey("d"), 2)
      |> add_withdrawal(address.Script("b"), 1)
      |> add_withdrawal(address.VerificationKey("f"), 3)
      |> add_withdrawal(address.VerificationKey("d"), 2)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Validity Range

test testing_set_validity_range() {
  // Arrange:
  let validity_range = after(10)

  let txn_raw = Transaction { ..transaction.placeholder, validity_range }
  let txn_new = transaction.placeholder |> set_validity_range(validity_range)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Sign Transaction

test testing_add_signatory() {
  // Arrange:
  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      extra_signatories: [
        #"00000000000000000000000000000000000000000000000000000001",
        #"00000000000000000000000000000000000000000000000000000002",
      ],
    }

  let txn_new =
    // The order will be preserved as is:
    transaction.placeholder
      |> add_signatory(
          #"00000000000000000000000000000000000000000000000000000001",
        )
      |> add_signatory(
          #"00000000000000000000000000000000000000000000000000000002",
        )

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction Redeemers

test testing_add_redeemer() {
  // Arrange:
  let script_purpose_1 = "PolicyId" |> transaction.Mint
  let script_purpose_2 = output_reference |> transaction.Spend
  let script_purpose_3 = "ScriptHash" |> address.Script |> transaction.Withdraw
  let script_purpose_4 =
    transaction.Publish {
      at: 3,
      certificate: "ScriptHash"
        |> address.Script
        |> RetireFromConstitutionalCommittee,
    }
  let script_purpose_5 = "VerificationKeyHash" |> StakePool |> transaction.Vote
  let script_purpose_6 =
    transaction.Propose {
      at: 5,
      proposal_procedure: ProposalProcedure {
        deposit: 500_000_000,
        return_address: "ScriptHash" |> address.Script,
        governance_action: NicePoll,
      },
    }

  let redeemer = "Redeemer" |> b_data

  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      redeemers: [
        Pair(script_purpose_1, redeemer), Pair(script_purpose_2, redeemer),
        Pair(script_purpose_3, redeemer), Pair(script_purpose_4, redeemer),
        Pair(script_purpose_5, redeemer), Pair(script_purpose_6, redeemer),
      ],
    }

  let txn_new =
    transaction.placeholder
      // Add redeemers with script purpose in any order:
      |> add_redeemer(script_purpose_1, redeemer)
      |> add_redeemer(script_purpose_3, redeemer)
      |> add_redeemer(script_purpose_5, redeemer)
      |> add_redeemer(script_purpose_6, redeemer)
      |> add_redeemer(script_purpose_4, redeemer)
      |> add_redeemer(script_purpose_2, redeemer)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// Test Transaction Datums

test testing_add_datum() {
  // Arrange:
  let datum = "Data" |> b_data

  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      datums: [
        Pair("DataHash1", datum), Pair("DataHash2", datum),
        Pair("DataHash3", datum), Pair("DataHash4", datum),
      ]
        |> from_pairs(),
    }

  let txn_new =
    transaction.placeholder
      // Add datums with data hash in any order:
      |> add_datum("DataHash1", datum)
      |> add_datum("DataHash3", datum)
      |> add_datum("DataHash4", datum)
      |> add_datum("DataHash2", datum)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction ID

test testing_set_id() {
  // Arrange:
  let txn_raw = Transaction { ..transaction.placeholder, id: "TransactionId" }
  let txn_new = transaction.placeholder |> set_id("TransactionId")

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Transaction Votes

test testing_add_vote() {
  // Arrange:
  let voter_1 = "ScriptHash" |> address.Script |> ConstitutionalCommitteeMember
  let voter_2 = "ScriptHash" |> address.Script |> DelegateRepresentative
  let voter_3 = "VerificationKeyHash" |> StakePool

  let vote_1 = Pair(GovernanceActionId("TransactionId1", 0), governance.No)
  let vote_2 = Pair(GovernanceActionId("TransactionId2", 1), governance.Yes)
  let vote_3 = Pair(GovernanceActionId("TransactionId3", 2), governance.Abstain)

  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      votes: [
        Pair(voter_1, [vote_2]), Pair(voter_2, [vote_1, vote_3]),
        Pair(voter_3, [vote_1, vote_2, vote_3]),
      ],
    }

  let txn_new =
    transaction.placeholder
      // Add votes with voter in any order:
      |> add_vote(voter_1, [vote_2])
      |> add_vote(voter_3, [vote_1, vote_2, vote_3])
      |> add_vote(voter_2, [vote_1, vote_3])

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Proposal Procedures

test testing_add_proposal_procedure() {
  // Arrange:
  let script_1 =
    #"00000000000000000000000000000000000000000000000000000001"
      |> address.Script
  let script_2 =
    #"00000000000000000000000000000000000000000000000000000002"
      |> address.Script
  let script_3 =
    #"00000000000000000000000000000000000000000000000000000003"
      |> address.Script

  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      proposal_procedures: [
        ProposalProcedure(0, script_1, NicePoll),
        ProposalProcedure(1, script_2, NicePoll),
        ProposalProcedure(2, script_3, NicePoll),
      ],
    }

  let txn_new =
    transaction.placeholder
      // The order will be preserved as is:
      |> add_proposal_procedure(0, script_1, NicePoll)
      |> add_proposal_procedure(1, script_2, NicePoll)
      |> add_proposal_procedure(2, script_3, NicePoll)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Current Treasury Amount

test testing_set_current_treasury_amount() {
  // Arrange:
  let treasury = 1_000_000_000_000_000

  let txn_raw =
    Transaction {
      ..transaction.placeholder,
      current_treasury_amount: Some(treasury),
    }

  let txn_new = transaction.placeholder |> set_current_treasury_amount(treasury)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}

// ## Test Treasury Donation

test testing_set_treasury_donation() {
  // Arrange:
  let donate = 20_000_000_000_000

  let txn_raw =
    Transaction { ..transaction.placeholder, treasury_donation: Some(donate) }
  let txn_new = transaction.placeholder |> set_treasury_donation(donate)

  // Trace:
  //   trace @"txn_raw": txn_raw
  //   trace @"txn_new": txn_new
  // Assert:
  (txn_raw == txn_new)?
}
