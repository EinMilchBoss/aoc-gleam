import gleam/list
import gleam/string

import year_2023/day_05/entry.{type Entry}

pub type Map {
  Map(entries: List(Entry))
}

/// # Format
/// 
/// ```
/// a-to-b map:
/// 60 56 37
/// 56 93 4
/// ```
pub fn from_string(input: String) -> Map {
  let entries =
    input
    |> string.split("\n")
    |> list.drop(1)
    |> list.map(entry.from_string)

  Map(entries:)
}

pub fn translate(map: Map, seed: Int) -> Int {
  case list.find(map.entries, entry.contains(_, seed)) {
    Error(_) -> seed
    Ok(entry) -> entry.translate(entry, seed)
  }
}
