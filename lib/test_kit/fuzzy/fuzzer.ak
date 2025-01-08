//// Copied from [Anastasia-Labs/aiken-design-patterns](https://github.com/Anastasia-Labs/aiken-design-patterns/blob/main/lib/aiken-design-patterns/utils.ak)
//// with a few additions that might be useful.

use aiken/cbor
use aiken/collection
use aiken/collection/list
use aiken/crypto.{
  Blake2b_224, Blake2b_256, DataHash, ScriptHash, VerificationKeyHash,
}
use aiken/fuzz
use cardano/address.{Address, VerificationKey}
use cardano/assets.{AssetName, PolicyId}
use cardano/certificate.{
  DelegateBlockProduction, DelegateBoth, DelegateRepresentative, DelegateVote,
  StakePoolId,
}
use cardano/governance.{GovernanceActionId}
use cardano/transaction.{OutputReference, TransactionId}
use cardano/transaction/output_reference
use hidden/aiken/stdlib/cardano/address/credential
use hidden/aiken/stdlib/cardano/certificate/d_rep
use hidden/aiken/stdlib/cardano/governance/voter
use hidden/aiken/stdlib/cardano/transaction/datum

/// Alias: [`StakePoolHash`](#StakePoolHash)
pub type CredentialHash {
  Specified(crypto.Hash<Blake2b_224, ByteArray>)
  Fuzzed
}

/// Used by:
/// - [`address_fuzzer`](#address_fuzzer) to determine the payment part of a generated address
/// - [`credential_fuzzer`](#credential_fuzzer) to determine the possible generated credential type
/// - [`delegate_representative_fuzzer`](#delegate_representative_fuzzer) to determine the possible generated registered dRep credential type
pub type FromCredential {
  /// Payment part from script with known or any credential hash.
  /// Usage examples,
  /// ```aiken
  /// address_fuzzer(FromScript(Specified("KNOWN_SCRIPT_HASH")), staking_part)
  /// address_fuzzer(FromScript(Fuzzed), staking_part)
  /// ```
  /// See [`WithDelegation`](#WithDelegation) for more info on how to set the rule for the staking part.
  FromScript(CredentialHash)

  /// Payment part from key with known or any credential hash.
  /// Usage examples,
  /// ```aiken
  /// address_fuzzer(FromKey(Specified("KNOWN_KEY_HASH")), staking_part)
  /// address_fuzzer(FromKey(Fuzzed), staking_part)
  /// ```
  /// See [`WithDelegation`](#WithDelegation) for more info on how to set the rule for the staking part.
  FromKey(CredentialHash)

  /// Payment part from script or key with `Fuzzed` `CredentialHash`.
  /// Usage example,
  /// ```aiken
  /// address_fuzzer(FromFuzzed, staking_part)
  /// ```
  /// See [`WithDelegation`](#WithDelegation) for more info on how to set the rule for the staking part.
  FromFuzzed
}

/// Used by [`address_fuzzer`](#address_fuzzer) to determine the staking part of a generated address.
pub type WithDelegation {
  /// Address generator with no staking part:
  /// ```aiken
  /// address_fuzzer(payment_part, WithNoDelegation)
  /// ```
  /// See [`FromCredential`](#FromCredential) for more info on how to set the rule for the payment part.
  WithNoDelegation

  /// Address generator with staking part from script with known or any credential hash:
  /// ```aiken
  /// address_fuzzer(payment_part, WithDelegationScript(Specified("KNOWN_SCRIPT_HASH")))
  /// address_fuzzer(payment_part, WithDelegationScript(Fuzzed))
  /// ```
  /// See [`FromCredential`](#FromCredential) for more info on how to set the rule for the payment part.
  WithDelegationScript(CredentialHash)

  /// Address generator with staking part from key with known or any credential hash:
  /// ```aiken
  /// address_fuzzer(payment_part, WithDelegationKey(Specified("KNOWN_KEY_HASH")))
  /// address_fuzzer(payment_part, WithDelegationKey(Fuzzed))
  /// ```
  /// See [`FromCredential`](#FromCredential) for more info on how to set the rule for the payment part.
  WithDelegationKey(CredentialHash)

  /// Address generator with staking part with the same credential as the payment part:
  /// ```aiken
  /// address_fuzzer(payment_part, WithTheSameDelegationScriptOrKey)
  /// ```
  ///
  /// Useful for generating multi-purpose validator addresses, because:
  /// - If the address payment credential is `Script`(`"CURRENT_SCRIPT_HASH"`), then `WithTheSameDelegationScriptOrKey`
  ///   will generate an address with delegation script hash `"CURRENT_SCRIPT_HASH"`
  /// - If the address payment credential is `VerificationKey`(`"CURRENT_SCRIPT_HASH"`), then `WithTheSameDelegationScriptOrKey`
  ///   will generate an address with delegation key hash `"CURRENT_SCRIPT_HASH"`
  ///
  /// ```aiken
  /// test multi_purpose_validator_addresses(multi_purpose_validator_address via address_fuzzer(FromScript(Fuzzed), WithTheSameDelegationScriptOrKey)) {
  ///   multi_purpose_validator_address |> cbor.diagnostic |> fuzz.label
  /// }
  /// ```
  ///
  /// See [`FromCredential`](#FromCredential) for more info on how to set the rule for the payment part.
  WithTheSameDelegationScriptOrKey

  /// Address generator with either `NoDelegation` | `Fuzzed` `DelegationScript` | `Fuzzed` `DelegationKey` | `TheSameDelegationScriptOrKey`
  /// staking part:
  /// ```aiken
  /// address_fuzzer(payment_part, WithFuzzedDelegation)
  /// ```
  /// See [`FromCredential`](#FromCredential) for more info on how to set the rule for the payment part.
  WithFuzzedDelegation
}

// Certificate Fuzzer Types

pub type StakePoolHash =
  CredentialHash

/// Used by [`delegate_fuzzer`](#delegate_fuzzer) to determine the dRep type when the generated
/// [`Delegate`](https://aiken-lang.github.io/stdlib/cardano/certificate.html#Delegate) is either:
/// - `DelegateVote`([`DelegateRepresentative`](https://aiken-lang.github.io/stdlib/cardano/certificate.html#DelegateRepresentative))
/// - `DelegateBoth`([`StakePoolId`](https://aiken-lang.github.io/stdlib/cardano/certificate.html#StakePoolId),
///   [`DelegateRepresentative`](https://aiken-lang.github.io/stdlib/cardano/certificate.html#DelegateRepresentative))
pub type VoteDelegateRepresentative {
  VoteRegistered(FromCredential)
  VoteAlwaysAbstain
  VoteAlwaysNoConfidence
  VoteFuzzed
}

// ## Address Fuzzers

/// An [`Address`](https://aiken-lang.github.io/stdlib/cardano/address.html#Address) fuzzer.
/// See [`FromCredential`](#FromCredential) and [`WithDelegation`](#WithDelegation)
/// for more information and usage examples.
pub fn address_fuzzer(
  from: FromCredential,
  with_delegation: WithDelegation,
) -> Fuzzer<Address> {
  let address_fuzzer_from_script =
    fn(script: CredentialHash) {
      when script is {
        Specified(script_hash) ->
          address.from_script(script_hash) |> fuzz.constant
        Fuzzed -> {
          let script_hash <- fuzz.map(script_hash_fuzzer())
          address.from_script(script_hash)
        }
      }
    }
  let address_fuzzer_from_key =
    fn(key: CredentialHash) {
      when key is {
        Specified(verification_key_hash) ->
          address.from_verification_key(verification_key_hash)
            |> fuzz.constant
        Fuzzed -> {
          let verification_key_hash <- fuzz.map(verification_key_hash_fuzzer())
          address.from_verification_key(verification_key_hash)
        }
      }
    }

  let address_fuzzer_with_delegation_script =
    fn(address_fuzzer: Fuzzer<Address>, delegation_script: CredentialHash) {
      when delegation_script is {
        Specified(s) -> {
          let p <- fuzz.map(address_fuzzer)
          p |> address.with_delegation_script(s)
        }
        Fuzzed -> {
          let p, s <- fuzz.map2(address_fuzzer, script_hash_fuzzer())
          p |> address.with_delegation_script(s)
        }
      }
    }
  let address_fuzzer_with_delegation_key =
    fn(address_fuzzer: Fuzzer<Address>, delegation_key: CredentialHash) {
      when delegation_key is {
        Specified(s) -> {
          let p <- fuzz.map(address_fuzzer)
          p |> address.with_delegation_key(s)
        }
        Fuzzed -> {
          let p, s <- fuzz.map2(address_fuzzer, verification_key_hash_fuzzer())
          p |> address.with_delegation_key(s)
        }
      }
    }
  let address_fuzzer_with_the_same_delegation_script_or_key =
    fn(address_fuzzer: Fuzzer<Address>) {
      let p <- fuzz.map(address_fuzzer)
      when p.payment_credential is {
        address.Script(s) -> p |> address.with_delegation_script(s)
        VerificationKey(s) -> p |> address.with_delegation_key(s)
      }
    }

  let p =
    when from is {
      FromScript(credential_hash) -> address_fuzzer_from_script(credential_hash)
      FromKey(credential_hash) -> address_fuzzer_from_key(credential_hash)
      FromFuzzed ->
        fuzz.either(
          Fuzzed |> address_fuzzer_from_script,
          Fuzzed |> address_fuzzer_from_key,
        )
    }
  when with_delegation is {
    WithNoDelegation -> p
    WithDelegationScript(credential_hash) ->
      p |> address_fuzzer_with_delegation_script(credential_hash)
    WithDelegationKey(credential_hash) ->
      p |> address_fuzzer_with_delegation_key(credential_hash)
    WithTheSameDelegationScriptOrKey ->
      p |> address_fuzzer_with_the_same_delegation_script_or_key()
    WithFuzzedDelegation ->
      fuzz.either4(
        p,
        p |> address_fuzzer_with_delegation_script(Fuzzed),
        p |> address_fuzzer_with_delegation_key(Fuzzed),
        p |> address_fuzzer_with_the_same_delegation_script_or_key(),
      )
  }
}

/// Fuzzes either `Script` or `VerificationKey` credentials determined by [`FromCredential`](#FromCredential)
/// ```aiken
/// credential_fuzzer(FromScript(Fuzzed))
/// credential_fuzzer(FromKey(Fuzzed))
/// credential_fuzzer(FromFuzzed)
/// ```
/// `FromScript` and `FromKey` with `Specified` [`CredentialHash`](#CredentialHash) are also supported
/// but most of the time there's no reason to use a fuzzer for a known credential type and hash.
pub fn credential_fuzzer(from: FromCredential) -> Fuzzer<address.Credential> {
  when from is {
    FromScript(credential) -> {
      let script_hash <-
        fuzz.map(
          when credential is {
            Specified(hash) -> hash |> fuzz.constant
            Fuzzed -> script_hash_fuzzer()
          },
        )
      script_hash |> credential.to_script
    }

    FromKey(credential) -> {
      let verification_key_hash <-
        fuzz.map(
          when credential is {
            Specified(hash) -> hash |> fuzz.constant
            Fuzzed -> verification_key_hash_fuzzer()
          },
        )
      verification_key_hash |> credential.to_verification_key
    }

    FromFuzzed ->
      fuzz.either(
        {
          let script_hash <- fuzz.map(script_hash_fuzzer())
          script_hash |> credential.to_script
        },
        {
          let verification_key_hash <- fuzz.map(verification_key_hash_fuzzer())
          verification_key_hash |> credential.to_verification_key
        },
      )
  }
}

/// Script Hash with 28 bytes fuzzer.
pub fn script_hash_fuzzer() -> Fuzzer<ScriptHash> {
  fuzz.bytearray_fixed(28)
}

/// Verification Key Hash with 28 bytes fuzzer.
pub fn verification_key_hash_fuzzer() -> Fuzzer<VerificationKeyHash> {
  fuzz.bytearray_fixed(28)
}

// ## Asset Fuzzers

/// Policy ID with 28 bytes fuzzer.
pub fn policy_id_fuzzer() -> Fuzzer<PolicyId> {
  fuzz.bytearray_fixed(28)
}

/// Asset Name with 0-32 bytes fuzzer.
pub fn asset_name_fuzzer() -> Fuzzer<AssetName> {
  fuzz.bytearray_between(0, 32)
}

/// A [`Value`](https://aiken-lang.github.io/stdlib/cardano/assets.html#Value) fuzzer,
/// guaranteed to include some amount of ADA (minimum must be specified)
///
/// Fuzzes a list of assets with some ADA with quantity of at least as the specified minimum amount, and 0-10 tokens:
/// ```aiken
/// assets.from_asset_list([
///   Pair("", [Pair("", lovelace_count)]),
///   ..,
///   Pair(policy_id, [Pair(token_name, quantity), ..])
/// ])
/// ```
/// Where,
/// - `lovelace_count` `<-` [`fuzz.int_at_least`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#int_at_least)`(min_lovelaces)`
/// - `policy_id` `<-` [`policy_id_fuzzer`](#policy_id_fuzzer)`()`
/// - `token_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `quantity` `<-` [`fuzz.int_at_least`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#int_at_least)`(1)`
pub fn value_fuzzer(min_lovelaces: assets.Lovelace) -> Fuzzer<assets.Value> {
  let lovelace_count <- fuzz.and_then(fuzz.int_at_least(min_lovelaces))
  let lovelace_value = assets.from_lovelace(lovelace_count)

  let other_assets_values <-
    fuzz.map(fuzz.list_at_most(single_asset_value_fuzzer(), 10))
  other_assets_values |> list.foldl(lovelace_value, assets.merge)
}

/// A [`Value`](https://aiken-lang.github.io/stdlib/cardano/assets.html#Value) fuzzer with a single asset.
/// Randomly generates the Policy ID.
///
/// Fuzzes the following token:
/// ```aiken
/// policy_id |> assets.from_asset(token_name, quantity)
/// ```
/// Where,
/// - `policy_id` `<-` [`policy_id_fuzzer`](#policy_id_fuzzer)`()`
/// - `token_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `quantity` `<-` [`fuzz.int_at_least`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#int_at_least)`(1)`
pub fn single_asset_value_fuzzer() -> Fuzzer<assets.Value> {
  policy_id_fuzzer() |> fuzz.and_then(single_specific_asset_value_fuzzer)
}

/// A fuzzer for [`Value`](https://aiken-lang.github.io/stdlib/cardano/assets.html#Value) with a single asset.
/// Unsafely expects 28 bytes long Policy ID to be provided.
///
/// Fuzzes the following token:
/// ```aiken
/// policy_id |> assets.from_asset(token_name, quantity)
/// ```
/// Where,
/// - `token_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `quantity` `<-` [`fuzz.int_at_least`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#int_at_least)`(1)`
pub fn single_specific_asset_value_fuzzer(
  policy_id: PolicyId,
) -> Fuzzer<assets.Value> {
  let
    token_name: AssetName,
    quantity: Int,
  <- fuzz.map2(asset_name_fuzzer(), fuzz.int_at_least(1))

  policy_id |> assets.from_asset(token_name, quantity)
}

/// A [`Value`](https://aiken-lang.github.io/stdlib/cardano/assets.html#Value) fuzzer without any lovelaces.
///
/// Fuzzes 1-10 tokens:
/// ```aiken
/// assets.from_asset_list([
///   Pair(policy_id, [Pair(token_name, quantity), ..])
///   ..,
/// ])
/// ```
/// Where,
/// - `policy_id` `<-` [`policy_id_fuzzer`](#policy_id_fuzzer)`()`
/// - `token_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `quantity` `<-` [`fuzz.int_at_least`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#int_at_least)`(1)`
pub fn mint_fuzzer() -> Fuzzer<assets.Value> {
  let other_assets_values <-
    fuzz.map(fuzz.list_between(single_asset_value_fuzzer(), 1, 10))
  other_assets_values |> list.foldl(assets.zero, assets.merge)
}

// ## Certificate Fuzzers

/// Stake Pool ID with 28 bytes fuzzer.
pub fn stake_pool_id_fuzzer() -> Fuzzer<StakePoolId> {
  fuzz.bytearray_fixed(28)
}

/// Fuzzes either `Registered`([`FromCredential`](#FromCredential)) | `AlwaysAbstain` | `AlwaysNoConfidence`
/// ```aiken
/// // Fuzzes either:
/// // - Registered("KNOWN_SCRIPT_HASH" |> Script)
/// // - AlwaysAbstain
/// // - AlwaysNoConfidence
/// delegate_representative_fuzzer(when_registered: FromScript(Specified("KNOWN_SCRIPT_HASH")))
/// 
/// // Fuzzes either:
/// // - Registered(Any Script)
/// // - AlwaysAbstain
/// // - AlwaysNoConfidence
/// delegate_representative_fuzzer(when_registered: FromScript(Fuzzed))
/// 
/// // Fuzzes either:
/// // - Registered("KNOWN_KEY_HASH" |> VerificationKey)
/// // - AlwaysAbstain
/// // - AlwaysNoConfidence
/// delegate_representative_fuzzer(when_registered: FromKey(Specified("KNOWN_KEY_HASH")))
/// 
/// // Fuzzes either:
/// // - Registered(Any VerificationKey)
/// // - AlwaysAbstain
/// // - AlwaysNoConfidence
/// delegate_representative_fuzzer(when_registered: FromKey(Fuzzed))
/// 
/// // Fuzzes either:
/// // - Registered(Any Script or Any VerificationKey)
/// // - AlwaysAbstain
/// // - AlwaysNoConfidence
/// delegate_representative_fuzzer(when_registered: FromFuzzed)
/// ```
pub fn delegate_representative_fuzzer(
  when_registered: FromCredential,
) -> Fuzzer<DelegateRepresentative> {
  fuzz.either3(
    {
      let credential <- fuzz.map(credential_fuzzer(when_registered))
      credential |> d_rep.to_registered
    },
    d_rep.always_abstain |> fuzz.constant,
    d_rep.always_no_confidence |> fuzz.constant,
  )
}

/// Fuzzes either:
/// - `DelegateBlockProduction`([`StakePoolHash`](#StakePoolHash))
/// - `DelegateVote`([`VoteDelegateRepresentative`](#VoteDelegateRepresentative))
/// - `DelegateBoth`([`StakePoolHash`](#StakePoolHash), [`VoteDelegateRepresentative`](#VoteDelegateRepresentative))
pub fn delegate_fuzzer(
  when_block_production: StakePoolHash,
  when_vote: VoteDelegateRepresentative,
  when_both: (StakePoolHash, VoteDelegateRepresentative),
) -> Fuzzer<certificate.Delegate> {
  let fuzz_block_production =
    fn(block_production_stake_pool) {
      let stake_pool_id <-
        fuzz.map(
          when block_production_stake_pool is {
            Specified(stake_pool_id) -> stake_pool_id |> fuzz.constant
            Fuzzed -> stake_pool_id_fuzzer()
          },
        )
      DelegateBlockProduction(stake_pool_id)
    }
  let fuzz_vote =
    fn(vote_delegate_representative) {
      let delegate_representative <-
        fuzz.map(
          when vote_delegate_representative is {
            VoteRegistered(when_registered) -> {
              let credential <- fuzz.map(credential_fuzzer(when_registered))
              credential |> d_rep.to_registered
            }
            VoteAlwaysAbstain -> fuzz.constant(d_rep.always_abstain)
            VoteAlwaysNoConfidence -> fuzz.constant(d_rep.always_no_confidence)
            VoteFuzzed -> delegate_representative_fuzzer(FromFuzzed)
          },
        )
      DelegateVote(delegate_representative)
    }
  let fuzz_both =
    fn((block_production_stake_pool, vote_delegate_representative)) {
      expect
        DelegateBlockProduction(stake_pool),
        DelegateVote(delegate_representative),
      <-
        fuzz.map2(
          fuzz_block_production(block_production_stake_pool),
          fuzz_vote(vote_delegate_representative),
        )
      DelegateBoth(stake_pool, delegate_representative)
    }

  fuzz.either3(
    when_block_production |> fuzz_block_production,
    when_vote |> fuzz_vote,
    when_both |> fuzz_both,
  )
}

// ## Governance Fuzzers

/// Fuzzes a [`Constitution`](https://aiken-lang.github.io/stdlib/cardano/governance.html#Constitution)
/// with either `Some`(`"KNOWN_SCRIPT_HASH"` | `Any Script Hash`) or `None`
/// ```aiken
/// // Fuzzes either:
/// // - Constitution(Some("KNOWN_SCRIPT_HASH" |> Script))
/// // - Constitution(None)
/// constitution_fuzzer(some_guardrails: Specified("KNOWN_SCRIPT_HASH"))
/// 
/// // Fuzzes either:
/// // - Constitution(Some(Any Script Hash))
/// // - Constitution(None)
/// constitution_fuzzer(some_guardrails: Fuzzed)
/// ```
pub fn constitution_fuzzer(some_guardrails: CredentialHash) {
  let guardrails <-
    fuzz.map(
      fuzz.option(
        when some_guardrails is {
          Specified(script_hash) -> script_hash |> fuzz.constant
          Fuzzed -> script_hash_fuzzer()
        },
      ),
    )
  governance.Constitution(guardrails)
}

/// Governance Action ID fuzzer,
/// Transaction ID with 32 bytes,
/// and output index between 0 and 512.
pub fn governance_action_id_fuzzer() -> Fuzzer<GovernanceActionId> {
  let
    transaction_id: TransactionId,
    action_index: collection.Index,
  <- fuzz.map2(transaction_id_fuzzer(), fuzz.int_between(0, 512))

  GovernanceActionId(transaction_id, action_index)
}

/// Fuzzes either `Yes` | `No` | `Abstain`
pub fn vote_fuzzer() {
  fuzz.either3(
    governance.Yes |> fuzz.constant,
    governance.No |> fuzz.constant,
    governance.Abstain |> fuzz.constant,
  )
}

/// Fuzzes either:
/// - `ConstitutionalCommitteeMember`([`FromCredential`](#FromCredential))
/// - `DelegateRepresentative`([`FromCredential`](#FromCredential))
/// - `StakePool`([`StakePoolHash`](#StakePoolHash))
pub fn voter_fuzzer(
  when_constitutional_committee_member: FromCredential,
  when_delegate_representative: FromCredential,
  when_stake_pool: StakePoolHash,
) {
  let fuzz_constitutional_committee_member =
    fn(constitutional_committee_member_credential) {
      let credential <-
        fuzz.map(credential_fuzzer(constitutional_committee_member_credential))
      credential |> voter.to_constitutional_committee_member
    }
  let fuzz_delegate_representative =
    fn(delegate_representative_credential) {
      let credential <-
        fuzz.map(credential_fuzzer(delegate_representative_credential))
      credential |> voter.to_delegate_representative
    }
  let fuzz_stake_pool =
    fn(stake_pool) {
      let stake_pool_id <-
        fuzz.map(
          when stake_pool is {
            Specified(stake_pool_id) -> stake_pool_id |> fuzz.constant
            Fuzzed -> stake_pool_id_fuzzer()
          },
        )
      stake_pool_id |> voter.to_stake_pool
    }

  fuzz.either3(
    when_constitutional_committee_member |> fuzz_constitutional_committee_member,
    when_delegate_representative |> fuzz_delegate_representative,
    when_stake_pool |> fuzz_stake_pool,
  )
}

// ## Transaction Fuzzers

/// Fuzzes either `DatumHash`(`data_hash`) | `InlineDatum`(`data`) | `NoDatum`
/// ```aiken
/// // Fuzzes either:
/// // - DatumHash(Any DataHash)
/// // - InlineDatum(Any Data)
/// // - NoDatum
/// datum_fuzzer(when_datum_hash: data_hash_fuzzer(), when_inline_datum: data_fuzzer())
/// 
/// // Fuzzes either:
/// // - DatumHash(Known DataHash)
/// // - InlineDatum(Any Data)
/// // - NoDatum
/// datum_fuzzer(when_datum_hash: (known_data, "KNOWN_DATA_HASH") |> fuzz.constant, when_inline_datum: data_fuzzer())
/// 
/// // Fuzzes either:
/// // - DatumHash(Any DataHash)
/// // - InlineDatum(Known Data)
/// // - NoDatum
/// datum_fuzzer(when_datum_hash: data_hash_fuzzer(), when_inline_datum: known_data |> fuzz.constant)
/// 
/// // Fuzzes either:
/// // - DatumHash(Known DataHash)
/// // - InlineDatum(Known Data)
/// // - NoDatum
/// datum_fuzzer(when_datum_hash: (known_data, "KNOWN_DATA_HASH") |> fuzz.constant, when_inline_datum: known_data |> fuzz.constant)
/// ```
/// See also:
/// - [`data_hash_fuzzer`](#data_hash_fuzzer)`()`
/// - [`data_fuzzer`](#data_fuzzer)`()`
pub fn datum_fuzzer(
  when_datum_hash: Fuzzer<(Data, DataHash)>,
  when_inline_datum: Fuzzer<Data>,
) -> Fuzzer<transaction.Datum> {
  fuzz.either3(
    {
      let (_, data_hash) <- fuzz.map(when_datum_hash)
      data_hash |> datum.to_datum_hash
    },
    {
      let data <- fuzz.map(when_inline_datum)
      data |> datum.to_inline_datum
    },
    datum.no_datum |> fuzz.constant,
  )
}

/// Data Hash with Blake2b-256 hash digest (32 bytes) of some `data` fuzzer.
///
/// Where,
/// - `data` `<-` [`data_fuzzer`](#data_fuzzer)`()`
///
/// Could be used as `DatumHash` fuzzer, see: [`datum_fuzzer`](#datum_fuzzer)
pub fn data_hash_fuzzer() -> Fuzzer<(Data, DataHash)> {
  let data <- fuzz.map(data_fuzzer())
  let data_hash = data |> cbor.serialise |> crypto.blake2b_256

  (data, data_hash)
}

/// Fuzzes either upcasted `Bool` | `Byte` | `ByteArray` | `Int`
///
/// Where,
/// |   Data                                                                     |   Possible Value    | Chance |
/// |----------------------------------------------------------------------------|---------------------|--------|
/// | [`Bool`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#bool)           |  `True` \| `False`  |    25% |
/// | [`Byte`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#byte)           |      `0`-`255`      |    25% |
/// | [`ByteArray`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#bytearray) | `"random 32 bytes"` |    25% |
/// | [`Int`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#int)             |   `-255`-`16383`    |    25% |
///
/// Could be used as `InlineDatum` fuzzer, see: [`datum_fuzzer`](#datum_fuzzer)
pub fn data_fuzzer() -> Fuzzer<Data> {
  fuzz.either4(
    {
      let bool <- fuzz.map(fuzz.bool())
      let data: Data = bool
      data
    },
    {
      let byte <- fuzz.map(fuzz.byte())
      let data: Data = byte
      data
    },
    {
      let bytearray <- fuzz.map(fuzz.bytearray())
      let data: Data = bytearray
      data
    },
    {
      let int <- fuzz.map(fuzz.int())
      let data: Data = int
      data
    },
  )
}

/// Blake2b-224 fuzzer with `n` unique count.
pub fn blake2b_224_fuzzer(
  count n: Int,
) -> Fuzzer<List<crypto.Hash<Blake2b_224, ByteArray>>> {
  28 |> fuzz.bytearray_fixed |> fuzz.set_between(n, n)
}

/// Blake2b-256 fuzzer with `n` unique count.
pub fn blake2b_256_fuzzer(
  count n: Int,
) -> Fuzzer<List<crypto.Hash<Blake2b_256, ByteArray>>> {
  32 |> fuzz.bytearray_fixed |> fuzz.set_between(n, n)
}

// ### Output Reference Fuzzers

/// Output Reference fuzzer,
/// Transaction ID with 32 bytes,
/// and output index between 0 and 512.
pub fn output_reference_fuzzer() -> Fuzzer<OutputReference> {
  let
    transaction_id: TransactionId,
    output_index: collection.Index,
  <- fuzz.map2(transaction_id_fuzzer(), fuzz.int_between(0, 512))

  OutputReference(transaction_id, output_index)
}

/// Transaction ID with 32 bytes fuzzer.
pub fn transaction_id_fuzzer() -> Fuzzer<TransactionId> {
  fuzz.bytearray_fixed(32)
}

// ### Transaction Output Fuzzers

/// Simple wallet UTxO fuzzer,
/// with a random number of tokens/NFTs.
///
/// Fuzzes the following UTxO:
/// ```aiken
/// transaction.Output {
///   address: Address(Fuzzed |> FromKey, Fuzzed |> WithDelegationKey),
///   value: 2 or more ADA and 0-10 tokens/NFTs,
///   datum: NoDatum,
///   reference_script: None,
/// }
/// ```
pub fn user_output_fuzzer() -> Fuzzer<transaction.Output> {
  let
    address: Address,
    value: assets.Value,
  <-
    fuzz.map2(
      address_fuzzer(Fuzzed |> FromKey, Fuzzed |> WithDelegationKey),
      value_fuzzer(2_000_000),
    )
  transaction.Output(address, value, datum.no_datum, None)
}

/// Simple (non-script) outputs fuzzer.
///
/// Fuzzes a list between 1-10 elements of the following UTxO:
/// ```aiken
/// transaction.Output {
///   address: Address(Fuzzed |> FromKey, Fuzzed |> WithDelegationKey),
///   value: 2 or more ADA and 0-10 tokens/NFTs,
///   datum: NoDatum,
///   reference_script: None,
/// }
/// ```
pub fn user_outputs_fuzzer() -> Fuzzer<List<transaction.Output>> {
  user_output_fuzzer() |> fuzz.list_between(1, 10)
}

/// Given a script hash and datum,
/// this fuzzer generates a UTxO at an address which its payment part is the same as the given script hash.
///
/// Fuzzes the following UTxO:
/// ```aiken
/// transaction.Output {
///   address: from_script(script_hash),
///   value: 2 or more ADA and 0-10 tokens/NFTs,
///   datum: transaction.Datum,
///   reference_script: None,
/// }
/// ```
pub fn specific_script_output_fuzzer(
  script_hash: ScriptHash,
  datum: transaction.Datum,
) -> Fuzzer<transaction.Output> {
  let value <- fuzz.map(value_fuzzer(2_000_000))
  transaction.Output {
    address: address.from_script(script_hash),
    value,
    datum,
    reference_script: None,
  }
}

/// Returns a tuple where its first element is the random script hash (payment part of the UTxO's address).
/// UTxO value is also random, with 2 ADA.
///
/// Fuzzes the following tuple:
/// ```aiken
/// (script_hash, utxo)
/// ```
/// Where,
/// - `script_hash` `<-` [`script_hash_fuzzer`](#script_hash_fuzzer)`()`
/// - `utxo` `<-` [`specific_script_output_fuzzer`](#specific_script_output_fuzzer)`(script_hash, datum)`
///   ```aiken
///   transaction.Output {
///     address: from_script(script_hash),
///     value: 2 or more ADA and 0-10 tokens/NFTs,
///     datum: transaction.Datum,
///     reference_script: None,
///   }
///   ```
pub fn script_output_fuzzer(
  datum: transaction.Datum,
) -> Fuzzer<(ScriptHash, transaction.Output)> {
  let script_hash <- fuzz.and_then(script_hash_fuzzer())
  let utxo <- fuzz.map(specific_script_output_fuzzer(script_hash, datum))
  (script_hash, utxo)
}

/// UTxO fuzzer, where the value is composed of 2 ADA and a Beacon NFT,
/// such that its Policy ID is equal to the script credential of the payment part of UTxO's address.
/// This script hash is also returned.
///
/// Fuzzes the following tuple:
/// ```aiken
/// (script_hash, utxo)
/// ```
/// Where,
/// - `policy_id: script_hash` `<-` [`script_hash_fuzzer`](#script_hash_fuzzer)`()`
/// - `asset_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `utxo` `=`
///   ```aiken
///   transaction.Output {
///     address: from_script(script_hash),
///     value: 2 ADA and a Beacon NFT (policy_id: script_hash, asset_name, quantity: 1),
///     datum,
///     reference_script: None,
///   }
///   ```
pub fn authentic_script_output_fuzzer(
  datum: transaction.Datum,
) -> Fuzzer<(ScriptHash, transaction.Output)> {
  let lovelace_value = assets.from_lovelace(2_000_000)

  let
    script_hash: ScriptHash,
    token_name: AssetName,
  <- fuzz.map2(script_hash_fuzzer(), asset_name_fuzzer())

  let beacon = assets.from_asset(script_hash, token_name, 1)
  let utxo =
    transaction.Output {
      address: address.from_script(script_hash),
      value: assets.merge(lovelace_value, beacon),
      datum,
      reference_script: None,
    }

  (script_hash, utxo)
}

// ### Transaction Input Fuzzers

/// Simple wallet UTxO fuzzer,
/// with a random reference output and a random number of tokens/NFTs.
///
/// Fuzzes the following Transaction Input:
/// ```aiken
/// transaction.Input(output_reference, output)
/// ```
/// Where,
/// - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
/// - `output` `<-` [`user_output_fuzzer`](#user_output_fuzzer)`()`
///   ```aiken
///   transaction.Output {
///     address: Address(Fuzzed |> FromKey, Fuzzed |> WithDelegationKey),
///     value: 2 or more ADA and 0-10 tokens/NFTs,
///     datum: NoDatum,
///     reference_script: None,
///   }
///   ```
pub fn user_input_fuzzer() -> Fuzzer<transaction.Input> {
  let
    output_reference: OutputReference,
    output: transaction.Output,
  <- fuzz.map2(output_reference_fuzzer(), user_output_fuzzer())

  transaction.Input(output_reference, output)
}

/// Simple (non-script) inputs fuzzer.
///
/// Fuzzes a list between 1-10 elements of the following Transaction Input:
/// ```aiken
/// transaction.Input(output_reference, output)
/// ```
/// Where,
/// - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
/// - `output` `<-` [`user_output_fuzzer`](#user_output_fuzzer)`()`
///   ```aiken
///   transaction.Output {
///     address: Address(Fuzzed |> FromKey, Fuzzed |> WithDelegationKey),
///     value: 2 or more ADA and 0-10 tokens/NFTs,
///     datum: NoDatum,
///     reference_script: None,
///   }
///   ```
pub fn user_inputs_fuzzer() -> Fuzzer<List<transaction.Input>> {
  user_input_fuzzer() |> fuzz.list_between(1, 10)
}

/// Similar to [`specific_script_output_fuzzer`](#specific_script_output_fuzzer),
/// with an additional randomized wrapper for output reference.
///
/// Fuzzes the following Transaction Input:
/// ```aiken
/// transaction.Input(output_reference, output)
/// ```
/// Where,
/// - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
/// - `output` `=`
///   ```aiken
///   transaction.Output {
///     address: from_script(script_hash),
///     value: 2 or more ADA and 0-10 tokens/NFTs,
///     datum: transaction.Datum,
///     reference_script: None,
///   }
///   ```
pub fn specific_script_input_fuzzer(
  script_hash: ScriptHash,
  datum: transaction.Datum,
) -> Fuzzer<transaction.Input> {
  let
    output_reference: OutputReference,
    output: transaction.Output,
  <-
    fuzz.map2(
      output_reference_fuzzer(),
      specific_script_output_fuzzer(script_hash, datum),
    )
  transaction.Input(output_reference, output)
}

/// Similar to [`script_output_fuzzer`](#script_output_fuzzer),
/// with an additional randomized wrapper for output reference.
///
/// Fuzzes the following tuple:
/// ```aiken
/// (script_hash, script_input)
/// ```
/// Where,
/// - `script_hash` `<-` [`script_hash_fuzzer`](#script_hash_fuzzer)`()`
/// - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
/// - `output` `<-` [`specific_script_output_fuzzer`](#specific_script_output_fuzzer)`(script_hash, datum)`
///   ```aiken
///   transaction.Output {
///     address: from_script(script_hash),
///     value: 2 or more ADA and 0-10 tokens/NFTs,
///     datum: transaction.Datum,
///     reference_script: None,
///   }
///   ```
/// - `script_input` `=`
///   ```aiken
///   transaction.Input(output_reference, output)
///   ```
pub fn script_input_fuzzer(
  datum: transaction.Datum,
) -> Fuzzer<(ScriptHash, transaction.Input)> {
  let
    output_reference: OutputReference,
    (script_hash, output),
  <- fuzz.map2(output_reference_fuzzer(), script_output_fuzzer(datum))

  let script_input = transaction.Input(output_reference, output)

  (script_hash, script_input)
}

/// Similar to [`authentic_script_output_fuzzer`](#authentic_script_output_fuzzer),
/// with and additional randomized wrapper for output reference.
///
/// Fuzzes the following tuple:
/// ```aiken
/// (script_hash, script_input)
/// ```
/// Where,
/// - `policy_id: script_hash` `<-` [`script_hash_fuzzer`](#script_hash_fuzzer)`()`
/// - `asset_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
/// - `output` `=`
///   ```aiken
///   transaction.Output {
///     address: from_script(script_hash),
///     value: 2 ADA and a Beacon NFT (policy_id: script_hash, asset_name, quantity: 1),
///     datum,
///     reference_script: None,
///   }
///   ```
/// - `script_input` `=`
///   ```aiken
///   transaction.Input(output_reference, output)
///   ```
pub fn authentic_script_input_fuzzer(
  datum: transaction.Datum,
) -> Fuzzer<(ScriptHash, transaction.Input)> {
  let
    output_reference: OutputReference,
    (script_hash, output),
  <- fuzz.map2(output_reference_fuzzer(), authentic_script_output_fuzzer(datum))

  let script_input = transaction.Input(output_reference, output)

  (script_hash, script_input)
}

/// Fuzzer for a sorted list of user/wallet inputs,
/// with the addition of one authentic script input.
///
/// Fuzzes the following tuple:
/// ```aiken
/// (script_hash, script_input, sorted_inputs)
/// ```
/// Where,
/// - `policy_id: script_hash` `<-` [`script_hash_fuzzer`](#script_hash_fuzzer)`()`
/// - `asset_name` `<-` [`asset_name_fuzzer`](#asset_name_fuzzer)`()`
/// - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
/// - `output` `=`
///   ```aiken
///   transaction.Output {
///     address: from_script(script_hash),
///     value: 2 ADA and a Beacon NFT (policy_id: script_hash, asset_name, quantity: 1),
///     datum,
///     reference_script: None,
///   }
///   ```
/// - `script_input` `=`
///   ```aiken
///   transaction.Input(output_reference, output)
///   ```
/// - `wallet_inputs` `<-` a list between 1-10 elements of `transaction.Input(output_reference, output)` where,
///     - `output_reference` `<-` [`output_reference_fuzzer`](#output_reference_fuzzer)`()`
///     - `output` `<-` [`user_output_fuzzer`](#user_output_fuzzer)`()`
///       ```aiken
///       transaction.Output {
///         address: Address(Fuzzed |> FromKey, Fuzzed |> WithDelegationKey),
///         value: 2 or more ADA and 0-10 tokens/NFTs,
///         datum: NoDatum,
///         reference_script: None,
///       }
///       ```
/// - `sorted_inputs` `=` `sorted_by_output_reference([script_input, ..wallet_inputs])`
pub fn inputs_with_an_authentic_script_input_fuzzer(
  datum: transaction.Datum,
) -> Fuzzer<(ScriptHash, transaction.Input, List<transaction.Input>)> {
  let sort_inputs =
    fn(transaction_inputs) {
      let
        transaction.Input(l_o_ref, _),
        transaction.Input(r_o_ref, _),
      <- list.sort(transaction_inputs)

      l_o_ref |> output_reference.compare(r_o_ref)
    }

  let
    wallet_inputs: List<transaction.Input>,
    (script_hash, script_input),
  <- fuzz.map2(user_inputs_fuzzer(), authentic_script_input_fuzzer(datum))

  let sorted_inputs = [script_input, ..wallet_inputs] |> sort_inputs

  (script_hash, script_input, sorted_inputs)
}
