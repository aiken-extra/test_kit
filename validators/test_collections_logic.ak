//// @hidden
//// ```
//// Aiken v1.1.9:
//// │ PASS [mem: 30377, cpu: 8161595] testing_all_true
//// │ PASS [mem: 29117, cpu: 7545021] testing_any_true
//// │ PASS [mem: 33382, cpu: 9021840] testing_all_false
//// │ PASS [mem: 31521, cpu: 8233217] testing_any_false
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
