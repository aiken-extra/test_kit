//// @hidden

use aiken/fuzz
use aiken/interval.{
  after, before, between, entirely_after, entirely_before, entirely_between,
}
use test_kit/fuzzy
use test_kit/time.{
  CS, DS, Day, Hour, MS, Minute, Second, Week, Zero, add_interval, sub_interval,
}

/// Testing for `add_interval` autimatically tests for `add_bound`, `add_finite`, and `add_time` too.
test testing_add_interval(
  (lower_bound, upper_bound) via fuzzy.tuple(
    fuzz.int_between(1738335721000, 1738339382000),
    fuzz.int_between(1738343043000, 1738346704000),
  ),
) {
  and {
    ( after(lower_bound) |> add_interval(Zero, Zero) ) == after(lower_bound + 0),
    ( after(lower_bound) |> add_interval(3 |> MS, Zero) ) == after(
      lower_bound + 3,
    ),
    ( after(lower_bound) |> add_interval(Zero, 4 |> MS) ) == after(
      lower_bound + 0,
    ),
    ( after(lower_bound) |> add_interval(5 |> MS, 6 |> MS) ) == after(
      lower_bound + 5,
    ),
    // testing entirely_after and CS:
    ( entirely_after(lower_bound) |> add_interval(Zero, Zero) ) == entirely_after(
      lower_bound + 0 * 10,
    ),
    ( entirely_after(lower_bound) |> add_interval(7 |> CS, Zero) ) == entirely_after(
      lower_bound + 7 * 10,
    ),
    ( entirely_after(lower_bound) |> add_interval(Zero, 8 |> CS) ) == entirely_after(
      lower_bound + 0 * 10,
    ),
    ( entirely_after(lower_bound) |> add_interval(9 |> CS, 10 |> CS) ) == entirely_after(
      lower_bound + 9 * 10,
    ),
    // testing before and DS:
    ( before(upper_bound) |> add_interval(Zero, Zero) ) == before(
      upper_bound + 0 * 100,
    ),
    ( before(upper_bound) |> add_interval(11 |> DS, Zero) ) == before(
      upper_bound + 0 * 100,
    ),
    ( before(upper_bound) |> add_interval(Zero, 12 |> DS) ) == before(
      upper_bound + 12 * 100,
    ),
    ( before(upper_bound) |> add_interval(13 |> DS, 14 |> DS) ) == before(
      upper_bound + 14 * 100,
    ),
    // testing entirely_before and Second:
    ( entirely_before(upper_bound) |> add_interval(Zero, Zero) ) == entirely_before(
      upper_bound + 0 * 1_000,
    ),
    ( entirely_before(upper_bound) |> add_interval(15 |> Second, Zero) ) == entirely_before(
      upper_bound + 0 * 1_000,
    ),
    ( entirely_before(upper_bound) |> add_interval(Zero, 16 |> Second) ) == entirely_before(
      upper_bound + 16 * 1_000,
    ),
    ( entirely_before(upper_bound) |> add_interval(17 |> Second, 18 |> Second) ) == entirely_before(
      upper_bound + 18 * 1_000,
    ),
    // testing between and Minute:
    ( between(lower_bound, upper_bound) |> add_interval(Zero, Zero) ) == between(
      lower_bound + 0 * 60 * 1_000,
      upper_bound + 0 * 60 * 1_000,
    ),
    ( between(lower_bound, upper_bound) |> add_interval(25 |> Minute, Zero) ) == between(
      lower_bound + 25 * 60 * 1_000,
      upper_bound + 0 * 60 * 1_000,
    ),
    ( between(lower_bound, upper_bound) |> add_interval(Zero, 26 |> Minute) ) == between(
      lower_bound + 0 * 60 * 1_000,
      upper_bound + 26 * 60 * 1_000,
    ),
    (
      between(lower_bound, upper_bound)
        |> add_interval(27 |> Minute, 28 |> Minute)
    ) == between(lower_bound + 27 * 60 * 1_000, upper_bound + 28 * 60 * 1_000),
    // testing entirely_between and Hour:
    ( entirely_between(lower_bound, upper_bound) |> add_interval(Zero, Zero) ) == entirely_between(
      lower_bound + 0 * 60 * 60 * 1_000,
      upper_bound + 0 * 60 * 60 * 1_000,
    ),
    (
      entirely_between(lower_bound, upper_bound)
        |> add_interval(29 |> Hour, Zero)
    ) == entirely_between(
      lower_bound + 29 * 60 * 60 * 1_000,
      upper_bound + 0 * 60 * 60 * 1_000,
    ),
    (
      entirely_between(lower_bound, upper_bound)
        |> add_interval(Zero, 30 |> Hour)
    ) == entirely_between(
      lower_bound + 0 * 60 * 60 * 1_000,
      upper_bound + 30 * 60 * 60 * 1_000,
    ),
    (
      entirely_between(lower_bound, upper_bound)
        |> add_interval(31 |> Hour, 32 |> Hour)
    ) == entirely_between(
      lower_bound + 31 * 60 * 60 * 1_000,
      upper_bound + 32 * 60 * 60 * 1_000,
    ),
    // testing Day and Week:
    ( after(lower_bound) |> add_interval(29 |> Day, 30 |> Week) ) == after(
      lower_bound + 29 * 24 * 60 * 60 * 1_000,
    ),
    ( before(upper_bound) |> add_interval(31 |> Week, 32 |> Day) ) == before(
      upper_bound + 32 * 24 * 60 * 60 * 1_000,
    ),
    ( entirely_after(lower_bound) |> add_interval(33 |> Week, 34 |> Day) ) == entirely_after(
      lower_bound + 33 * 7 * 24 * 60 * 60 * 1_000,
    ),
    ( entirely_before(upper_bound) |> add_interval(35 |> Day, 36 |> Week) ) == entirely_before(
      upper_bound + 36 * 7 * 24 * 60 * 60 * 1_000,
    ),
  }
}

/// Testing for `sub_interval` autimatically tests for `sub_bound`, `sub_finite`, and `sub_time` too.
test testing_sub_interval(
  (lower_bound, upper_bound) via fuzzy.tuple(
    fuzz.int_between(1738335721000, 1738339382000),
    fuzz.int_between(1738343043000, 1738346704000),
  ),
) {
  and {
    ( after(lower_bound) |> sub_interval(3 |> Hour, 4 |> Hour) ) == after(
      lower_bound - 3 * 60 * 60 * 1_000,
    ),
    ( after(lower_bound) |> sub_interval(2 |> Hour, Zero) ) == after(
      lower_bound - 2 * 60 * 60 * 1_000,
    ),
    ( after(lower_bound) |> sub_interval(Zero, 1 |> Hour) ) == after(
      lower_bound - 0 * 60 * 60 * 1_000,
    ),
    ( after(lower_bound) |> sub_interval(Zero, Zero) ) == after(
      lower_bound - 0 * 60 * 60 * 1_000,
    ),
    // testing entirely_after and Minute:
    ( entirely_after(lower_bound) |> sub_interval(3 |> Minute, 4 |> Minute) ) == entirely_after(
      lower_bound - 3 * 60 * 1_000,
    ),
    ( entirely_after(lower_bound) |> sub_interval(2 |> Minute, Zero) ) == entirely_after(
      lower_bound - 2 * 60 * 1_000,
    ),
    ( entirely_after(lower_bound) |> sub_interval(Zero, 1 |> Minute) ) == entirely_after(
      lower_bound - 0 * 60 * 1_000,
    ),
    ( entirely_after(lower_bound) |> sub_interval(Zero, Zero) ) == entirely_after(
      lower_bound - 0 * 60 * 1_000,
    ),
    // testing before and Second:
    ( before(upper_bound) |> sub_interval(3 |> Second, 4 |> Second) ) == before(
      upper_bound - 4 * 1_000,
    ),
    ( before(upper_bound) |> sub_interval(2 |> Second, Zero) ) == before(
      upper_bound - 0 * 1_000,
    ),
    ( before(upper_bound) |> sub_interval(Zero, 1 |> Second) ) == before(
      upper_bound - 1 * 1_000,
    ),
    ( before(upper_bound) |> sub_interval(Zero, Zero) ) == before(
      upper_bound - 0 * 1_000,
    ),
    // testing entirely_before and DS:
    ( entirely_before(upper_bound) |> sub_interval(3 |> DS, 4 |> DS) ) == entirely_before(
      upper_bound - 4 * 100,
    ),
    ( entirely_before(upper_bound) |> sub_interval(2 |> DS, Zero) ) == entirely_before(
      upper_bound - 0 * 100,
    ),
    ( entirely_before(upper_bound) |> sub_interval(Zero, 1 |> DS) ) == entirely_before(
      upper_bound - 1 * 100,
    ),
    ( entirely_before(upper_bound) |> sub_interval(Zero, Zero) ) == entirely_before(
      upper_bound - 0 * 100,
    ),
    // testing between and CS:
    ( between(lower_bound, upper_bound) |> sub_interval(3 |> CS, 4 |> CS) ) == between(
      lower_bound - 3 * 10,
      upper_bound - 4 * 10,
    ),
    ( between(lower_bound, upper_bound) |> sub_interval(2 |> CS, Zero) ) == between(
      lower_bound - 2 * 10,
      upper_bound - 0 * 10,
    ),
    ( between(lower_bound, upper_bound) |> sub_interval(Zero, 1 |> CS) ) == between(
      lower_bound - 0 * 10,
      upper_bound - 1 * 10,
    ),
    ( between(lower_bound, upper_bound) |> sub_interval(Zero, Zero) ) == between(
      lower_bound - 0 * 10,
      upper_bound - 0 * 10,
    ),
    // testing entirely_between and MS:
    (
      entirely_between(lower_bound, upper_bound)
        |> sub_interval(3 |> MS, 4 |> MS)
    ) == entirely_between(lower_bound - 3, upper_bound - 4),
    (
      entirely_between(lower_bound, upper_bound) |> sub_interval(2 |> MS, Zero)
    ) == entirely_between(lower_bound - 2, upper_bound - 0),
    (
      entirely_between(lower_bound, upper_bound) |> sub_interval(Zero, 1 |> MS)
    ) == entirely_between(lower_bound - 0, upper_bound - 1),
    ( entirely_between(lower_bound, upper_bound) |> sub_interval(Zero, Zero) ) == entirely_between(
      lower_bound - 0,
      upper_bound - 0,
    ),
    // testing Day and Week:
    ( after(lower_bound) |> sub_interval(4 |> Day, 5 |> Week) ) == after(
      lower_bound - 4 * 24 * 60 * 60 * 1_000,
    ),
    ( before(upper_bound) |> sub_interval(3 |> Week, 4 |> Day) ) == before(
      upper_bound - 4 * 24 * 60 * 60 * 1_000,
    ),
    ( entirely_after(lower_bound) |> sub_interval(2 |> Week, 3 |> Day) ) == entirely_after(
      lower_bound - 2 * 7 * 24 * 60 * 60 * 1_000,
    ),
    ( entirely_before(upper_bound) |> sub_interval(1 |> Day, 2 |> Week) ) == entirely_before(
      upper_bound - 2 * 7 * 24 * 60 * 60 * 1_000,
    ),
  }
}
