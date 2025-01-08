//// @hidden

use aiken/fuzz
use test_kit/fuzzy.{
  tuple, tuple3, tuple4, tuple5, tuple6, tuple7, tuple8, tuple9,
}
use test_kit/fuzzy/fuzzer.{data_fuzzer}

// ## Tuple Fuzzers

fn prop_tuple2() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant

  let l_tuple <- fuzz.and_then(tuple(fuzzer_a, fuzzer_b))
  let r_tuple <-
    fuzz.and_then(fuzz.map2(fuzzer_a, fuzzer_b, fn(a, b) { (a, b) }))

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple3() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant

  let l_tuple <- fuzz.and_then(tuple3(fuzzer_a, fuzzer_b, fuzzer_c))
  let r_tuple <-
    fuzz.and_then(
      fuzz.map3(fuzzer_a, fuzzer_b, fuzzer_c, fn(a, b, c) { (a, b, c) }),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple4() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())
  let d <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant
  let fuzzer_d = d |> fuzz.constant

  let l_tuple <- fuzz.and_then(tuple4(fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d))
  let r_tuple <-
    fuzz.and_then(
      fuzz.map4(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fn(a, b, c, d) { (a, b, c, d) },
      ),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple5() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())
  let d <- fuzz.and_then(data_fuzzer())
  let e <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant
  let fuzzer_d = d |> fuzz.constant
  let fuzzer_e = e |> fuzz.constant

  let l_tuple <-
    fuzz.and_then(tuple5(fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e))
  let r_tuple <-
    fuzz.and_then(
      fuzz.map5(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fn(a, b, c, d, e) { (a, b, c, d, e) },
      ),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple6() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())
  let d <- fuzz.and_then(data_fuzzer())
  let e <- fuzz.and_then(data_fuzzer())
  let f <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant
  let fuzzer_d = d |> fuzz.constant
  let fuzzer_e = e |> fuzz.constant
  let fuzzer_f = f |> fuzz.constant

  let l_tuple <-
    fuzz.and_then(
      tuple6(fuzzer_a, fuzzer_b, fuzzer_c, fuzzer_d, fuzzer_e, fuzzer_f),
    )
  let r_tuple <-
    fuzz.and_then(
      fuzz.map6(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fn(a, b, c, d, e, f) { (a, b, c, d, e, f) },
      ),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple7() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())
  let d <- fuzz.and_then(data_fuzzer())
  let e <- fuzz.and_then(data_fuzzer())
  let f <- fuzz.and_then(data_fuzzer())
  let g <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant
  let fuzzer_d = d |> fuzz.constant
  let fuzzer_e = e |> fuzz.constant
  let fuzzer_f = f |> fuzz.constant
  let fuzzer_g = g |> fuzz.constant

  let l_tuple <-
    fuzz.and_then(
      tuple7(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fuzzer_g,
      ),
    )
  let r_tuple <-
    fuzz.and_then(
      fuzz.map7(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fuzzer_g,
        fn(a, b, c, d, e, f, g) { (a, b, c, d, e, f, g) },
      ),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple8() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())
  let d <- fuzz.and_then(data_fuzzer())
  let e <- fuzz.and_then(data_fuzzer())
  let f <- fuzz.and_then(data_fuzzer())
  let g <- fuzz.and_then(data_fuzzer())
  let h <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant
  let fuzzer_d = d |> fuzz.constant
  let fuzzer_e = e |> fuzz.constant
  let fuzzer_f = f |> fuzz.constant
  let fuzzer_g = g |> fuzz.constant
  let fuzzer_h = h |> fuzz.constant

  let l_tuple <-
    fuzz.and_then(
      tuple8(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fuzzer_g,
        fuzzer_h,
      ),
    )
  let r_tuple <-
    fuzz.and_then(
      fuzz.map8(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fuzzer_g,
        fuzzer_h,
        fn(a, b, c, d, e, f, g, h) { (a, b, c, d, e, f, g, h) },
      ),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple9() -> Fuzzer<Bool> {
  let a <- fuzz.and_then(data_fuzzer())
  let b <- fuzz.and_then(data_fuzzer())
  let c <- fuzz.and_then(data_fuzzer())
  let d <- fuzz.and_then(data_fuzzer())
  let e <- fuzz.and_then(data_fuzzer())
  let f <- fuzz.and_then(data_fuzzer())
  let g <- fuzz.and_then(data_fuzzer())
  let h <- fuzz.and_then(data_fuzzer())
  let i <- fuzz.and_then(data_fuzzer())

  let fuzzer_a = a |> fuzz.constant
  let fuzzer_b = b |> fuzz.constant
  let fuzzer_c = c |> fuzz.constant
  let fuzzer_d = d |> fuzz.constant
  let fuzzer_e = e |> fuzz.constant
  let fuzzer_f = f |> fuzz.constant
  let fuzzer_g = g |> fuzz.constant
  let fuzzer_h = h |> fuzz.constant
  let fuzzer_i = i |> fuzz.constant

  let l_tuple <-
    fuzz.and_then(
      tuple9(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fuzzer_g,
        fuzzer_h,
        fuzzer_i,
      ),
    )
  let r_tuple <-
    fuzz.and_then(
      fuzz.map9(
        fuzzer_a,
        fuzzer_b,
        fuzzer_c,
        fuzzer_d,
        fuzzer_e,
        fuzzer_f,
        fuzzer_g,
        fuzzer_h,
        fuzzer_i,
        fn(a, b, c, d, e, f, g, h, i) { (a, b, c, d, e, f, g, h, i) },
      ),
    )

  fuzz.constant(l_tuple == r_tuple)
}

fn prop_tuple2_to_tuple9() -> Fuzzer<Bool> {
  let tuple2_map2 <- fuzz.and_then(prop_tuple2())
  let tuple3_map3 <- fuzz.and_then(prop_tuple3())
  let tuple4_map4 <- fuzz.and_then(prop_tuple4())
  let tuple5_map5 <- fuzz.and_then(prop_tuple5())
  let tuple6_map6 <- fuzz.and_then(prop_tuple6())
  let tuple7_map7 <- fuzz.and_then(prop_tuple7())
  let tuple8_map8 <- fuzz.and_then(prop_tuple8())
  let tuple9_map9 <- fuzz.and_then(prop_tuple9())

  fuzz.constant(and {
      tuple2_map2,
      tuple3_map3,
      tuple4_map4,
      tuple5_map5,
      tuple6_map6,
      tuple7_map7,
      tuple8_map8,
      tuple9_map9,
    })
}

test testing_all_tuple_fuzzers(match via prop_tuple2_to_tuple9()) {
  match
}
