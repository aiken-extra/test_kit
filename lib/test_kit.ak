use aiken/cbor
use aiken/fuzz
use aiken/primitive/bytearray
use aiken/primitive/string

pub type Any =
  Data

/// A convenient way of upcasting any serialisable type to `Data`
/// instead of doing `let data: Data = any`
pub fn to_data(any: Any) -> Data {
  let data: Data = any
  data
}

/// Pretty-print data with label. This function calls
/// [`fuzz.label`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#label)
/// internally, so it will work with property testing.
pub fn print(label: ByteArray, data: Data) {
  [label |> bytearray.to_string, data |> cbor.diagnostic]
    |> string.join(@": ")
    |> fuzz.label
}
