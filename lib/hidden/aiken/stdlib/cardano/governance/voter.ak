//// @hidden
//// A governance voter type module to avoid name clashing with `certificate.DelegateRepresentative`

use cardano/address
use cardano/certificate.{StakePoolId}
use cardano/governance.{
  ConstitutionalCommitteeMember, DelegateRepresentative, StakePool,
}

pub fn to_constitutional_committee_member(
  voter: address.Credential,
) -> governance.Voter {
  ConstitutionalCommitteeMember(voter)
}

pub fn to_delegate_representative(voter: address.Credential) -> governance.Voter {
  DelegateRepresentative(voter)
}

pub fn to_stake_pool(voter: StakePoolId) -> governance.Voter {
  StakePool(voter)
}
