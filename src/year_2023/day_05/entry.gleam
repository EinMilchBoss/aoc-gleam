import gleam/int
import gleam/list
import gleam/string

import year_2023/day_05/range.{type Range, Range}

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

pub type EntryRanges {
  EntryRanges(destination_range: Range, source_range: Range)
}

pub fn to_entry_ranges(entry: Entry) -> EntryRanges {
  EntryRanges(
    destination_range: Range(
      start: entry.destination,
      end_exclusive: entry.destination + entry.length,
    ),
    source_range: Range(
      start: entry.source,
      end_exclusive: entry.source + entry.length,
    ),
  )
}

pub fn get_offset(from this: EntryRanges) -> Int {
  this.destination_range.start - this.source_range.start
}
