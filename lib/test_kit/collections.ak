use aiken/collection/list.{foldr, map3}
use test_kit/collections/logic.{all_true, any_true}

// ## List

/// Tells whether all of the `booleans` are `true`
pub fn list_and(bool_list: List<Bool>) -> Bool {
  bool_list |> all_true
}

/// Tells whether any of the `booleans` is `true`
pub fn list_or(bool_list: List<Bool>) -> Bool {
  bool_list |> any_true
}

// ## Zip

/// Combine 3 lists together into a list of 3-tuple.
pub fn zip3(az: List<a>, bz: List<b>, cz: List<c>) -> List<(a, b, c)> {
  let a, b, c <- map3(az, bz, cz)
  (a, b, c)
}

/// Decompose a list of 3-tuple into a tuple of 3 lists.
pub fn unzip3(abc: List<(a, b, c)>) -> (List<a>, List<b>, List<c>) {
  let curr, next <- foldr(abc, ([], [], []))

  let (a, b, c) = curr
  let (az, bz, cz) = next

  ([a, ..az], [b, ..bz], [c, ..cz])
}
