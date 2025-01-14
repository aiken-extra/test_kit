use aiken/fuzz

// ## Tuple Fuzzers

/// A convenient way of generating tuples instead of doing [`map2`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map2)
/// ```aiken
/// fuzz.map2(
///   fuzzer_a, fuzzer_b,
///   fn(a, b) { (a, b) }
/// )
/// ```
pub fn tuple(a: Fuzzer<a>, b: Fuzzer<b>) -> Fuzzer<(a, b)> {
  let a, b <- fuzz.map2(a, b)
  (a, b)
}

/// A convenient way of generating tuple3 instead of doing [`map3`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map3)
/// ```aiken
/// fuzz.map3(
///   fuzzer_a, fuzzer_b, fuzzer_c,
///   fn(a, b, c) { (a, b, c) }
/// )
/// ```
pub fn tuple3(a: Fuzzer<a>, b: Fuzzer<b>, c: Fuzzer<c>) -> Fuzzer<(a, b, c)> {
  let a, b, c <- fuzz.map3(a, b, c)
  (a, b, c)
}

/// A convenient way of generating tuple4 instead of doing [`map4`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map4)
/// ```aiken
/// fuzz.map4(
///   fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d,
///   fn(a, b, c, d) { (a, b, c, d) }
/// )
/// ```
pub fn tuple4(
  a: Fuzzer<a>,
  b: Fuzzer<b>,
  c: Fuzzer<c>,
  d: Fuzzer<d>,
) -> Fuzzer<(a, b, c, d)> {
  let a, b, c, d <- fuzz.map4(a, b, c, d)
  (a, b, c, d)
}

/// A convenient way of generating tuple5 instead of doing [`map5`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map5)
/// ```aiken
/// fuzz.map5(
///   fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e,
///   fn(a, b, c, d, e) { (a, b, c, d, e) }
/// )
/// ```
pub fn tuple5(
  a: Fuzzer<a>,
  b: Fuzzer<b>,
  c: Fuzzer<c>,
  d: Fuzzer<d>,
  e: Fuzzer<e>,
) -> Fuzzer<(a, b, c, d, e)> {
  let a, b, c, d, e <- fuzz.map5(a, b, c, d, e)
  (a, b, c, d, e)
}

/// A convenient way of generating tuple6 instead of doing [`map6`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map6)
/// ```aiken
/// fuzz.map6(
///   fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e, fuzzer_f,
///   fn(a, b, c, d, e, f) { (a, b, c, d, e, f) }
/// )
/// ```
pub fn tuple6(
  a: Fuzzer<a>,
  b: Fuzzer<b>,
  c: Fuzzer<c>,
  d: Fuzzer<d>,
  e: Fuzzer<e>,
  f: Fuzzer<f>,
) -> Fuzzer<(a, b, c, d, e, f)> {
  let a, b, c, d, e, f <- fuzz.map6(a, b, c, d, e, f)
  (a, b, c, d, e, f)
}

/// A convenient way of generating tuple7 instead of doing [`map7`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map7)
/// ```aiken
/// fuzz.map7(
///   fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e, fuzzer_f, fuzzer_g,
///   fn(a, b, c, d, e, f, g) { (a, b, c, d, e, f, g) }
/// )
/// ```
pub fn tuple7(
  a: Fuzzer<a>,
  b: Fuzzer<b>,
  c: Fuzzer<c>,
  d: Fuzzer<d>,
  e: Fuzzer<e>,
  f: Fuzzer<f>,
  g: Fuzzer<g>,
) -> Fuzzer<(a, b, c, d, e, f, g)> {
  let a, b, c, d, e, f, g <- fuzz.map7(a, b, c, d, e, f, g)
  (a, b, c, d, e, f, g)
}

/// A convenient way of generating tuple8 instead of doing [`map8`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map8)
/// ```aiken
/// fuzz.map8(
///   fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e, fuzzer_f, fuzzer_g, fuzzer_h,
///   fn(a, b, c, d, e, f, g, h) { (a, b, c, d, e, f, g, h) }
/// )
/// ```
pub fn tuple8(
  a: Fuzzer<a>,
  b: Fuzzer<b>,
  c: Fuzzer<c>,
  d: Fuzzer<d>,
  e: Fuzzer<e>,
  f: Fuzzer<f>,
  g: Fuzzer<g>,
  h: Fuzzer<h>,
) -> Fuzzer<(a, b, c, d, e, f, g, h)> {
  let a, b, c, d, e, f, g, h <- fuzz.map8(a, b, c, d, e, f, g, h)
  (a, b, c, d, e, f, g, h)
}

/// A convenient way of generating tuple9 instead of doing [`map9`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#map9)
/// ```aiken
/// fuzz.map9(
///   fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e, fuzzer_f, fuzzer_g, fuzzer_h, fuzzer_i,
///   fn(a, b, c, d, e, f, g, h, i) { (a, b, c, d, e, f, g, h, i) }
/// )
/// ```
pub fn tuple9(
  a: Fuzzer<a>,
  b: Fuzzer<b>,
  c: Fuzzer<c>,
  d: Fuzzer<d>,
  e: Fuzzer<e>,
  f: Fuzzer<f>,
  g: Fuzzer<g>,
  h: Fuzzer<h>,
  i: Fuzzer<i>,
) -> Fuzzer<(a, b, c, d, e, f, g, h, i)> {
  let a, b, c, d, e, f, g, h, i <- fuzz.map9(a, b, c, d, e, f, g, h, i)
  (a, b, c, d, e, f, g, h, i)
}

// ## Unique Fuzzers

/// Generates a list of `n` unique elements from the given fuzzer.
pub fn unique(fuzzer: Fuzzer<a>, count n: Int) -> Fuzzer<List<a>> {
  fuzzer |> fuzz.set_between(n, n)
}

/// Generates a tuple of 2 unique elements from the given fuzzer.
pub fn unique2(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a)> {
  expect [a, b] <- fuzz.map(unique(fuzzer, 2))
  (a, b)
}

/// Generates a tuple of 3 unique elements from the given fuzzer.
pub fn unique3(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a)> {
  expect [a, b, c] <- fuzz.map(unique(fuzzer, 3))
  (a, b, c)
}

/// Generates a tuple of 4 unique elements from the given fuzzer.
pub fn unique4(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a, a)> {
  expect [a, b, c, d] <- fuzz.map(unique(fuzzer, 4))
  (a, b, c, d)
}

/// Generates a tuple of 5 unique elements from the given fuzzer.
pub fn unique5(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a, a, a)> {
  expect [a, b, c, d, e] <- fuzz.map(unique(fuzzer, 5))
  (a, b, c, d, e)
}

/// Generates a tuple of 6 unique elements from the given fuzzer.
pub fn unique6(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a, a, a, a)> {
  expect [a, b, c, d, e, f] <- fuzz.map(unique(fuzzer, 6))
  (a, b, c, d, e, f)
}

/// Generates a tuple of 7 unique elements from the given fuzzer.
pub fn unique7(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a, a, a, a, a)> {
  expect [a, b, c, d, e, f, g] <- fuzz.map(unique(fuzzer, 7))
  (a, b, c, d, e, f, g)
}

/// Generates a tuple of 8 unique elements from the given fuzzer.
pub fn unique8(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a, a, a, a, a, a)> {
  expect [a, b, c, d, e, f, g, h] <- fuzz.map(unique(fuzzer, 8))
  (a, b, c, d, e, f, g, h)
}

/// Generates a tuple of 9 unique elements from the given fuzzer.
pub fn unique9(fuzzer: Fuzzer<a>) -> Fuzzer<(a, a, a, a, a, a, a, a, a)> {
  expect [a, b, c, d, e, f, g, h, i] <- fuzz.map(unique(fuzzer, 9))
  (a, b, c, d, e, f, g, h, i)
}
