import gleam/int
import gleam/list
import gleam/string

import year_2023/day_05/map.{type Map}

pub type Almanac {
  Almanac(seeds: List(Int), maps: List(Map))
}

/// # Format
/// 
/// ```
/// seeds: 79 14 55 13
/// 
/// a-to-b map:
/// 60 56 37
/// 56 93 4
/// 
/// b-to-c map:
/// 60 56 37
/// 56 93 4
/// ```
pub fn from_string(input: String) -> Almanac {
  let assert [seeds, ..maps] = string.split(input, "\n\n")

  let seeds = parse_seeds(seeds)
  let maps = list.map(maps, map.from_string)

  Almanac(seeds:, maps:)
}

/// # Format
/// 
/// ```
/// seeds: 79 14 55 13
/// ```
fn parse_seeds(input: String) -> List(Int) {
  let assert [_, numbers] = string.split(input, ": ")

  numbers
  |> string.split(" ")
  |> list.map(fn(number) {
    let assert Ok(seed) = int.parse(number)
    seed
  })
}

pub fn translate_seeds(almanac: Almanac) -> List(Int) {
  list.fold(almanac.maps, almanac.seeds, fn(acc, map) {
    list.map(acc, map.translate(map, _))
  })
}
