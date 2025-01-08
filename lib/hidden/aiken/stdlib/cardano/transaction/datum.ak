//// @hidden
//// A transaction datum type module to avoid potential name clashing in the future.

use aiken/crypto.{DataHash}
use cardano/transaction.{DatumHash, InlineDatum, NoDatum}

pub const no_datum = NoDatum

pub fn to_datum_hash(datum: DataHash) -> transaction.Datum {
  DatumHash(datum)
}

pub fn to_inline_datum(datum: Data) -> transaction.Datum {
  InlineDatum(datum)
}
