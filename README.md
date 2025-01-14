# test_kit

This library contains a set of tools, mainly for testing purposes:

- [`print`](#print) (pretty-print data with label)
- [`to_data`](#to_data) (upcast any serialisable type to `Data`)
- [`collections`](#collections) (contains some `list` and `zip3` functions)
- [`fuzzy`](#fuzzy) (`address`, `assets`, `certificate`, `governance`, and `transaction` fuzzers)
- [`time`](#time) (to `add`/`subtract` intervals and unwrapping finite time, taking its inclusivity into account)
- [`tx`](#tx) (helps mocking and constructing transaction data using the `transaction` builder)

| ℹ️  | Package info    | aiken-extra/test_kit                                                                     | 🧰  |
| --- | --------------- | ---------------------------------------------------------------------------------------- | --- |
| 🔴  | **Version**     | **v0.0.2**                                                                               | 🛠️  |
| 🔴  | **Codename**    | **helium**                                                                               | 🔥  |
| 🔴  | **Status**      | **alpha**                                                                                | 🧪  |
| 🟢  | **Depends on**  | [**aiken-lang/fuzz v2.1.0**](https://github.com/aiken-lang/fuzz/releases/tag/v2.1.0)     | ✅  |
| 🟢  | **Depends on**  | [**aiken-lang/stdlib v2.2.0**](https://github.com/aiken-lang/stdlib/releases/tag/v2.2.0) | ✅  |
| 🟢  | **Tested with** | [**aiken v1.1.9**](https://github.com/aiken-lang/aiken/releases/tag/v1.1.9)              | ✅  |

<!-- | 🟢  | **Version**     | **boron**                                                                                | ✅  | -->

<!-- | 🟡  | **Codename**    | **lithium**                                                                              | ☄️  | -->
<!-- | 🟡  | **Codename**    | **beryllium**                                                                            | ☄️  | -->

<!-- | 🟡  | **Status**      | **beta**                                                                                 | ⚗️  | -->

## `print`

Pretty-print data with label:

```gleam
use test_kit.{print}

print("Label", data) // fuzz.label(@"Label: cbor.diagnostic(data)")
```

By calling [`fuzz.label`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#label) internally,
`print` will also work with property testing.

## `to_data`

Upcast any serialisable type to `Data`:

```gleam
use test_kit.{to_data}

any |> to_data // let data: Data = any
```

## `collections`

Zip3:

```gleam
use test_kit/collections

collections.zip3(list_a, list_b, list_c) // -> [(a, b, c)..]
collections.unzip3(list_abc) // -> ([a..], [b..], [c..])
```

List `and` & `or`:

```gleam
use test_kit/collections/logic

[..bools] |> logic.all_true  // -> True | False
[..bools] |> logic.all_false // -> True | False
[..bools] |> logic.any_true  // -> True | False
[..bools] |> logic.any_false // -> True | False
```

## `fuzzy`

Tuple and unique fuzzers:

```gleam
use test_kit/fuzzy

// A convenient way of generating tuples instead of doing map:
test prop_tuple((a, b) via fuzzy.tuple(fuzzer_a, fuzzer_b)) { .. }
// also available: tuple3 to tuple9

// Generates 3 unique elements from the given fuzzer:
test prop_unique((x1, x2, x3) via fuzzy.unique3(fuzzer_x)) { .. }
// other element counts are also available
```

Transaction data fuzzers:

```gleam
use test_kit/fuzzy/fuzzer.{ .. }

test prop_address(address via address_fuzzer(FromFuzzed, WithFuzzedDelegation)) { .. } // random addresses
test prop_assets(value via value_fuzzer(min_lovelaces: 2_000_000)) { .. } // ADA and 0-10 tokens; credit goes to Anastasia-Labs
test prop_blake2b_224(blake2b_224_set via blake2b_224_fuzzer(count: 4)) { .. } // generates 4 distinct Blake2b-224 Hashes each run
test prop_blake2b_256(blake2b_256_set via blake2b_256_fuzzer(count: 6)) { .. } // generates 6 distinct Blake2b-256 Hashes each run
test prop_certificate(d_rep via delegate_representative_fuzzer(when_registered: FromFuzzed)) { .. } // Registered | AlwaysAbstain | AlwaysNoConfidence
test prop_governance(constitution via constitution_fuzzer(some_guardrails: Fuzzed)) { .. } // constitutions with either some guardrails script or none
test prop_transaction(inputs via user_inputs_fuzzer()) { .. } // simple (non-script) inputs; credit goes to Anastasia-Labs

// and more
```

## `time`

Interval additions and subtractions:

```gleam
use test_kit/time.{ .. }

interval.after(25200000)  |> add_interval(lower_bound: 6 |> Minute, upper_bound: 5 |> Hour) // == interval.after(25200000 + 6 * 60 * 1_000)
interval.before(360000)   |> add_interval(lower_bound: 4 |> DS, upper_bound: 3 |> Second) // == interval.before(360000 + 3 * 1_000)
interval.between(4, 5000) |> add_interval(lower_bound: 2 |> MS, upper_bound: 1 |> CS) // == interval.between(4 + 2, 5000 + 1 * 10)

interval.after(25200000)  |> sub_interval(lower_bound: 6 |> Minute, upper_bound: 5 |> Hour) // == interval.after(25200000 - 6 * 60 * 1_000)
interval.before(360000)   |> sub_interval(lower_bound: 4 |> DS, upper_bound: 3 |> Second) // == interval.before(360000 - 3 * 1_000)
interval.between(4, 5000) |> sub_interval(lower_bound: 2 |> MS, upper_bound: 1 |> CS) // == interval.between(4 - 2, 5000 - 1 * 10)

// also available: IntervalBound, IntervalBoundType, and PosixTime operations
```

Unwrapping finite time:

```gleam
use test_kit/time/unwrap

unwrap.finite_start_of(interval) // -> PosixTime
unwrap.finite_end_of(interval)   // -> PosixTime

// inclusivity is taken into account
```

## `tx`

Constructing transaction data:

```gleam
use test_kit/tx.{ .. }

test validate_something() {
  ..
  let tx = transaction.placeholder
    |> add_tx_ref_input(tx_ref_in)
    |> add_tx_input(tx_in_1)
    |> add_tx_input(tx_in_2)
    |> add_tx_output(tx_out_1)
    |> add_tx_output(tx_out_2)
    |> add_signatory("Signer")
  ..
  // assert:
  validator.validate.spend(.., .., .., tx)
}
```

Mocking transaction data:

```gleam
use test_kit/tx/mock.{ .. }

mock_address(from_payment: 1, from_stake: 2)
mock_address("A", "B")    // Address with both Payment and Staking part
mock_address(True, False) // Address with only Payment part

mock_verification_key_credential(from: 34) // VerificationKey(#"00000000000000000000000000000000000000000000000000000034")
mock_script_credential(from: 567)          // Script(#"00000000000000000000000000000000000000000000000000000567")

mock_verification_key_hash(from: 89) // #"00000000000000000000000000000000000000000000000000000089"
mock_script_hash(from: 10)           // #"00000000000000000000000000000000000000000000000000000010"

mock_asset(1112, asset_name: "NFT", quantity: 1) // Value(#"00..............................001112", "NFT", 1)
mock_policy_id(1112)                             // #"00000000000000000000000000000000000000000000000000001112"

mock_output_reference(131415, output_index: 16) // OutputReference(#"00..............................00131415", 16)
mock_transaction_id(131415)                     // #"0000000000000000000000000000000000000000000000000000000000131415"

mock_blake2b_224(from: 224) // #"00000000000000000000000000000000000000000000000000000224"
mock_blake2b_256(from: 256) // #"0000000000000000000000000000000000000000000000000000000000000256"

mock_hash_from_bytearray(#"af", size: 4) // #"000000af"
mock_hash_from_int(123, size: 3)         // #"000123"
mock_hash(1, size: 2)                    // #"0001"
```
