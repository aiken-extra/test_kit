//// A convenient way to unwrap `Finite(PosixTime)` from an `Interval`,
//// but will **panic** if the interval bound is not `Finite`.

use aiken/interval.{Finite, Interval, IntervalBoundType}
use test_kit/time.{PosixTime}

/// Returns the **normalized lower-bound** `Posixtime` of an `interval`
/// > [!WARNING]
/// > Will panic if `lower_bound` is not `Finite`
pub fn finite_start_of(interval: Interval<PosixTime>) -> PosixTime {
  let bound = interval.lower_bound

  expect Finite(time): IntervalBoundType<PosixTime> = bound.bound_type

  if bound.is_inclusive {
    time
  } else {
    time + 1
  }
}

/// Returns the **normalized upper-bound** `PosixTime` of an `interval`
/// > [!WARNING]
/// > Will panic if `upper_bound` is not `Finite`
pub fn finite_end_of(interval: Interval<PosixTime>) -> PosixTime {
  let bound = interval.upper_bound

  expect Finite(time): IntervalBoundType<PosixTime> = bound.bound_type

  if bound.is_inclusive {
    time
  } else {
    time - 1
  }
}
