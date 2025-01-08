use aiken/collection/list.{all, any}

/// Equivalent to the old `list.and`
pub fn all_true(bool_list: List<Bool>) -> Bool {
  bool_list |> all(identity)
}

/// Equivalent to the old `list.or`
pub fn any_true(bool_list: List<Bool>) -> Bool {
  bool_list |> any(identity)
}

/// The opposite of `all_true`
pub fn all_false(bool_list: List<Bool>) -> Bool {
  let bool <- all(bool_list)
  !bool
}

/// The opposite of `any_true`
pub fn any_false(bool_list: List<Bool>) -> Bool {
  let bool <- any(bool_list)
  !bool
}
