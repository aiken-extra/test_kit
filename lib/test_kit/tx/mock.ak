//// A fancy way to construct mock hashes, such as:
//// - [`VerificationKeyHash`](https://aiken-lang.github.io/stdlib/aiken/crypto.html#VerificationKeyHash)
//// - [`ScriptHash`](https://aiken-lang.github.io/stdlib/aiken/crypto.html#ScriptHash)
//// - [`PolicyId`](https://aiken-lang.github.io/stdlib/cardano/assets.html#PolicyId)
//// - [`TransactionId`](https://aiken-lang.github.io/stdlib/cardano/transaction.html#TransactionId)
//// - and any other hashes
////
//// Usage examples:
//// ```aiken
//// // Mock Address:
//// let address_key = mock_address(1, False) // if 2nd arg is False | Void | [] | "" | 0, then there's no staking part
//// address_key == from_verification_key(#"00000000000000000000000000000000000000000000000000000001")
//// // use cardano/address.{from_verification_key}
////
//// // Mock Credential:
//// mock_verification_key_credential(2) == VerificationKey(#"00000000000000000000000000000000000000000000000000000002")
//// mock_script_credential(3) == Script(#"00000000000000000000000000000000000000000000000000000003")
//// // use cardano/address.{VerificationKey, Script}
//// (mock_verification_key_hash(4) |> VerificationKey) == VerificationKey(#"00000000000000000000000000000000000000000000000000000004")
//// (mock_script_hash(5) |> Script) == Script(#"00000000000000000000000000000000000000000000000000000005")
//// 
//// // Mock Asset:
//// let mint = mock_asset(6, "NFT", 1)
//// let burn = from_asset(mock_policy_id(6), "NFT", -1) // you can also only mock the Policy ID
//// mint
////   |> merge(burn)
////   |> is_zero() // True
//// // use cardano/assets.{from_asset, merge, is_zero}
//// 
//// // Mock Output Reference:
//// let o_ref = mock_output_reference(7, 0) // aliases: mock_out_ref, mock_o_ref
//// and {
////   o_ref == OutputReference(mock_transaction_id(7), 0), // you can also only mock the Transaction ID
////   o_ref == OutputReference {
////     transaction_id: #"0000000000000000000000000000000000000000000000000000000000000007",
////     output_index: 0,
////   },
//// }
//// // use cardano/transaction.{OutputReference}
//// 
//// // Mock any hash:
//// mock_hash(8, 2) == #"0008"
//// mock_hash_from_int(9, 3) == #"000009"
//// mock_hash_from_bytearray(#"10", 4) == #"00000010"
//// ```
////
//// > [!NOTE]
//// > Constructing mock hashes this way will add to your Memory and CPU Usages **during testing**!
//// > For example: `mock_sh(1)` will generate `#"00000000000000000000000000000000000000000000000000000001"`,
//// > but notice the following Memory and CPU Usages.
//// > ```aiken
//// > /// Aiken v1.1.9 mem: 261806, cpu: 75093536
//// > test mock() {
//// >   trace mock_sh(1)
//// >   True
//// > }
//// > 
//// > /// Aiken v1.1.9 mem: 254825, cpu: 71651198
//// > test no_mock() {
//// >   trace #"00000000000000000000000000000000000000000000000000000001"
//// >   True
//// > }
//// > ```

use aiken/builtin
use aiken/cbor
use aiken/crypto.{
  Blake2b_224, Blake2b_256, Hash, ScriptHash, VerificationKeyHash,
}
use aiken/math
use aiken/primitive/bytearray
use cardano/address.{Address, Credential, Inline, Script, VerificationKey}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{OutputReference, TransactionId}

pub type Any =
  Data

// ## Mock Hash

/// Mocks any hash. You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// The second parameter, `size: Int`, determines the byte length of the resulting mock hash.
/// Smaller size than the length of the `from` argument will NOT truncate it,
/// but 0 or negative size may cause panic or an unexpected behavior!
///
/// Usage examples:
/// ```aiken
/// mock_hash(1, 2) == #"0001"
/// mock_hash(345, 6) == #"000000000345"
/// mock_hash(#"af", 4) == #"000000af"
/// mock_hash("Abc", 3) == #"416263"
/// mock_hash(True, 5) == #"0000D87A80"
/// mock_hash(None, 7) == #"00000000D87A80"
/// mock_hash(Void, 1) == #"D87980"
/// mock_hash(Never, 1) == #"D87A80"
/// mock_hash(Never, 0) == #"D87A80"
/// mock_hash([], 1) == #"80"
/// mock_hash([], 0) == #"80"
/// mock_hash([], -1) == #"80"
/// ```
pub fn mock_hash(from: Any, size: Int) -> ByteArray {
  if from is i: Int {
    i |> mock_hash_from_int(size)
  } else if from is bs: ByteArray {
    bs |> mock_hash_from_bytearray(size)
  } else {
    from |> cbor.serialise |> mock_hash_from_bytearray(size)
  }
}

// ### From ByteArray

/// Left pad ByteArray with pad for left times.
/// For example:
/// ```aiken
/// left_pad("a", 0, 1) == #"0061"
/// left_pad(#"1600", 23, 4) == #"171717171600"
/// left_pad(#"18", 19, 0) == #"18"
/// left_pad(#"20", 2, -1) == #"20"
/// ```
fn left_pad(bs: ByteArray, pad: Int, left: Int) -> ByteArray {
  let next = left - 1
  if next < 0 {
    bs
  } else {
    bs |> left_pad(pad, next) |> builtin.cons_bytearray(pad, _)
  }
}

/// Mocks any hash from [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray).
///
/// The second parameter, `size: Int`, determines the byte length of the resulting mock hash.
/// Smaller size than the length of the `from` argument will NOT truncate it.
///
/// Usage examples:
/// ```aiken
/// mock_hash_from_bytearray(#"af", 4) == #"000000af"
/// mock_hash_from_bytearray("Abc", 3) == #"416263"
/// mock_hash_from_bytearray(#"af", 2) == #"00af"
/// mock_hash_from_bytearray("Abc", 1) == #"416263"
/// mock_hash_from_bytearray(#"af", 0) == #"af"
/// mock_hash_from_bytearray("Abc", -1) == #"416263"
/// ```
pub fn mock_hash_from_bytearray(bs: ByteArray, size: Int) -> ByteArray {
  let bs_length = bs |> builtin.length_of_bytearray
  bs |> left_pad(0, size - bs_length)
}

// ### From Int

/// Converts 0-9 hex to dec.
/// For example:
/// ```aiken
/// hex_to_dec(1, 0) == 1
/// hex_to_dec(12, 0) == 18
/// hex_to_dec(123, 0) == 291
/// ```
/// The second argument `e` must start from 0
fn hex_to_dec(hex: Int, e: Int) -> Int {
  let next = hex / 10
  hex % 10 * math.pow(16, e) + if next == 0 {
    0
  } else {
    next |> hex_to_dec(e + 1)
  }
}

/// Mocks any hash from [`Int`](https://aiken-lang.org/language-tour/primitive-types#int).
///
/// > [!IMPORTANT]
/// > NEGATIVE value for the first parameter is acceptable,
/// > but combined with 0 or less second argument value may
/// > cause panic or an unexpected behavior!
///
/// Usage examples:
/// ```aiken
/// mock_hash_from_int(1, 2) == #"0001"
/// mock_hash_from_int(345, 6) == #"000000000345"
/// mock_hash_from_int(1, 0) == #"01"
/// mock_hash_from_int(345, 0) == #"0345"
/// mock_hash_from_int(1, -2) => 💥
/// mock_hash_from_int(345, -6) => 💥
/// mock_hash_from_int(-1, 2) == #"9999"
/// mock_hash_from_int(-345, 6) == #"999999999655"
/// ```
pub fn mock_hash_from_int(i: Int, size: Int) -> ByteArray {
  let hex =
    if i < 0 {
      math.pow(10, 2 * size) + i
    } else {
      i
    }
  hex |> hex_to_dec(0) |> bytearray.from_int_big_endian(size)
}

// ## Mock Blake2b

/// Mocks a Blake2b-224 Hash. It is 28-byte long.
/// This function is not meant to be called directly,
/// although there's no restriction.
/// It is used by:
/// - [`mock_verification_key_hash`](#mock_verification_key_hash)
/// - [`mock_script_hash`](#mock_script_hash)
/// - [`mock_policy_id`](#mock_policy_id)
pub fn mock_blake2b_224(from: Any) -> Hash<Blake2b_224, ByteArray> {
  mock_hash(from, 28)
}

/// Mocks a Blake2b-256 Hash. It is 32-byte long.
/// This function is not meant to be called directly,
/// although there's no restriction.
/// It is used by:
/// - [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_blake2b_256(from: Any) -> Hash<Blake2b_256, ByteArray> {
  mock_hash(from, 32)
}

// ## Mock Address

/// Helper function used internally. If `from_stake` is `False` | `Void` | `[]` | `""` | `0`,
/// then there's no staking part (`stake_credential: None`)
fn mock_addr(
  mock_credential: fn(Any) -> Credential,
  from_payment: Any,
  from_stake: Any,
) -> Address {
  Address {
    payment_credential: from_payment |> mock_credential,
    stake_credential: from_stake
      |> builtin.choose_data(
          when builtin.un_constr_data(from_stake) is {
            Pair(0, []) -> None
            from -> from |> mock_credential |> Inline |> Some
          },
          when builtin.un_map_data(from_stake) is {
            [] -> None
            from -> from |> mock_credential |> Inline |> Some
          },
          when builtin.un_list_data(from_stake) is {
            [] -> None
            from -> from |> mock_credential |> Inline |> Some
          },
          when builtin.un_i_data(from_stake) is {
            0 -> None
            from -> from |> mock_credential |> Inline |> Some
          },
          when builtin.un_b_data(from_stake) is {
            "" -> None
            from -> from |> mock_credential |> Inline |> Some
          },
        ),
  }
}

/// Mocks an [`Address`](https://aiken-lang.github.io/stdlib/cardano/address.html#Address)
/// with `VerificationKey` payment and stake credentials.
/// You can pass any serializable data type for both the `from_payment` and `from_stake` arguments.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// let address_key = mock_address(123, False) // if 2nd arg is False | Void | [] | "" | 0, then there's no staking part
/// address_key == from_verification_key(#"00000000000000000000000000000000000000000000000000000123")
/// // use cardano/address.{from_verification_key, with_delegation_key}
/// let address_key_key = mock_address(456, 789)
/// address_key_key == (
///   from_verification_key(#"00000000000000000000000000000000000000000000000000000456")
///     |> with_delegation_key(#"00000000000000000000000000000000000000000000000000000789")
/// )
/// ```
///
/// > [!NOTE]
/// > `from_payment` and `from_stake` can have different data types. If `from_stake` is `False` | `Void` | `[]` | `""` | `0`,
/// > then there's no staking part (`stake_credential: None`)
pub fn mock_address(from_payment: Any, from_stake: Any) -> Address {
  mock_verification_key_credential |> mock_addr(from_payment, from_stake)
}

/// Similar to [`mock_address`](#mock_address), but with `Script` payment and stake credentials.
/// You can pass any serializable data type for both the `from_payment` and `from_stake` arguments.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// let address_script = mock_script_address(123, Void)
/// address_script == from_script(#"00000000000000000000000000000000000000000000000000000123")
/// // use cardano/address.{from_script, with_delegation_script}
/// let address_script_script = mock_script_address(456, 789)
/// address_script_script == (
///   from_script(#"00000000000000000000000000000000000000000000000000000456")
///     |> with_delegation_script(#"00000000000000000000000000000000000000000000000000000789")
/// )
/// ```
///
/// > [!NOTE]
/// > `from_payment` and `from_stake` can have different data types. If `from_stake` is `False` | `Void` | `[]` | `""` | `0`,
/// > then there's no staking part (`stake_credential: None`)
pub fn mock_script_address(from_payment: Any, from_stake: Any) -> Address {
  mock_script_credential |> mock_addr(from_payment, from_stake)
}

/// Similar to [`mock_address`](#mock_address), but with `Script` stake credential,
/// and the staking part (`stake_credential`) will NEVER be `None`.
/// You can pass any serializable data type for both the `from_payment` and `from_stake` arguments.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// let address_key_script = mock_address_with_delegation_script(123, 456)
/// address_key_script == (
///   from_verification_key(#"00000000000000000000000000000000000000000000000000000123")
///     |> with_delegation_script(#"00000000000000000000000000000000000000000000000000000456")
/// )
/// // use cardano/address.{from_verification_key, with_delegation_script}
/// ```
pub fn mock_address_with_delegation_script(
  from_payment: Any,
  from_stake: Any,
) -> Address {
  mock_address_from_verification_key(from_payment)
    |> with_mock_delegation_script(from_stake)
}

/// Similar to [`mock_address_with_delegation_script`](#mock_address_with_delegation_script),
/// but it's the other way around. The payment part is `Script` credential, and the staking part is
/// `VerificationKey` credential. The staking part (`stake_credential`) will NEVER be `None`.
/// You can pass any serializable data type for both the `from_payment` and `from_stake` arguments.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// let address_script_key = mock_script_address_with_delegation_key(123, 456)
/// address_script_key == (
///   from_script(#"00000000000000000000000000000000000000000000000000000123")
///     |> with_delegation_key(#"00000000000000000000000000000000000000000000000000000456")
/// )
/// // use cardano/address.{from_script, with_delegation_key}
/// ```
pub fn mock_script_address_with_delegation_key(
  from_payment: Any,
  from_stake: Any,
) -> Address {
  mock_address_from_script(from_payment)
    |> with_mock_delegation_key(from_stake)
}

// ### Aiken's stdlib cardano/address Constructions Style

/// Constructs an [`Address`](https://aiken-lang.github.io/stdlib/cardano/address.html#Address)
/// from a mock verification key hash. The resulting address has no delegation rights.
/// You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage example:
/// ```aiken
/// mock_address_from_verification_key(1) == mock_address(1, 0)
/// ```
pub fn mock_address_from_verification_key(from: Any) -> Address {
  address.from_verification_key(from |> mock_verification_key_hash)
}

/// Constructs an [`Address`](https://aiken-lang.github.io/stdlib/cardano/address.html#Address)
/// from a mock script hash. The address has no delegation rights.
/// You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage example:
/// ```aiken
/// mock_address_from_script(2) == mock_script_address(2, 0)
/// ```
pub fn mock_address_from_script(from: Any) -> Address {
  address.from_script(from |> mock_script_hash)
}

/// Sets the delegation part of an [`Address`](https://aiken-lang.github.io/stdlib/cardano/address.html#Address)
/// using a mock verification key hash. This is useful when combined with [`mock_address_from_verification_key`](#mock_address_from_verification_key)
/// or [`mock_address_from_script`](#mock_address_from_script). You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// (mock_address_from_verification_key(3)
///   |> with_mock_delegation_key(4)
/// ) == mock_address(3, 4)
/// 
/// (mock_address_from_script(3)
///   |> with_mock_delegation_key(4)
/// ) == mock_script_address_with_delegation_key(3, 4)
/// ```
pub fn with_mock_delegation_key(address: Address, from: Any) -> Address {
  address |> address.with_delegation_key(from |> mock_verification_key_hash)
}

/// Sets the delegation part of an [`Address`](https://aiken-lang.github.io/stdlib/cardano/address.html#Address)
/// using a mock script hash. This is useful when combined with [`mock_address_from_verification_key`](#mock_address_from_verification_key)
/// or [`mock_address_from_script`](#mock_address_from_script). You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// (mock_address_from_verification_key(5)
///   |> with_mock_delegation_script(6)
/// ) == mock_address_with_delegation_script(5, 6)
/// 
/// (mock_address_from_script(5)
///   |> with_mock_delegation_script(6)
/// ) == mock_script_address(5, 6)
/// ```
pub fn with_mock_delegation_script(address: Address, from: Any) -> Address {
  address |> address.with_delegation_script(from |> mock_script_hash)
}

// ### Mock Credential

/// Mocks a `VerificationKey` credential. You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// mock_verification_key_credential(1) == VerificationKey(#"00000000000000000000000000000000000000000000000000000001")
/// mock_verification_key_credential(123) == VerificationKey(#"00000000000000000000000000000000000000000000000000000123")
/// mock_verification_key_credential(#"af") == VerificationKey(#"000000000000000000000000000000000000000000000000000000af")
/// mock_verification_key_credential("Abc") == VerificationKey(#"00000000000000000000000000000000000000000000000000416263")
/// mock_verification_key_credential(True) == VerificationKey(#"00000000000000000000000000000000000000000000000000D87A80")
/// mock_verification_key_credential(None) == VerificationKey(#"00000000000000000000000000000000000000000000000000D87A80")
/// mock_verification_key_credential(Void) == VerificationKey(#"00000000000000000000000000000000000000000000000000D87980")
/// mock_verification_key_credential(Never) == VerificationKey(#"00000000000000000000000000000000000000000000000000D87A80")
/// mock_verification_key_credential([]) == VerificationKey(#"00000000000000000000000000000000000000000000000000000080")
/// // use cardano/address.{VerificationKey}
/// ```
pub fn mock_verification_key_credential(from: Any) -> Credential {
  VerificationKey(from |> mock_verification_key_hash)
}

/// Mocks a `Script` credential. You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// mock_script_credential(1) == Script(#"00000000000000000000000000000000000000000000000000000001")
/// mock_script_credential(123) == Script(#"00000000000000000000000000000000000000000000000000000123")
/// mock_script_credential(#"af") == Script(#"000000000000000000000000000000000000000000000000000000af")
/// mock_script_credential("Abc") == Script(#"00000000000000000000000000000000000000000000000000416263")
/// mock_script_credential(True) == Script(#"00000000000000000000000000000000000000000000000000D87A80")
/// mock_script_credential(None) == Script(#"00000000000000000000000000000000000000000000000000D87A80")
/// mock_script_credential(Void) == Script(#"00000000000000000000000000000000000000000000000000D87980")
/// mock_script_credential(Never) == Script(#"00000000000000000000000000000000000000000000000000D87A80")
/// mock_script_credential([]) == Script(#"00000000000000000000000000000000000000000000000000000080")
/// // use cardano/address.{Script}
/// ```
pub fn mock_script_credential(from: Any) -> Credential {
  Script(from |> mock_script_hash)
}

// #### Mock Verification Key Hash

/// Mocks a [`VerificationKeyHash`](https://aiken-lang.github.io/stdlib/aiken/crypto.html#VerificationKeyHash).
/// You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// mock_verification_key_hash(1) == #"00000000000000000000000000000000000000000000000000000001"
/// mock_verification_key_hash(123) == #"00000000000000000000000000000000000000000000000000000123"
/// mock_verification_key_hash(#"af") == #"000000000000000000000000000000000000000000000000000000af"
/// mock_verification_key_hash("Abc") == #"00000000000000000000000000000000000000000000000000416263"
/// mock_verification_key_hash(True) == #"00000000000000000000000000000000000000000000000000D87A80"
/// mock_verification_key_hash(None) == #"00000000000000000000000000000000000000000000000000D87A80"
/// mock_verification_key_hash(Void) == #"00000000000000000000000000000000000000000000000000D87980"
/// mock_verification_key_hash(Never) == #"00000000000000000000000000000000000000000000000000D87A80"
/// mock_verification_key_hash([]) == #"00000000000000000000000000000000000000000000000000000080"
/// ```
/// 
/// Alias: [`mock_vkh`](#mock_vkh)
pub fn mock_verification_key_hash(from: Any) -> VerificationKeyHash {
  from |> mock_blake2b_224
}

/// See: [`mock_verification_key_hash`](#mock_verification_key_hash)
pub fn mock_vkh(from: Any) -> VerificationKeyHash {
  from |> mock_verification_key_hash
}

// #### Mock Script Hash

/// Mocks a [`ScriptHash`](https://aiken-lang.github.io/stdlib/aiken/crypto.html#ScriptHash).
/// Under the hood, it's the same as [`mock_verification_key_hash`](#mock_verification_key_hash)
/// or [`mock_vkh`](#mock_vkh). You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage examples:
/// ```aiken
/// mock_script_hash(1) == #"00000000000000000000000000000000000000000000000000000001"
/// mock_script_hash(123) == #"00000000000000000000000000000000000000000000000000000123"
/// mock_script_hash(#"af") == #"000000000000000000000000000000000000000000000000000000af"
/// mock_script_hash("Abc") == #"00000000000000000000000000000000000000000000000000416263"
/// mock_script_hash(True) == #"00000000000000000000000000000000000000000000000000D87A80"
/// mock_script_hash(None) == #"00000000000000000000000000000000000000000000000000D87A80"
/// mock_script_hash(Void) == #"00000000000000000000000000000000000000000000000000D87980"
/// mock_script_hash(Never) == #"00000000000000000000000000000000000000000000000000D87A80"
/// mock_script_hash([]) == #"00000000000000000000000000000000000000000000000000000080"
/// ```
/// 
/// Alias: [`mock_sh`](#mock_sh)
pub fn mock_script_hash(from: Any) -> ScriptHash {
  from |> mock_blake2b_224
}

/// See: [`mock_script_hash`](#mock_script_hash)
pub fn mock_sh(from: Any) -> ScriptHash {
  from |> mock_script_hash
}

// ## Mock Asset

/// Constructs a [`Value`](https://aiken-lang.github.io/stdlib/cardano/assets.html#Value)
/// from a mock [`PolicyId`](#mock_policy_id), [`AssetName`](https://aiken-lang.github.io/stdlib/cardano/assets.html#AssetName)
/// and a given `quantity`. You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage example:
/// ```aiken
/// mock_asset("PolicyId", "NFT", 1)
///   |> add(#"0000000000000000000000000000000000000000506F6C6963794964", "NFT", -1)
///   |> is_zero() // True
/// // use cardano/assets.{add, is_zero}
/// ```
///
/// > [!NOTE]
/// > You can also only mock the Policy ID, see: [`mock_policy_id`](#mock_policy_id)
pub fn mock_asset(from: Any, asset_name: AssetName, quantity qty: Int) {
  assets.from_asset(from |> mock_policy_id, asset_name, qty)
}

// ### Mock Policy ID

/// Mocks a [`PolicyId`](https://aiken-lang.github.io/stdlib/cardano/assets.html#PolicyId).
/// You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage example:
/// ```aiken
/// from_asset(mock_policy_id(123), "NFT", 1)
///   |> add(#"00000000000000000000000000000000000000000000000000000123", "NFT", -1)
///   |> is_zero() // True
/// // use cardano/assets.{from_asset, add, is_zero}
/// ```
/// 
/// Alias: [`mock_policy`](#mock_policy)
pub fn mock_policy_id(from: Any) -> PolicyId {
  from |> mock_blake2b_224
}

/// See: [`mock_policy_id`](#mock_policy_id)
pub fn mock_policy(from: Any) -> PolicyId {
  from |> mock_policy_id
}

// ## Mock Output Reference

/// Mocks an [`OutputReference`](https://aiken-lang.github.io/stdlib/cardano/transaction.html#OutputReference).
/// You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage example:
/// ```aiken
/// mock_output_reference(123, 45) == OutputReference {
///   transaction_id: #"0000000000000000000000000000000000000000000000000000000000000123",
///   output_index: 45,
/// }
/// // use cardano/transaction.{OutputReference}
/// ```
///
/// Aliases:
/// - [`mock_out_ref`](#mock_out_ref)
/// - [`mock_o_ref`](#mock_o_ref)
///
/// > [!NOTE]
/// > You can also only mock the Transaction ID, see: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_output_reference(from: Any, output_index: Int) -> OutputReference {
  OutputReference { transaction_id: from |> mock_transaction_id, output_index }
}

/// See: [`mock_output_reference`](#mock_output_reference)
pub fn mock_out_ref(from: Any, output_index: Int) -> OutputReference {
  from |> mock_output_reference(output_index)
}

/// See: [`mock_output_reference`](#mock_output_reference)
pub fn mock_o_ref(from: Any, output_index: Int) -> OutputReference {
  from |> mock_output_reference(output_index)
}

// ### Mock Transaction ID

/// Mocks a [`TransactionId`](https://aiken-lang.github.io/stdlib/cardano/transaction.html#TransactionId).
/// You can pass any serializable data type for the `from` argument.
///
/// If the argument data type is [`Int`](https://aiken-lang.org/language-tour/primitive-types#int),
/// then it will be processed like: `123` => `#"00..0123"`.
///
/// If the argument data type is [`ByteArray`](https://aiken-lang.org/language-tour/primitive-types#bytearray),
/// then it will be processed like: `"Abc"` => `#"00..00416263"`, `#"af"` => `#"00..000000af"`.
///
/// Otherwise, it will be [serialised](https://aiken-lang.github.io/stdlib/aiken/cbor.html#serialise).
///
/// Usage example:
/// ```aiken
/// OutputReference(mock_transaction_id(1), 0) == mock_output_reference(1, 0)
/// // use cardano/transaction.{OutputReference}
/// ```
/// 
/// Aliases:
/// - [`mock_tran_id`](#mock_tran_id)
/// - [`mock_txn_id`](#mock_txn_id)
/// - [`mock_tx_id`](#mock_tx_id)
/// - [`mock_tx_hash`](#mock_tx_hash)
/// - [`mock_txn_hash`](#mock_txn_hash)
/// - [`mock_tran_hash`](#mock_tran_hash)
/// - [`mock_transaction_hash`](#mock_transaction_hash)
pub fn mock_transaction_id(from: Any) -> TransactionId {
  from |> mock_blake2b_256
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_tran_id(from: Any) -> TransactionId {
  from |> mock_transaction_id
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_txn_id(from: Any) -> TransactionId {
  from |> mock_transaction_id
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_tx_id(from: Any) -> TransactionId {
  from |> mock_transaction_id
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_tx_hash(from: Any) -> TransactionId {
  from |> mock_transaction_id
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_txn_hash(from: Any) -> TransactionId {
  from |> mock_transaction_id
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_tran_hash(from: Any) -> TransactionId {
  from |> mock_transaction_id
}

/// See: [`mock_transaction_id`](#mock_transaction_id)
pub fn mock_transaction_hash(from: Any) -> TransactionId {
  from |> mock_transaction_id
}
