//// @hidden
//// A certificate dRep type module to avoid name clashing with `governance.DelegateRepresentative`

use cardano/address
use cardano/certificate.{
  AlwaysAbstain, AlwaysNoConfidence, DelegateRepresentative,
}

pub fn to_registered(d_rep: address.Credential) -> DelegateRepresentative {
  certificate.Registered(d_rep)
}

pub const always_abstain = AlwaysAbstain

pub const always_no_confidence = AlwaysNoConfidence
