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
