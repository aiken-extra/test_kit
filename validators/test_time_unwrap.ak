//// @hidden

use aiken/fuzz
use aiken/interval.{
  after, before, between, entirely_after, entirely_before, entirely_between,
}
use test_kit/fuzzy
use test_kit/time/unwrap.{finite_end_of, finite_start_of}

test testing_finite_start(
  (lower_bound, upper_bound) via fuzzy.tuple(
    fuzz.int_between(1738335721000, 1738339382000),
    fuzz.int_between(1738343043000, 1738346704000),
  ),
) {
  and {
    ( after(lower_bound) |> finite_start_of ) == lower_bound,
    ( entirely_after(lower_bound) |> finite_start_of ) == lower_bound + 1,
    ( between(lower_bound, upper_bound) |> finite_start_of ) == lower_bound,
    ( entirely_between(lower_bound, upper_bound) |> finite_start_of ) == lower_bound + 1,
  }
}

test testing_finite_end(
  (lower_bound, upper_bound) via fuzzy.tuple(
    fuzz.int_between(1738335721000, 1738339382000),
    fuzz.int_between(1738343043000, 1738346704000),
  ),
) {
  and {
    ( before(upper_bound) |> finite_end_of ) == upper_bound,
    ( entirely_before(upper_bound) |> finite_end_of ) == upper_bound - 1,
    ( between(lower_bound, upper_bound) |> finite_end_of ) == upper_bound,
    ( entirely_between(lower_bound, upper_bound) |> finite_end_of ) == upper_bound - 1,
  }
}
