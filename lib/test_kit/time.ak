//// You can have a real latest block-time value when running tests!
////
//// > [!NOTE]
//// > For Linux
////
//// Copy [`./check.sh`](https://github.com/aiken-extra/test_kit/blob/main/check.sh)
//// and paste it in the root directory of your Aiken project.
//// Make it an executable.
////
//// Add `now` to `aiken.toml` configurations like:
////
//// ```toml
//// [config.default]
//// ...
//// now = 0
//// ...
////
//// [config.any]
//// ...
//// now = 0
//// ...
//// ```
////
//// Run `./check.sh` (with optional `-m` and/or `-E` arguments)
////
//// ```bash
//// $ ./check.sh -H
//// Usage: ./check.sh -m <MATCH_TEST> -E <ENV>
//// ```
////
//// It will get the latest block-time, thanks to [Koios](https://www.koios.rest),
//// and reconfigure the value for `now` in all environments.
////
//// Access it from your code by:
////
//// ```aiken
//// use config
//// trace config.now
//// ```

use aiken/builtin
use aiken/interval.{Interval, IntervalBound, IntervalBoundType}

/// A number of milliseconds since 00:00:00 UTC on 1 January 1970.
///
/// Brought back [`aiken/time.{PosixTime}`](https://github.com/aiken-lang/stdlib/blob/205e8f9a06c6f3c9e7c93bb7745e390515e2e2cf/lib/aiken/time.ak)
/// after being removed in [`stdlib v2.0.0`](https://github.com/aiken-lang/stdlib/releases/tag/v2.0.0#:~:text=The%20module%20aiken/time.%20The%20PosixTime%20alias%20is%20no%20longer%20used%20anywhere)
pub type PosixTime =
  Int

pub type TimeUnit {
  Zero

  /// Millisecond: `1 millisecond = 1 / 1_000 second`
  MS(Int)

  /// Centisecond: `1 centisecond = 10 milliseconds`
  CS(Int)

  /// Decisecond: `1 decisecond = 100 milliseconds`
  DS(Int)

  Second(Int)
  Minute(Int)
  Hour(Int)
  Day(Int)
  Week(Int)
}

fn get_ms(self: TimeUnit) -> Int {
  when self is {
    Zero -> 0
    MS(ms) -> ms
    CS(cs) -> cs * 10
    DS(ds) -> ds * 100
    Second(s) -> s * 1_000
    Minute(m) -> m * 60_000
    Hour(h) -> h * 3_600_000
    Day(d) -> d * 86_400_000
    Week(w) -> w * 604_800_000
  }
}

// ## PosixTime

fn opr_time(
  self: PosixTime,
  time: TimeUnit,
  opr: fn(PosixTime, PosixTime) -> PosixTime,
) -> PosixTime {
  self |> opr(time |> get_ms)
}

/// Adds time to a [`PosixTime`](#PosixTime). For example:
/// ```aiken
/// 1234567890000
///   |> add_time(Zero)
/// // == 1234567890000 + 0
/// 
/// 5443200000
///   |> add_time(8 |> Week)
/// // == 5443200000 + 8 * 7 * 24 * 60 * 60 * 1_000
/// 
/// 691200000
///   |> add_time(7 |> Day)
/// // == 691200000 + 7 * 24 * 60 * 60 * 1_000
/// 
/// 25200000
///   |> add_time(6 |> Minute)
/// // == 25200000 + 6 * 60 * 1_000
/// 
/// 360000
///   |> add_time(3 |> Second)
/// // == 360000 + 3 * 1_000
/// 
/// 5000
///   |> add_time(2 |> MS)
/// // == 5000 + 2
/// ```
pub fn add_time(self: PosixTime, time: TimeUnit) -> PosixTime {
  self |> opr_time(time, builtin.add_integer)
}

/// Subtracts time from a [`PosixTime`](#PosixTime). For example:
/// ```aiken
/// 1234567890000
///   |> sub_time(Zero)
/// // == 1234567890000 - 0
/// 
/// 5443200000
///   |> sub_time(8 |> Week)
/// // == 5443200000 - 8 * 7 * 24 * 60 * 60 * 1_000
/// 
/// 691200000
///   |> sub_time(7 |> Day)
/// // == 691200000 - 7 * 24 * 60 * 60 * 1_000
/// 
/// 25200000
///   |> sub_time(6 |> Minute)
/// // == 25200000 - 6 * 60 * 1_000
/// 
/// 360000
///   |> sub_time(3 |> Second)
/// // == 360000 - 3 * 1_000
/// 
/// 5000
///   |> sub_time(2 |> MS)
/// // == 5000 - 2
/// ```
pub fn sub_time(self: PosixTime, time: TimeUnit) -> PosixTime {
  self |> opr_time(time, builtin.subtract_integer)
}

// ## Interval

fn opr_interval(
  self: Interval,
  lower_bound: TimeUnit,
  upper_bound: TimeUnit,
  opr: fn(IntervalBound, TimeUnit) -> IntervalBound,
) -> Interval {
  Interval {
    lower_bound: self.lower_bound |> opr(lower_bound),
    upper_bound: self.upper_bound |> opr(upper_bound),
  }
}

/// Adds time to an `Interval`. For example:
/// ```aiken
/// interval.after(1234567890000)
///   |> add_interval(lower_bound: Zero, upper_bound: Zero)
/// // == interval.after(1234567890000 + 0)
/// 
/// interval.after(5443200000)
///   |> add_interval(Zero, 8 |> Week)
/// // == interval.after(5443200000 + 0)
/// 
/// interval.after(691200000)
///   |> add_interval(7 |> Day, Zero)
/// // == interval.after(691200000 + 7 * 24 * 60 * 60 * 1_000)
/// 
/// interval.after(25200000)
///   |> add_interval(6 |> Minute, 5 |> Hour)
/// // == interval.after(25200000 + 6 * 60 * 1_000)
/// 
/// interval.before(360000)
///   |> add_interval(4 |> DS, 3 |> Second)
/// // == interval.before(360000 + 3 * 1_000)
/// 
/// interval.between(4, 5000)
///   |> add_interval(2 |> MS, 1 |> CS)
/// // == interval.between(4 + 2, 5000 + 1 * 10)
/// ```
pub fn add_interval(
  self: Interval,
  lower_bound: TimeUnit,
  upper_bound: TimeUnit,
) -> Interval {
  self |> opr_interval(lower_bound, upper_bound, add_bound)
}

/// Subtracts time from an `Interval`. For example:
/// ```aiken
/// interval.after(1234567890000)
///   |> sub_interval(lower_bound: Zero, upper_bound: Zero)
/// // == interval.after(1234567890000 - 0)
/// 
/// interval.after(5443200000)
///   |> sub_interval(Zero, 8 |> Week)
/// // == interval.after(5443200000 - 0)
/// 
/// interval.after(691200000)
///   |> sub_interval(7 |> Day, Zero)
/// // == interval.after(691200000 - 7 * 24 * 60 * 60 * 1_000)
/// 
/// interval.after(25200000)
///   |> sub_interval(6 |> Minute, 5 |> Hour)
/// // == interval.after(25200000 - 6 * 60 * 1_000)
/// 
/// interval.before(360000)
///   |> sub_interval(4 |> DS, 3 |> Second)
/// // == interval.before(360000 - 3 * 1_000)
/// 
/// interval.between(4, 5000)
///   |> sub_interval(2 |> MS, 1 |> CS)
/// // == interval.between(4 - 2, 5000 - 1 * 10)
/// ```
pub fn sub_interval(
  self: Interval,
  lower_bound: TimeUnit,
  upper_bound: TimeUnit,
) -> Interval {
  self |> opr_interval(lower_bound, upper_bound, sub_bound)
}

// ## IntervalBound

fn opr_bound(
  self: IntervalBound,
  bound: TimeUnit,
  opr: fn(IntervalBoundType, TimeUnit) -> IntervalBoundType,
) -> IntervalBound {
  IntervalBound { ..self, bound_type: self.bound_type |> opr(bound) }
}

/// Adds time to an `IntervalBound`. For example:
/// ```aiken
/// interval.after(1234567890000).lower_bound
///   |> add_bound(Zero)
/// // == IntervalBound { bound_type: Finite(1234567890000 + 0), is_inclusive: True }
/// 
/// interval.after(5443200000).upper_bound
///   |> add_bound(8 |> Week)
/// // == IntervalBound { bound_type: PositiveInfinity, is_inclusive: True }
/// 
/// interval.before(691200000).lower_bound
///   |> add_bound(7 |> Day)
/// // == IntervalBound { bound_type: NegativeInfinity, is_inclusive: True }
/// 
/// interval.before(25200000).upper_bound
///   |> add_bound(6 |> Minute)
/// // == IntervalBound { bound_type: Finite(25200000 + 6 * 60 * 1_000), is_inclusive: True }
/// 
/// interval.between(360000, 12780000).lower_bound
///   |> add_bound(3 |> Second)
/// // == IntervalBound { bound_type: Finite(360000 + 3 * 1_000), is_inclusive: True }
/// 
/// interval.between(4, 5000).upper_bound
///   |> add_bound(2 |> MS)
/// // == IntervalBound { bound_type: Finite(5000 + 2), is_inclusive: True }
/// ```
pub fn add_bound(self: IntervalBound, bound: TimeUnit) -> IntervalBound {
  self |> opr_bound(bound, add_finite)
}

/// Subtracts time from an `IntervalBound`. For example:
/// ```aiken
/// interval.after(1234567890000).lower_bound
///   |> sub_bound(Zero)
/// // == IntervalBound { bound_type: Finite(1234567890000 - 0), is_inclusive: True }
/// 
/// interval.after(5443200000).upper_bound
///   |> sub_bound(8 |> Week)
/// // == IntervalBound { bound_type: PositiveInfinity, is_inclusive: True }
/// 
/// interval.before(691200000).lower_bound
///   |> sub_bound(7 |> Day)
/// // == IntervalBound { bound_type: NegativeInfinity, is_inclusive: True }
/// 
/// interval.before(25200000).upper_bound
///   |> sub_bound(6 |> Minute)
/// // == IntervalBound { bound_type: Finite(25200000 - 6 * 60 * 1_000), is_inclusive: True }
/// 
/// interval.between(360000, 12780000).lower_bound
///   |> sub_bound(3 |> Second)
/// // == IntervalBound { bound_type: Finite(360000 - 3 * 1_000), is_inclusive: True }
/// 
/// interval.between(4, 5000).upper_bound
///   |> sub_bound(2 |> MS)
/// // == IntervalBound { bound_type: Finite(5000 - 2), is_inclusive: True }
/// ```
pub fn sub_bound(self: IntervalBound, bound: TimeUnit) -> IntervalBound {
  self |> opr_bound(bound, sub_finite)
}

// ## Finite IntervalBoundType

fn opr_finite(
  self: IntervalBoundType,
  finite: TimeUnit,
  opr: fn(PosixTime, TimeUnit) -> PosixTime,
) -> IntervalBoundType {
  when self is {
    interval.Finite(time) -> time |> opr(finite) |> interval.Finite
    infinite -> infinite
  }
}

/// Adds time to a [finite](https://aiken-lang.github.io/stdlib/aiken/interval.html#IntervalBoundType)
/// `IntervalBoundType`. For example:
/// ```aiken
/// interval.after(1234567890000).lower_bound.bound_type
///   |> add_finite(Zero)
/// // == Finite(1234567890000 + 0)
/// 
/// interval.after(5443200000).upper_bound.bound_type
///   |> add_finite(8 |> Week)
/// // == PositiveInfinity
/// 
/// interval.before(691200000).lower_bound.bound_type
///   |> add_finite(7 |> Day)
/// // == NegativeInfinity
/// 
/// interval.before(25200000).upper_bound.bound_type
///   |> add_finite(6 |> Minute)
/// // == Finite(25200000 + 6 * 60 * 1_000)
/// 
/// interval.between(360000, 12780000).lower_bound.bound_type
///   |> add_finite(3 |> Second)
/// // == Finite(360000 + 3 * 1_000)
/// 
/// interval.between(4, 5000).upper_bound.bound_type
///   |> add_finite(2 |> MS)
/// // == Finite(5000 + 2)
/// ```
pub fn add_finite(
  self: IntervalBoundType,
  finite: TimeUnit,
) -> IntervalBoundType {
  self |> opr_finite(finite, add_time)
}

/// Subtracts time from a [finite](https://aiken-lang.github.io/stdlib/aiken/interval.html#IntervalBoundType)
/// `IntervalBoundType`. For example:
/// ```aiken
/// interval.after(1234567890000).lower_bound.bound_type
///   |> sub_finite(Zero)
/// // == Finite(1234567890000 - 0)
/// 
/// interval.after(5443200000).upper_bound.bound_type
///   |> sub_finite(8 |> Week)
/// // == PositiveInfinity
/// 
/// interval.before(691200000).lower_bound.bound_type
///   |> sub_finite(7 |> Day)
/// // == NegativeInfinity
/// 
/// interval.before(25200000).upper_bound.bound_type
///   |> sub_finite(6 |> Minute)
/// // == Finite(25200000 - 6 * 60 * 1_000)
/// 
/// interval.between(360000, 12780000).lower_bound.bound_type
///   |> sub_finite(3 |> Second)
/// // == Finite(360000 - 3 * 1_000)
/// 
/// interval.between(4, 5000).upper_bound.bound_type
///   |> sub_finite(2 |> MS)
/// // == Finite(5000 - 2)
/// ```
pub fn sub_finite(
  self: IntervalBoundType,
  finite: TimeUnit,
) -> IntervalBoundType {
  self |> opr_finite(finite, sub_time)
}
