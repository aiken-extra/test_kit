//// @hidden
//// ```
//// Aiken v1.1.21:
//// │ PASS [mem:  49.72 K, cpu:  15.18 M] testing_mock_hash
//// │ PASS [mem:  24.07 K, cpu:   5.84 M] testing_mock_hash_from_bytearray
//// │ PASS [mem: 344.43 K, cpu: 109.74 M] testing_mock_hash_from_int
//// │ PASS [mem:   3.91 M, cpu:   1.21 B] testing_mock_blake2b_224
//// │ PASS [mem:   4.56 M, cpu:   1.41 B] testing_mock_blake2b_256
//// │ PASS [mem: 374.03 K, cpu: 148.94 M] testing_mock_address
//// ```

use aiken/collection/list
use aiken/fuzz
use cardano/address.{Script, VerificationKey}
use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference}
use test_kit/fuzzy
use test_kit/fuzzy/fuzzer.{data_fuzzer}
use test_kit/tx/mock.{
  mock_address, mock_address_from_script, mock_address_from_verification_key,
  mock_address_with_delegation_script, mock_asset, mock_blake2b_224,
  mock_blake2b_256, mock_hash, mock_hash_from_bytearray, mock_hash_from_int,
  mock_o_ref, mock_out_ref, mock_output_reference, mock_policy, mock_policy_id,
  mock_script_address, mock_script_address_with_delegation_key, mock_script_hash,
  mock_sh, mock_tran_hash, mock_tran_id, mock_transaction_hash,
  mock_transaction_id, mock_tx_hash, mock_tx_id, mock_txn_hash, mock_txn_id,
  mock_verification_key_hash, mock_vkh,
}

// /// Aiken v1.1.9:
// /// │ PASS [mem: 261806, cpu: 75093536] mock
// /// │ · with traces
// /// │ | h'00000000000000000000000000000000000000000000000000000001'
// test mock() {
//   trace mock_sh(1)
//   True
// }

// /// Aiken v1.1.9:
// /// │ PASS [mem: 254825, cpu: 71651198] no_mock
// /// │ · with traces
// /// │ | h'00000000000000000000000000000000000000000000000000000001'
// test no_mock() {
//   trace #"00000000000000000000000000000000000000000000000000000001"
//   True
// }

test testing_mock_hash() {
  and {
    mock_hash(1, 2) == #"0001",
    mock_hash("c", 4) == #"00000063",
    mock_hash(True, 6) == #"000000d87a80",
  }
}

test testing_mock_hash_from_bytearray() {
  and {
    mock_hash_from_bytearray("a", 1) == "a",
    mock_hash_from_bytearray(#"ab", 2) == #"00ab",
    mock_hash_from_bytearray(#"cdef", 0) == #"cdef",
    mock_hash_from_bytearray(#"765432", -1) == #"765432",
  }
}

test testing_mock_hash_from_int() {
  and {
    mock_hash_from_int(1, 2) == #"0001",
    mock_hash_from_int(34, 5) == #"0000000034",
    mock_hash_from_int(-1, 2) == #"9999",
    mock_hash_from_int(-34, 5) == #"9999999966",
  }
}

test testing_mock_blake2b_224() {
  //   trace @"mock_blake2b_224(2)": mock_blake2b_224(2)
  //   trace @"mock_blake2b_224(224)": mock_blake2b_224(224)
  //   trace @"mock_blake2b_224(-2)": mock_blake2b_224(-2)
  //   trace @"mock_blake2b_224(-224)": mock_blake2b_224(-224)

  and {
    mock_blake2b_224(2) == #"00000000000000000000000000000000000000000000000000000002",
    mock_blake2b_224(224) == #"00000000000000000000000000000000000000000000000000000224",
    mock_blake2b_224(-2) == #"99999999999999999999999999999999999999999999999999999998",
    mock_blake2b_224(-224) == #"99999999999999999999999999999999999999999999999999999776",
  }
}

test testing_mock_blake2b_256() {
  //   trace @"mock_blake2b_256(2)": mock_blake2b_256(2)
  //   trace @"mock_blake2b_256(256)": mock_blake2b_256(256)
  //   trace @"mock_blake2b_256(-2)": mock_blake2b_256(-2)
  //   trace @"mock_blake2b_256(-256)": mock_blake2b_256(-256)

  and {
    mock_blake2b_256(2) == #"0000000000000000000000000000000000000000000000000000000000000002",
    mock_blake2b_256(256) == #"0000000000000000000000000000000000000000000000000000000000000256",
    mock_blake2b_256(-2) == #"9999999999999999999999999999999999999999999999999999999999999998",
    mock_blake2b_256(-256) == #"9999999999999999999999999999999999999999999999999999999999999744",
  }
}

test testing_mock_address() {
  let address_01 =
    address.from_verification_key(
      #"00000000000000000000000000000000000000000000000000000000",
    )
      |> address.with_delegation_key(
          #"00000000000000000000000000000000000000000000000000000001",
        )

  let script_address_01 =
    address.from_script(
      #"00000000000000000000000000000000000000000000000000000000",
    )
      |> address.with_delegation_script(
          #"00000000000000000000000000000000000000000000000000000001",
        )

  let address_1 =
    address.from_verification_key(
      #"00000000000000000000000000000000000000000000000000000001",
    )

  let script_address_1 =
    address.from_script(
      #"00000000000000000000000000000000000000000000000000000001",
    )

  let address_with_delegation_script_01 =
    address.from_verification_key(
      #"00000000000000000000000000000000000000000000000000000000",
    )
      |> address.with_delegation_script(
          #"00000000000000000000000000000000000000000000000000000001",
        )

  let script_address_with_delegation_key_01 =
    address.from_script(
      #"00000000000000000000000000000000000000000000000000000000",
    )
      |> address.with_delegation_key(
          #"00000000000000000000000000000000000000000000000000000001",
        )

  and {
    // Address(Key, Key):
    mock_address(0, 1) == address_01,
    // Address(Script, Script):
    mock_script_address(0, 1) == script_address_01,
    // Address(Key, Script):
    mock_address_with_delegation_script(0, 1) == address_with_delegation_script_01,
    // Address(Script, Key):
    mock_script_address_with_delegation_key(0, 1) == script_address_with_delegation_key_01,
    // Address(Credential):
    mock_address_from_verification_key(1) == address_1,
    mock_address_from_script(1) == script_address_1,
    // Address(Key):
    mock_address(1, 0) == address_1,
    mock_address(1, "") == address_1,
    mock_address(1, []) == address_1,
    mock_address(1, False) == address_1,
    mock_address(1, Void) == address_1,
    // Address(Script):
    mock_script_address(1, 0) == script_address_1,
    mock_script_address(1, "") == script_address_1,
    mock_script_address(1, []) == script_address_1,
    mock_script_address(1, False) == script_address_1,
    mock_script_address(1, Void) == script_address_1,
  }
}

test testing_mock_credential(
  (v, s) via fuzzy.tuple(data_fuzzer(), data_fuzzer()),
) {
  let vk_l = VerificationKey(v |> mock_verification_key_hash)
  let vk_r = VerificationKey(v |> mock_vkh)

  let sk_l = Script(s |> mock_script_hash)
  let sk_r = Script(s |> mock_sh)

  and {
    // testing alias:
    vk_l == vk_r,
    sk_l == sk_r,
    mock_verification_key_hash(v) == mock_vkh(v),
    mock_script_hash(s) == mock_sh(s),
    // `VerificationKeyHash` and `ScriptHash` are both `Hash<Blake2b_224, ByteArray>`:
    mock_verification_key_hash(v) == mock_sh(v),
    mock_verification_key_hash(s) == mock_sh(s),
    mock_script_hash(v) == mock_vkh(v),
    mock_script_hash(s) == mock_vkh(s),
  }
}

test testing_mock_asset(
  (p, a, q) via fuzzy.tuple3(data_fuzzer(), fuzz.bytearray(), fuzz.int()),
) {
  let p1: PolicyId = mock_policy_id(p)
  let p2: PolicyId = mock_policy(p)

  and {
    mock_asset(p, a, q) == assets.from_asset(p1, a, q),
    mock_asset(p, a, q) == assets.from_asset(p2, a, q),
    // testing alias:
    p1 == p2,
    // p1 - p2 =
    mock_asset(p1, a, q) |> assets.add(p2, a, -q) |> assets.is_zero,
  }
}

test testing_mock_output_reference(
  (x, o) via fuzzy.tuple(data_fuzzer(), fuzz.int_between(0, 512)),
) {
  let o_ref_1 = OutputReference(mock_transaction_id(x), o)
  let o_ref_2 =
    OutputReference { transaction_id: mock_tran_id(x), output_index: o }
  let o_ref_3 = OutputReference(mock_txn_id(x), o)
  let o_ref_4 =
    OutputReference { transaction_id: mock_tx_id(x), output_index: o }

  let o_ref_5 = OutputReference(mock_tx_hash(x), o)
  let o_ref_6 =
    OutputReference { transaction_id: mock_txn_hash(x), output_index: o }
  let o_ref_7 = OutputReference(mock_tran_hash(x), o)
  let o_ref_8 =
    OutputReference {
      transaction_id: mock_transaction_hash(x),
      output_index: o,
    }

  expect [_] =
    // all must be the same, ie: only 1 distinct element
    [
      o_ref_1,
      o_ref_2,
      o_ref_3,
      o_ref_4,
      o_ref_5,
      o_ref_6,
      o_ref_7,
      o_ref_8,
      // testing alias:
      mock_output_reference(x, o),
      mock_out_ref(x, o),
      mock_o_ref(x, o),
    ]
      |> list.unique
}
