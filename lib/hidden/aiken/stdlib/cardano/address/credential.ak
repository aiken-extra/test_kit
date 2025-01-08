//// @hidden
//// An address credential type module to avoid potential name clashing in the future.

use aiken/crypto.{ScriptHash, VerificationKeyHash}
use cardano/address.{VerificationKey}

pub fn to_verification_key(
  credential: VerificationKeyHash,
) -> address.Credential {
  VerificationKey(credential)
}

pub fn to_script(credential: ScriptHash) -> address.Credential {
  address.Script(credential)
}
