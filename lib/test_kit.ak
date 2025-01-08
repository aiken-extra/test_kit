use aiken/cbor
use aiken/fuzz
use aiken/primitive/bytearray
use aiken/primitive/string

/// Pretty-print data with label. This function calls
/// [`fuzz.label`](https://aiken-lang.github.io/fuzz/aiken/fuzz.html#label)
/// internally, so it will work with property testing.
pub fn print(label: ByteArray, data: Data) {
  [label |> bytearray.to_string, data |> cbor.diagnostic]
    |> string.join(@": ")
    |> fuzz.label
}
