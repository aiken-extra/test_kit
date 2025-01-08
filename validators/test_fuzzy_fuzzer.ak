//// @hidden

use aiken/collection/list
use aiken/crypto.{
  Blake2b_224, Blake2b_256, DataHash, ScriptHash, VerificationKeyHash,
}
use aiken/fuzz
use aiken/primitive/bytearray
use cardano/address.{Address, VerificationKey}
use cardano/assets
use cardano/certificate.{
  AlwaysAbstain, AlwaysNoConfidence, DelegateBlockProduction, DelegateBoth,
  DelegateRepresentative, DelegateVote,
}
use cardano/transaction.{DatumHash, InlineDatum, NoDatum, OutputReference}
use test_kit.{print}
use test_kit/fuzzy/fuzzer.{
  FromFuzzed, FromKey, FromScript, Fuzzed, Specified, VoteFuzzed,
  WithDelegationKey, WithDelegationScript, WithFuzzedDelegation,
  WithNoDelegation, WithTheSameDelegationScriptOrKey, address_fuzzer,
  authentic_script_input_fuzzer, authentic_script_output_fuzzer,
  blake2b_224_fuzzer, blake2b_256_fuzzer, credential_fuzzer, data_fuzzer,
  data_hash_fuzzer, datum_fuzzer, delegate_fuzzer,
  delegate_representative_fuzzer, inputs_with_an_authentic_script_input_fuzzer,
  mint_fuzzer, output_reference_fuzzer, script_hash_fuzzer, script_input_fuzzer,
  script_output_fuzzer, specific_script_input_fuzzer,
  specific_script_output_fuzzer, user_input_fuzzer, user_inputs_fuzzer,
  user_output_fuzzer, user_outputs_fuzzer, value_fuzzer,
  verification_key_hash_fuzzer,
}

// ## Address Fuzzers

// ### Specified Script Address Fuzzers

fn test_specified_script_address_with_no_delegation_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(FromScript(Specified(script_hash)), WithNoDelegation),
    )
  (script_hash, address)
}

test testing_specified_script_address_with_no_delegation_fuzzer(
  (script_hash, address) via test_specified_script_address_with_no_delegation_fuzzer(),
) {
  address == address.from_script(script_hash)
}

fn test_specified_script_address_with_specified_delegation_script_fuzzer() -> Fuzzer<
  (ScriptHash, ScriptHash, Address),
> {
  let payment_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let stake_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Specified(payment_script_hash)),
        WithDelegationScript(Specified(stake_script_hash)),
      ),
    )
  (payment_script_hash, stake_script_hash, address)
}

test testing_specified_script_address_with_specified_delegation_script_fuzzer(
  (payment_script_hash, stake_script_hash, address) via test_specified_script_address_with_specified_delegation_script_fuzzer(),
) {
  address == (
    address.from_script(payment_script_hash)
      |> address.with_delegation_script(stake_script_hash)
  )
}

fn test_specified_script_address_with_fuzzed_delegation_script_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let payment_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Specified(payment_script_hash)),
        WithDelegationScript(Fuzzed),
      ),
    )
  (payment_script_hash, address)
}

test testing_specified_script_address_with_fuzzed_delegation_script_fuzzer(
  (payment_script_hash, address) via test_specified_script_address_with_fuzzed_delegation_script_fuzzer(),
) {
  //   print("stake_credential", address.stake_credential)
  address.payment_credential == address.Script(payment_script_hash)
}

fn test_specified_script_address_with_specified_delegation_key_fuzzer() -> Fuzzer<
  (ScriptHash, VerificationKeyHash, Address),
> {
  let payment_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let stake_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Specified(payment_script_hash)),
        WithDelegationKey(Specified(stake_key_hash)),
      ),
    )
  (payment_script_hash, stake_key_hash, address)
}

test testing_specified_script_address_with_specified_delegation_key_fuzzer(
  (payment_script_hash, stake_key_hash, address) via test_specified_script_address_with_specified_delegation_key_fuzzer(),
) {
  address == (
    address.from_script(payment_script_hash)
      |> address.with_delegation_key(stake_key_hash)
  )
}

fn test_specified_script_address_with_fuzzed_delegation_key_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let payment_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Specified(payment_script_hash)),
        WithDelegationKey(Fuzzed),
      ),
    )
  (payment_script_hash, address)
}

test testing_specified_script_address_with_fuzzed_delegation_key_fuzzer(
  (payment_script_hash, address) via test_specified_script_address_with_fuzzed_delegation_key_fuzzer(),
) {
  //   print("stake_credential", address.stake_credential)
  address.payment_credential == address.Script(payment_script_hash)
}

fn test_specified_script_address_with_the_same_delegation_script_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let payment_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Specified(payment_script_hash)),
        WithTheSameDelegationScriptOrKey,
      ),
    )
  (payment_script_hash, address)
}

test testing_specified_script_address_with_the_same_delegation_script_fuzzer(
  (script_hash, address) via test_specified_script_address_with_the_same_delegation_script_fuzzer(),
) {
  address == (
    address.from_script(script_hash)
      |> address.with_delegation_script(script_hash)
  )
}

fn test_specified_script_address_with_fuzzed_delegation_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let payment_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Specified(payment_script_hash)),
        WithFuzzedDelegation,
      ),
    )
  (payment_script_hash, address)
}

test testing_specified_script_address_with_fuzzed_delegation_fuzzer_distribution(
  (payment_script_hash, address) via test_specified_script_address_with_fuzzed_delegation_fuzzer(),
) {
  fuzz.label(
    when address.stake_credential is {
      None ->
        // 25%
        @"NoDelegation"

      Some(address.Inline(address.Script(stake_script_hash))) ->
        if payment_script_hash == stake_script_hash {
          // 25%
          @"TheSameDelegationScript"
        } else {
          // 25%
          @"DelegationScript"
        }

      Some(address.Inline(VerificationKey(_stake_key_hash))) ->
        // 25%
        @"DelegationKey"

      Some(_) ->
        // 0%
        @"PointerDelegation"
    },
  )
  address.payment_credential == address.Script(payment_script_hash)
}

// ### Specified Key Address Fuzzers

fn test_specified_key_address_with_no_delegation_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(address_fuzzer(FromKey(Specified(key_hash)), WithNoDelegation))
  (key_hash, address)
}

test testing_specified_key_address_with_no_delegation_fuzzer(
  (key_hash, address) via test_specified_key_address_with_no_delegation_fuzzer(),
) {
  address == address.from_verification_key(key_hash)
}

fn test_specified_key_address_with_specified_delegation_script_fuzzer() -> Fuzzer<
  (VerificationKeyHash, ScriptHash, Address),
> {
  let payment_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let stake_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Specified(payment_key_hash)),
        WithDelegationScript(Specified(stake_script_hash)),
      ),
    )
  (payment_key_hash, stake_script_hash, address)
}

test testing_specified_key_address_with_specified_delegation_script_fuzzer(
  (payment_key_hash, stake_script_hash, address) via test_specified_key_address_with_specified_delegation_script_fuzzer(),
) {
  address == (
    address.from_verification_key(payment_key_hash)
      |> address.with_delegation_script(stake_script_hash)
  )
}

fn test_specified_key_address_with_fuzzed_delegation_script_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let payment_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Specified(payment_key_hash)),
        WithDelegationScript(Fuzzed),
      ),
    )
  (payment_key_hash, address)
}

test testing_specified_key_address_with_fuzzed_delegation_script_fuzzer(
  (payment_key_hash, address) via test_specified_key_address_with_fuzzed_delegation_script_fuzzer(),
) {
  //   print("stake_credential", address.stake_credential)
  address.payment_credential == VerificationKey(payment_key_hash)
}

fn test_specified_key_address_with_specified_delegation_key_fuzzer() -> Fuzzer<
  (VerificationKeyHash, VerificationKeyHash, Address),
> {
  let payment_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let stake_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Specified(payment_key_hash)),
        WithDelegationKey(Specified(stake_key_hash)),
      ),
    )
  (payment_key_hash, stake_key_hash, address)
}

test testing_specified_key_address_with_specified_delegation_key_fuzzer(
  (payment_key_hash, stake_key_hash, address) via test_specified_key_address_with_specified_delegation_key_fuzzer(),
) {
  address == (
    address.from_verification_key(payment_key_hash)
      |> address.with_delegation_key(stake_key_hash)
  )
}

fn test_specified_key_address_with_fuzzed_delegation_key_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let payment_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Specified(payment_key_hash)),
        WithDelegationKey(Fuzzed),
      ),
    )
  (payment_key_hash, address)
}

test testing_specified_key_address_with_fuzzed_delegation_key_fuzzer(
  (payment_key_hash, address) via test_specified_key_address_with_fuzzed_delegation_key_fuzzer(),
) {
  //   print("stake_credential", address.stake_credential)
  address.payment_credential == VerificationKey(payment_key_hash)
}

fn test_specified_key_address_with_the_same_delegation_key_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let payment_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Specified(payment_key_hash)),
        WithTheSameDelegationScriptOrKey,
      ),
    )
  (payment_key_hash, address)
}

test testing_specified_key_address_with_the_same_delegation_key_fuzzer(
  (key_hash, address) via test_specified_key_address_with_the_same_delegation_key_fuzzer(),
) {
  address == (
    address.from_verification_key(key_hash)
      |> address.with_delegation_key(key_hash)
  )
}

fn test_specified_key_address_with_fuzzed_delegation_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let payment_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(FromKey(Specified(payment_key_hash)), WithFuzzedDelegation),
    )
  (payment_key_hash, address)
}

test testing_specified_key_address_with_fuzzed_delegation_fuzzer_distribution(
  (payment_key_hash, address) via test_specified_key_address_with_fuzzed_delegation_fuzzer(),
) {
  fuzz.label(
    when address.stake_credential is {
      None ->
        // 25%
        @"NoDelegation"

      Some(address.Inline(address.Script(_stake_script_hash))) ->
        // 25%
        @"DelegationScript"

      Some(address.Inline(VerificationKey(stake_key_hash))) ->
        if payment_key_hash == stake_key_hash {
          // 25%
          @"TheSameDelegationKey"
        } else {
          // 25%
          @"DelegationKey"
        }

      Some(_) ->
        // 0%
        @"PointerDelegation"
    },
  )
  address.payment_credential == VerificationKey(payment_key_hash)
}

// ### Fuzzed Script Address Fuzzers

test testing_fuzzed_script_address_with_no_delegation_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromScript(Fuzzed),
    WithNoDelegation,
  ),
) {
  expect address.Script(_payment_script_hash) = payment_credential
  //   print("payment_script_hash", payment_script_hash)
  stake_credential == None
}

fn test_fuzzed_script_address_with_specified_delegation_script_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let stake_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Fuzzed),
        WithDelegationScript(Specified(stake_script_hash)),
      ),
    )
  (stake_script_hash, address)
}

test testing_fuzzed_script_address_with_specified_delegation_script_fuzzer(
  (stake_script_hash, Address { payment_credential, stake_credential }) via test_fuzzed_script_address_with_specified_delegation_script_fuzzer(),
) {
  expect address.Script(_payment_script_hash) = payment_credential
  //   print("payment_script_hash", payment_script_hash)
  stake_credential == (
    stake_script_hash |> address.Script |> address.Inline |> Some
  )
}

test testing_fuzzed_script_address_with_fuzzed_delegation_script_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromScript(Fuzzed),
    WithDelegationScript(Fuzzed),
  ),
) {
  expect address.Script(_payment_script_hash) = payment_credential
  expect Some(address.Inline(address.Script(_stake_script_hash))) =
    stake_credential
  //   print("Address", (payment_script_hash, stake_script_hash))
}

fn test_fuzzed_script_address_with_specified_delegation_key_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let stake_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromScript(Fuzzed),
        WithDelegationKey(Specified(stake_key_hash)),
      ),
    )
  (stake_key_hash, address)
}

test testing_fuzzed_script_address_with_specified_delegation_key_fuzzer(
  (stake_key_hash, Address { payment_credential, stake_credential }) via test_fuzzed_script_address_with_specified_delegation_key_fuzzer(),
) {
  expect address.Script(_payment_key_hash) = payment_credential
  //   print("payment_key_hash", payment_key_hash)
  stake_credential == (
    stake_key_hash |> VerificationKey |> address.Inline |> Some
  )
}

test testing_fuzzed_script_address_with_fuzzed_delegation_key_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromScript(Fuzzed),
    WithDelegationKey(Fuzzed),
  ),
) {
  expect address.Script(_payment_key_hash) = payment_credential
  expect Some(address.Inline(VerificationKey(_stake_key_hash))) =
    stake_credential
  //   print("Address", (payment_key_hash, stake_key_hash))
}

test testing_fuzzed_script_address_with_the_same_delegation_script_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromScript(Fuzzed),
    WithTheSameDelegationScriptOrKey,
  ),
) {
  expect address.Script(_payment_script_hash) = payment_credential
  expect Some(address.Inline(address.Script(_stake_script_hash))) =
    stake_credential
  //   print("Address", (payment_script_hash, stake_script_hash))
}

test testing_fuzzed_script_address_with_fuzzed_delegation_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromScript(Fuzzed),
    WithFuzzedDelegation,
  ),
) {
  expect address.Script(payment_script_hash) = payment_credential
  fuzz.label(
    when stake_credential is {
      None ->
        // 25%
        @"NoDelegation"

      Some(address.Inline(address.Script(stake_script_hash))) ->
        if payment_script_hash == stake_script_hash {
          // 25%
          @"TheSameDelegationScript"
        } else {
          // 25%
          @"DelegationScript"
        }

      Some(address.Inline(VerificationKey(_stake_key_hash))) ->
        // 25%
        @"DelegationKey"

      Some(_) ->
        // 0%
        @"PointerDelegation"
    },
  )
}

// ### Fuzzed Key Address Fuzzers

test testing_fuzzed_key_address_with_no_delegation_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromKey(Fuzzed),
    WithNoDelegation,
  ),
) {
  expect VerificationKey(_payment_key_hash) = payment_credential
  //   print("payment_key_hash", payment_key_hash)
  stake_credential == None
}

fn test_fuzzed_key_address_with_specified_delegation_script_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let stake_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Fuzzed),
        WithDelegationScript(Specified(stake_script_hash)),
      ),
    )
  (stake_script_hash, address)
}

test testing_fuzzed_key_address_with_specified_delegation_script_fuzzer(
  (stake_script_hash, Address { payment_credential, stake_credential }) via test_fuzzed_key_address_with_specified_delegation_script_fuzzer(),
) {
  expect VerificationKey(_payment_key_hash) = payment_credential
  //   print("payment_key_hash", payment_key_hash)
  stake_credential == (
    stake_script_hash |> address.Script |> address.Inline |> Some
  )
}

test testing_fuzzed_key_address_with_fuzzed_delegation_script_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromKey(Fuzzed),
    WithDelegationScript(Fuzzed),
  ),
) {
  expect VerificationKey(_payment_key_hash) = payment_credential
  expect Some(address.Inline(address.Script(_stake_script_hash))) =
    stake_credential
  //   print("Address", (payment_key_hash, stake_script_hash))
}

fn test_fuzzed_key_address_with_specified_delegation_key_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let stake_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromKey(Fuzzed),
        WithDelegationKey(Specified(stake_key_hash)),
      ),
    )
  (stake_key_hash, address)
}

test testing_fuzzed_key_address_with_specified_delegation_key_fuzzer(
  (stake_key_hash, Address { payment_credential, stake_credential }) via test_fuzzed_key_address_with_specified_delegation_key_fuzzer(),
) {
  expect VerificationKey(_payment_key_hash) = payment_credential
  //   print("payment_key_hash", payment_key_hash)
  stake_credential == (
    stake_key_hash |> VerificationKey |> address.Inline |> Some
  )
}

test testing_fuzzed_key_address_with_fuzzed_delegation_key_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromKey(Fuzzed),
    WithDelegationKey(Fuzzed),
  ),
) {
  expect VerificationKey(_payment_key_hash) = payment_credential
  expect Some(address.Inline(VerificationKey(_stake_key_hash))) =
    stake_credential
  //   print("Address", (payment_key_hash, stake_key_hash))
}

test testing_fuzzed_key_address_with_the_same_delegation_key_fuzzer(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromKey(Fuzzed),
    WithTheSameDelegationScriptOrKey,
  ),
) {
  expect VerificationKey(_payment_key_hash) = payment_credential
  expect Some(address.Inline(VerificationKey(_stake_key_hash))) =
    stake_credential
  //   print("Address", (payment_key_hash, stake_key_hash))
}

test testing_fuzzed_key_address_with_fuzzed_delegation_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromKey(Fuzzed),
    WithFuzzedDelegation,
  ),
) {
  expect VerificationKey(payment_key_hash) = payment_credential
  fuzz.label(
    when stake_credential is {
      None ->
        // 25%
        @"NoDelegation"

      Some(address.Inline(address.Script(_stake_script_hash))) ->
        // 25%
        @"DelegationScript"

      Some(address.Inline(VerificationKey(stake_key_hash))) ->
        if payment_key_hash == stake_key_hash {
          // 25%
          @"TheSameDelegationKey"
        } else {
          // 25%
          @"DelegationKey"
        }

      Some(_) ->
        // 0%
        @"PointerDelegation"
    },
  )
}

// ### Fuzzed Address Fuzzers

test testing_fuzzed_address_with_no_delegation_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromFuzzed,
    WithNoDelegation,
  ),
) {
  fuzz.label(
    when payment_credential is {
      address.Script(_payment_script_hash) -> @"ScriptAddress"
      VerificationKey(_payment_key_hash) -> @"KeyAddress"
    },
  )
  stake_credential == None
}

fn test_fuzzed_address_with_specified_delegation_script_fuzzer() -> Fuzzer<
  (ScriptHash, Address),
> {
  let stake_script_hash <- fuzz.and_then(script_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(
        FromFuzzed,
        WithDelegationScript(Specified(stake_script_hash)),
      ),
    )
  (stake_script_hash, address)
}

test testing_fuzzed_address_with_specified_delegation_script_fuzzer_distribution(
  (stake_script_hash, Address { payment_credential, stake_credential }) via test_fuzzed_address_with_specified_delegation_script_fuzzer(),
) {
  fuzz.label(
    when payment_credential is {
      address.Script(_payment_script_hash) -> @"ScriptAddress"
      VerificationKey(_payment_key_hash) -> @"KeyAddress"
    },
  )
  stake_credential == (
    stake_script_hash |> address.Script |> address.Inline |> Some
  )
}

test testing_fuzzed_address_with_fuzzed_delegation_script_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromFuzzed,
    WithDelegationScript(Fuzzed),
  ),
) {
  fuzz.label(
    when payment_credential is {
      address.Script(_payment_script_hash) -> @"ScriptAddress"
      VerificationKey(_payment_key_hash) -> @"KeyAddress"
    },
  )
  expect Some(address.Inline(address.Script(_stake_script_hash))) =
    stake_credential
}

fn test_fuzzed_address_with_specified_delegation_key_fuzzer() -> Fuzzer<
  (VerificationKeyHash, Address),
> {
  let stake_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())
  let address <-
    fuzz.map(
      address_fuzzer(FromFuzzed, WithDelegationKey(Specified(stake_key_hash))),
    )
  (stake_key_hash, address)
}

test testing_fuzzed_address_with_specified_delegation_key_fuzzer_distribution(
  (stake_key_hash, Address { payment_credential, stake_credential }) via test_fuzzed_address_with_specified_delegation_key_fuzzer(),
) {
  fuzz.label(
    when payment_credential is {
      address.Script(_payment_script_hash) -> @"ScriptAddress"
      VerificationKey(_payment_key_hash) -> @"KeyAddress"
    },
  )
  stake_credential == (
    stake_key_hash |> VerificationKey |> address.Inline |> Some
  )
}

test testing_fuzzed_address_with_fuzzed_delegation_key_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromFuzzed,
    WithDelegationKey(Fuzzed),
  ),
) {
  fuzz.label(
    when payment_credential is {
      address.Script(_payment_script_hash) -> @"ScriptAddress"
      VerificationKey(_payment_key_hash) -> @"KeyAddress"
    },
  )
  expect Some(address.Inline(VerificationKey(_stake_key_hash))) =
    stake_credential
}

test testing_fuzzed_address_with_the_same_delegation_script_or_key_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromFuzzed,
    WithTheSameDelegationScriptOrKey,
  ),
) {
  fuzz.label(
    when payment_credential is {
      address.Script(_payment_script_hash) -> @"ScriptAddress"
      VerificationKey(_payment_key_hash) -> @"KeyAddress"
    },
  )
  stake_credential == Some(payment_credential |> address.Inline)
}

test testing_fuzzed_address_with_fuzzed_delegation_fuzzer_distribution(
  Address(payment_credential, stake_credential) via address_fuzzer(
    FromFuzzed,
    WithFuzzedDelegation,
  ),
) {
  fuzz.label(
    when (payment_credential, stake_credential) is {
      // ScriptAddress
      (address.Script(_payment_script_hash), None) ->
        // 12.5%
        @"ScriptAddress with NoDelegation"

      (
        address.Script(payment_script_hash),
        Some(address.Inline(address.Script(stake_script_hash))),
      ) ->
        if payment_script_hash == stake_script_hash {
          // 12.5%
          @"ScriptAddress with TheSameDelegationScript"
        } else {
          // 12.5%
          @"ScriptAddress with DelegationScript"
        }

      (
        address.Script(_payment_script_hash),
        Some(address.Inline(VerificationKey(_stake_key_hash))),
      ) ->
        // 12.5%
        @"ScriptAddress with DelegationKey"

      (address.Script(_payment_script_hash), Some(_)) ->
        // 0%
        @"ScriptAddress with PointerDelegation"

      // KeyAddress
      (VerificationKey(_payment_key_hash), None) ->
        // 12.5%
        @"KeyAddress with NoDelegation"

      (
        VerificationKey(_payment_key_hash),
        Some(address.Inline(address.Script(_stake_script_hash))),
      ) ->
        // 12.5%
        @"KeyAddress with DelegationScript"

      (
        VerificationKey(payment_key_hash),
        Some(address.Inline(VerificationKey(stake_key_hash))),
      ) ->
        if payment_key_hash == stake_key_hash {
          // 12.5%
          @"KeyAddress with TheSameDelegationKey"
        } else {
          // 12.5%
          @"KeyAddress with DelegationKey"
        }

      (VerificationKey(_payment_key_hash), Some(_)) ->
        // 0%
        @"KeyAddress with PointerDelegation"
    },
  )
}

// ### Credential Fuzzer

fn test_specified_script_credential_fuzzer() -> Fuzzer<
  (ScriptHash, address.Credential),
> {
  let script_hash <- fuzz.and_then(script_hash_fuzzer())

  let credential <-
    fuzz.map(credential_fuzzer(FromScript(Specified(script_hash))))
  (script_hash, credential)
}

test testing_specified_script_credential_fuzzer(
  (script_hash, credential) via test_specified_script_credential_fuzzer(),
) {
  address.Script(script_hash) == credential
}

test testing_fuzzed_script_credential_fuzzer(
  credential via credential_fuzzer(FromScript(Fuzzed)),
) {
  expect address.Script(_script_hash) = credential
  //   print("script_hash", script_hash)
}

fn test_specified_key_credential_fuzzer() -> Fuzzer<
  (VerificationKeyHash, address.Credential),
> {
  let verification_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())

  let credential <-
    fuzz.map(credential_fuzzer(FromKey(Specified(verification_key_hash))))
  (verification_key_hash, credential)
}

test testing_specified_key_credential_fuzzer(
  (verification_key_hash, credential) via test_specified_key_credential_fuzzer(),
) {
  VerificationKey(verification_key_hash) == credential
}

test testing_fuzzed_key_credential_fuzzer(
  credential via credential_fuzzer(FromKey(Fuzzed)),
) {
  expect VerificationKey(_verification_key_hash) = credential
  //   print("verification_key_hash", verification_key_hash)
}

test testing_fuzzed_credential_fuzzer_distribution(
  credential via credential_fuzzer(FromFuzzed),
) {
  fuzz.label(
    when credential is {
      address.Script(_script_hash) -> @"Script"
      VerificationKey(_key_hash) -> @"VerificationKey"
    },
  )
}

// ## Asset Fuzzers

pub fn trace_value(value: assets.Value) {
  let flatten_value <- list.for_each(value |> assets.flatten)
  print("Value", flatten_value)
}

test testing_value_fuzzer(
  value via fuzz.and_then(fuzz.int_at_least(2_000_000), value_fuzzer),
) {
  //   value |> trace_value
  let policies = value |> assets.policies |> list.length
  expect policies >= 1 && policies <= 1 + 10
  expect assets.lovelace_of(value) >= 2_000_000
  expect {
    let (_policy_id, _token_name, quantity) <- list.all(value |> assets.flatten)
    quantity > 0
  }
}

test testing_mint_fuzzer(mint via mint_fuzzer()) {
  //   mint |> trace_value
  let policies = mint |> assets.policies |> list.length
  expect policies >= 1 && policies <= 10
  expect {
    let (_policy_id, _token_name, quantity) <- list.all(mint |> assets.flatten)
    quantity > 0
  }
}

// ## Certificate Fuzzers

fn test_specified_script_delegate_representative_fuzzer() -> Fuzzer<
  (ScriptHash, DelegateRepresentative),
> {
  let script_hash <- fuzz.and_then(script_hash_fuzzer())

  let delegate_representative <-
    fuzz.map(
      delegate_representative_fuzzer(
        when_registered: FromScript(Specified(script_hash)),
      ),
    )
  (script_hash, delegate_representative)
}

test testing_specified_script_delegate_representative_fuzzer_distribution(
  (script_hash, delegate_representative) via test_specified_script_delegate_representative_fuzzer(),
) {
  when delegate_representative is {
    certificate.Registered(credential) -> {
      @"Registered Script dRep" |> fuzz.label
      credential == address.Script(script_hash)
    }

    AlwaysAbstain -> {
      @"AlwaysAbstain" |> fuzz.label
      True
    }

    AlwaysNoConfidence -> {
      @"AlwaysNoConfidence" |> fuzz.label
      True
    }
  }
}

test testing_fuzzed_script_delegate_representative_fuzzer_distribution(
  delegate_representative via delegate_representative_fuzzer(
    when_registered: FromScript(Fuzzed),
  ),
) {
  when delegate_representative is {
    certificate.Registered(credential) -> {
      expect address.Script(_script_hash) = credential
      @"Registered Script dRep" |> fuzz.label
    }
    AlwaysAbstain -> @"AlwaysAbstain" |> fuzz.label
    AlwaysNoConfidence -> @"AlwaysNoConfidence" |> fuzz.label
  }
}

fn test_specified_key_delegate_representative_fuzzer() -> Fuzzer<
  (VerificationKeyHash, DelegateRepresentative),
> {
  let verification_key_hash <- fuzz.and_then(verification_key_hash_fuzzer())

  let delegate_representative <-
    fuzz.map(
      delegate_representative_fuzzer(
        when_registered: FromKey(Specified(verification_key_hash)),
      ),
    )
  (verification_key_hash, delegate_representative)
}

test testing_specified_key_delegate_representative_fuzzer_distribution(
  (verification_key_hash, delegate_representative) via test_specified_key_delegate_representative_fuzzer(),
) {
  when delegate_representative is {
    certificate.Registered(credential) -> {
      @"Registered Key dRep" |> fuzz.label
      credential == VerificationKey(verification_key_hash)
    }

    AlwaysAbstain -> {
      @"AlwaysAbstain" |> fuzz.label
      True
    }

    AlwaysNoConfidence -> {
      @"AlwaysNoConfidence" |> fuzz.label
      True
    }
  }
}

test testing_fuzzed_key_delegate_representative_fuzzer_distribution(
  delegate_representative via delegate_representative_fuzzer(
    when_registered: FromKey(Fuzzed),
  ),
) {
  when delegate_representative is {
    certificate.Registered(credential) -> {
      expect VerificationKey(_verification_key_hash) = credential
      @"Registered Key dRep" |> fuzz.label
    }
    AlwaysAbstain -> @"AlwaysAbstain" |> fuzz.label
    AlwaysNoConfidence -> @"AlwaysNoConfidence" |> fuzz.label
  }
}

test testing_fuzzed_delegate_representative_fuzzer_registered_distribution(
  delegate_representative via delegate_representative_fuzzer(
    when_registered: FromFuzzed,
  ),
) {
  when delegate_representative is {
    certificate.Registered(address.Script(_script_hash)) ->
      // 16.7%
      @"Registered Script dRep" |> fuzz.label

    certificate.Registered(VerificationKey(_verification_key_hash)) ->
      // 16.7%
      @"Registered Key dRep" |> fuzz.label

    AlwaysAbstain ->
      // 33.3%
      @"AlwaysAbstain" |> fuzz.label

    AlwaysNoConfidence ->
      // 33.3%
      @"AlwaysNoConfidence" |> fuzz.label
  }
}

test testing_delegate_fuzzer_distribution(
  delegate via delegate_fuzzer(
    when_block_production: Fuzzed,
    when_vote: VoteFuzzed,
    when_both: (Fuzzed, VoteFuzzed),
  ),
) {
  fuzz.label(
    when delegate is {
      DelegateBlockProduction(_stake_pool) -> @"DelegateBlockProduction"
      DelegateVote(_delegate_representative) -> @"DelegateVote"
      DelegateBoth(_stake_pool, _delegate_representative) -> @"DelegateBoth"
    },
  )
}

// ## Governance Fuzzers

// ## Transaction Fuzzers

test testing_datum_fuzzer_distribution(
  datum via datum_fuzzer(
    when_datum_hash: data_hash_fuzzer(),
    when_inline_datum: data_fuzzer(),
  ),
) {
  //   print("datum", datum)
  fuzz.label(
    when datum is {
      DatumHash(_data_hash) -> @"DatumHash"
      InlineDatum(_data) -> @"InlineDatum"
      NoDatum -> @"NoDatum"
    },
  )
}

fn test_specified_data_hash_datum_when_datum_hash_fuzzer() -> Fuzzer<
  (DataHash, transaction.Datum),
> {
  let (data, data_hash) <- fuzz.and_then(data_hash_fuzzer())

  let datum <-
    fuzz.map(
      datum_fuzzer(
        when_datum_hash: (data, data_hash) |> fuzz.constant,
        when_inline_datum: data_fuzzer(),
      ),
    )
  (data_hash, datum)
}

test testing_specified_data_hash_datum_when_datum_hash_fuzzer(
  (data_hash, datum) via test_specified_data_hash_datum_when_datum_hash_fuzzer(),
) {
  when datum is {
    DatumHash(hash) -> data_hash == hash
    _ -> True
  }
}

fn test_specified_data_datum_when_inline_datum_fuzzer() -> Fuzzer<
  (Data, transaction.Datum),
> {
  let data <- fuzz.and_then(data_fuzzer())

  let datum <-
    fuzz.map(
      datum_fuzzer(
        when_datum_hash: data_hash_fuzzer(),
        when_inline_datum: data |> fuzz.constant,
      ),
    )
  (data, datum)
}

test testing_specified_data_datum_when_inline_datum_fuzzer(
  (inline_data, datum) via test_specified_data_datum_when_inline_datum_fuzzer(),
) {
  when datum is {
    InlineDatum(inline) -> inline == inline_data
    _ -> True
  }
}

fn test_specified_both_data_datum_when_inline_or_hash_fuzzer() -> Fuzzer<
  (DataHash, Data, transaction.Datum),
> {
  let (data, data_hash) <- fuzz.and_then(data_hash_fuzzer())

  let datum <-
    fuzz.map(
      datum_fuzzer(
        when_datum_hash: (data, data_hash) |> fuzz.constant,
        when_inline_datum: data |> fuzz.constant,
      ),
    )
  (data_hash, data, datum)
}

test testing_specified_both_data_datum_when_inline_or_hash_fuzzer(
  (data_hash, inline_data, datum) via test_specified_both_data_datum_when_inline_or_hash_fuzzer(),
) {
  when datum is {
    DatumHash(hash) -> data_hash == hash
    InlineDatum(inline) -> inline == inline_data
    _ -> True
  }
}

fn test_blake2b_224_fuzzer() -> Fuzzer<
  (Int, List<crypto.Hash<Blake2b_224, ByteArray>>),
> {
  let count <- fuzz.and_then(fuzz.int_between(1, 10))

  let blake2b_224s <- fuzz.map(blake2b_224_fuzzer(count))
  (count, blake2b_224s)
}

test testing_blake2b_224_fuzzer(
  (count, blake2b_224s) via test_blake2b_224_fuzzer(),
) {
  //   expect [blake2b_224, ..] = blake2b_224s
  //   "Blake2b-224" |> print(blake2b_224)

  ( blake2b_224s |> list.unique |> list.length ) == count
}

fn test_blake2b_256_fuzzer() -> Fuzzer<
  (Int, List<crypto.Hash<Blake2b_256, ByteArray>>),
> {
  let count <- fuzz.and_then(fuzz.int_between(1, 10))

  let blake2b_256s <- fuzz.map(blake2b_256_fuzzer(count))
  (count, blake2b_256s)
}

test testing_blake2b_256_fuzzer(
  (count, blake2b_256s) via test_blake2b_256_fuzzer(),
) {
  //   expect [blake2b_256, ..] = blake2b_256s
  //   "Blake2b-256" |> print(blake2b_256)

  ( blake2b_256s |> list.unique |> list.length ) == count
}

// ### Output Reference Fuzzer

fn test_output_reference(
  OutputReference { transaction_id, output_index },
) -> Bool {
  and {
    bytearray.length(transaction_id) == 32,
    output_index >= 0 && output_index <= 512,
  }
}

test testing_output_reference_fuzzer(o_ref via output_reference_fuzzer()) {
  //   print("OutputReference", o_ref)
  o_ref |> test_output_reference
}

// ### Transaction Output Fuzzers

fn test_user_output(utxo: transaction.Output) -> Bool {
  let transaction.Output(
    Address(payment_credential, stake_credential),
    value,
    datum,
    reference_script,
  ) = utxo

  // check address
  expect VerificationKey(_payment_key_hash) = payment_credential
  expect Some(address.Inline(VerificationKey(_stake_key_hash))) =
    stake_credential

  // check value
  let policies = value |> assets.policies |> list.length
  expect policies >= 1 && policies <= 1 + 10
  expect assets.lovelace_of(value) >= 2_000_000
  expect {
    let (_policy_id, _token_name, quantity) <- list.all(value |> assets.flatten)
    quantity > 0
  }

  // check datum and reference script
  datum == NoDatum && reference_script == None
}

test testing_user_output_fuzzer(utxo via user_output_fuzzer()) {
  utxo |> test_user_output
}

test testing_user_outputs_fuzzer(utxos via user_outputs_fuzzer()) {
  let utxos_length = utxos |> list.length
  expect utxos_length >= 1 && utxos_length <= 10

  let utxo <- list.all(utxos)
  utxo |> test_user_output
}

fn test_script_output(
  script_hash: ScriptHash,
  datum: transaction.Datum,
  utxo: transaction.Output,
) -> Bool {
  // check address
  expect utxo.address == address.from_script(script_hash)

  // check value
  let policies = utxo.value |> assets.policies |> list.length
  expect policies >= 1 && policies <= 1 + 10
  expect assets.lovelace_of(utxo.value) >= 2_000_000
  expect {
    let (_policy_id, _token_name, quantity) <-
      list.all(utxo.value |> assets.flatten)
    quantity > 0
  }

  // check datum and reference script
  utxo.datum == datum && utxo.reference_script == None
}

fn test_specific_script_output_fuzzer() -> Fuzzer<
  (ScriptHash, transaction.Datum, transaction.Output),
> {
  let script_hash <- fuzz.and_then(script_hash_fuzzer())
  let datum <-
    fuzz.and_then(
      datum_fuzzer(
        when_datum_hash: data_hash_fuzzer(),
        when_inline_datum: data_fuzzer(),
      ),
    )

  let utxo <- fuzz.map(specific_script_output_fuzzer(script_hash, datum))
  (script_hash, datum, utxo)
}

test testing_specific_script_output_fuzzer(
  (script_hash, datum, utxo) via test_specific_script_output_fuzzer(),
) {
  test_script_output(script_hash, datum, utxo)
}

fn test_script_output_fuzzer(
  fuzzer: fn(transaction.Datum) -> Fuzzer<(ScriptHash, transaction.Output)>,
) -> Fuzzer<(ScriptHash, transaction.Datum, transaction.Output)> {
  let datum <-
    fuzz.and_then(
      datum_fuzzer(
        when_datum_hash: data_hash_fuzzer(),
        when_inline_datum: data_fuzzer(),
      ),
    )

  let (script_hash, utxo) <- fuzz.map(fuzzer(datum))
  (script_hash, datum, utxo)
}

test testing_script_output_fuzzer(
  (script_hash, datum, utxo) via test_script_output_fuzzer(script_output_fuzzer),
) {
  test_script_output(script_hash, datum, utxo)
}

fn test_authentic_script_output(
  script_hash: ScriptHash,
  datum: transaction.Datum,
  utxo: transaction.Output,
) -> Bool {
  // check address
  expect utxo.address == address.from_script(script_hash)

  // check value
  let policies = utxo.value |> assets.policies |> list.length
  expect 2 = policies
  expect 2_000_000 = assets.lovelace_of(utxo.value)
  expect [(policy_id, _token_name, quantity)] =
    utxo.value |> assets.without_lovelace |> assets.flatten
  expect policy_id == script_hash && quantity == 1

  // check datum and reference script
  utxo.datum == datum && utxo.reference_script == None
}

test testing_authentic_script_output_fuzzer(
  (script_hash, datum, utxo) via test_script_output_fuzzer(
    authentic_script_output_fuzzer,
  ),
) {
  test_authentic_script_output(script_hash, datum, utxo)
}

// ### Transaction Input Fuzzers

fn test_user_input(in: transaction.Input) -> Bool {
  let transaction.Input(o_ref, utxo) = in
  and {
    o_ref |> test_output_reference,
    utxo |> test_user_output,
  }
}

test testing_user_input_fuzzer(in via user_input_fuzzer()) {
  //   print("Transaction.input", in)
  in |> test_user_input
}

test testing_user_inputs_fuzzer(ins via user_inputs_fuzzer()) {
  let ins_length = ins |> list.length
  expect ins_length >= 1 && ins_length <= 10

  let in <- list.all(ins)
  in |> test_user_input
}

fn test_script_input(
  script_hash: ScriptHash,
  datum: transaction.Datum,
  in: transaction.Input,
) -> Bool {
  let transaction.Input(o_ref, utxo) = in
  and {
    test_output_reference(o_ref),
    test_script_output(script_hash, datum, utxo),
  }
}

fn test_specific_script_input_fuzzer() -> Fuzzer<
  (ScriptHash, transaction.Datum, transaction.Input),
> {
  let script_hash <- fuzz.and_then(script_hash_fuzzer())
  let datum <-
    fuzz.and_then(
      datum_fuzzer(
        when_datum_hash: data_hash_fuzzer(),
        when_inline_datum: data_fuzzer(),
      ),
    )

  let in <- fuzz.map(specific_script_input_fuzzer(script_hash, datum))
  (script_hash, datum, in)
}

test testing_specific_script_input_fuzzer(
  (script_hash, datum, in) via test_specific_script_input_fuzzer(),
) {
  test_script_input(script_hash, datum, in)
}

fn test_script_input_fuzzer(
  fuzzer: fn(transaction.Datum) -> Fuzzer<(ScriptHash, transaction.Input)>,
) -> Fuzzer<(ScriptHash, transaction.Datum, transaction.Input)> {
  let datum <-
    fuzz.and_then(
      datum_fuzzer(
        when_datum_hash: data_hash_fuzzer(),
        when_inline_datum: data_fuzzer(),
      ),
    )

  let (script_hash, script_input) <- fuzz.map(fuzzer(datum))
  (script_hash, datum, script_input)
}

test testing_script_input_fuzzer(
  (script_hash, datum, script_input) via test_script_input_fuzzer(
    script_input_fuzzer,
  ),
) {
  test_script_input(script_hash, datum, script_input)
}

fn test_authentic_script_input(
  script_hash: ScriptHash,
  datum: transaction.Datum,
  script_input: transaction.Input,
) -> Bool {
  let transaction.Input(o_ref, utxo) = script_input
  and {
    test_output_reference(o_ref),
    test_authentic_script_output(script_hash, datum, utxo),
  }
}

test testing_authentic_script_input_fuzzer(
  (script_hash, datum, script_input) via test_script_input_fuzzer(
    authentic_script_input_fuzzer,
  ),
) {
  test_authentic_script_input(script_hash, datum, script_input)
}

fn test_inputs_with_an_authentic_script_input_fuzzer() -> Fuzzer<
  (ScriptHash, transaction.Datum, transaction.Input, List<transaction.Input>),
> {
  let datum <-
    fuzz.and_then(
      datum_fuzzer(
        when_datum_hash: data_hash_fuzzer(),
        when_inline_datum: data_fuzzer(),
      ),
    )

  let (script_hash, script_input, sorted_inputs) <-
    fuzz.map(inputs_with_an_authentic_script_input_fuzzer(datum))
  (script_hash, datum, script_input, sorted_inputs)
}

test testing_inputs_with_an_authentic_script_input_fuzzer(
  (script_hash, datum, script_input, sorted_inputs) via test_inputs_with_an_authentic_script_input_fuzzer(),
) {
  //   expect test_authentic_script_input(script_hash, datum, script_input)
  let in <- list.all(sorted_inputs)
  if in == script_input {
    test_authentic_script_input(script_hash, datum, script_input)
  } else {
    test_user_input(in)
  }
}
