import gleam/int
import gleam/list
import gleam/string

pub type Entry {
  Entry(destination: Int, source: Int, length: Int)
}

/// # Format
/// 
/// ```
/// 60 56 37
/// ```
pub fn from_string(input: String) -> Entry {
  let assert [destination, source, length] =
    string.split(input, " ")
    |> list.map(fn(part) {
      let assert Ok(number) = int.parse(part)
      number
    })

  Entry(destination:, source:, length:)
}

pub fn contains(entry: Entry, x: Int) -> Bool {
  entry.source <= x && x < entry.source + entry.length
}

pub fn translate(entry: Entry, x: Int) -> Int {
  x - entry.source + entry.destination
}
