//// @hidden
//// ```
//// Aiken v1.1.21:
//// │ PASS [mem:  25.34 K, cpu:   7.27 M] testing_all_true
//// │ PASS [mem:  23.55 K, cpu:   6.50 M] testing_any_true
//// │ PASS [mem:  27.85 K, cpu:   8.06 M] testing_all_false
//// │ PASS [mem:  25.55 K, cpu:   7.12 M] testing_any_false
//// ```

use test_kit/collections/logic.{all_false, all_true, any_false, any_true}

test testing_all_true() {
  and {
    [True, True, True] |> all_true,
    [True, False, True] |> all_true |> not,
    [] |> all_true,
  }
}

test testing_any_true() {
  and {
    [True, True] |> any_true,
    [True, False, True] |> any_true,
    [] |> any_true |> not,
    [False, False] |> any_true |> not,
  }
}

test testing_all_false() {
  and {
    [False, False, False] |> all_false,
    [False, True, False] |> all_false |> not,
    [] |> all_false,
  }
}

test testing_any_false() {
  and {
    [False, False] |> any_false,
    [False, True, False] |> any_false,
    [] |> any_false |> not,
    [True, True] |> any_false |> not,
  }
}
