//// @hidden
//// ```
//// Aiken v1.1.9:
//// │ PASS [mem:  30377, cpu:  8161595] testing_list_and
//// │ PASS [mem:  29117, cpu:  7545021] testing_list_or
//// │ PASS [mem:  95047, cpu: 33200860] testing_zip3
//// │ PASS [mem: 112579, cpu: 43284882] testing_unzip3
//// ```

use test_kit/collections.{list_and, list_or, unzip3, zip3}

test testing_list_and() {
  and {
    [True, True, True] |> list_and,
    [True, False, True] |> list_and |> not,
    [] |> list_and,
  }
}

test testing_list_or() {
  and {
    [True, True] |> list_or,
    [True, False, True] |> list_or,
    [] |> list_or |> not,
    [False, False] |> list_or |> not,
  }
}

test testing_zip3() {
  and {
    zip3([1, 2], ["a", "b", "c"], [True, False, True, False]) == [
      (1, "a", True), (2, "b", False),
    ],
    zip3([1, 2, 3], ["a", "b", "c", "d"], [True, False, True]) == [
      (1, "a", True), (2, "b", False), (3, "c", True),
    ],
    zip3([1, 2, 3, 4], ["a", "b", "c"], [True, False]) == [
      (1, "a", True), (2, "b", False),
    ],
  }
}

test testing_unzip3() {
  and {
    unzip3([(1, "a", True), (2, "b", False)]) == (
      [1, 2],
      ["a", "b"],
      [True, False],
    ),
    unzip3([(1, "a", True), (2, "b", False), (3, "c", True)]) == (
      [1, 2, 3],
      ["a", "b", "c"],
      [True, False, True],
    ),
    unzip3([(1, "a", True), (2, "b", False), (3, "c", True), (4, "d", False)]) == (
      [1, 2, 3, 4],
      ["a", "b", "c", "d"],
      [True, False, True, False],
    ),
  }
}
