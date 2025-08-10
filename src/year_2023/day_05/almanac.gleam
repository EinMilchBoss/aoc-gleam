import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

import year_2023/day_05/entry.{type Entry, type EntryRanges}
import year_2023/day_05/map.{type Map}
import year_2023/day_05/range.{type Range, Range}

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

/// # Visualization
/// 
/// ```
/// ┌──┬────┐    ┌─┬───┬───┐     ┌─────┬────┐  ┌─────┬───┐ 
/// │  │    │    │ │   │   │     │     │    │  │     │   │ 
/// │  ▼    ▼    │ │   ▼   ▼     ▼     ▼    ▼  ▼     ▼   │ 
/// │  ┌──┬────┐ │ │   ┌─────────┐     ┌────┬─────────┐  │ 
/// │  │  │    │ │ │   │         │     │    │         │  │ 
/// │  │  ▼    ▼ ▼ ▼   │         ▼     ▼    ▼         │  │ 
/// │  │  ┌────────┐   │        ┌───────────┐         │  │ 
/// │  │  │        │   │        │           │         │  │ 
/// ▼  ▼  ▼        ▼   ▼        ▼           ▼         ▼  ▼ 
/// ```
pub fn translate_seed_ranges(almanac: Almanac) {
  let input_ranges = seed_ranges(almanac)

  translate_seed_ranges_layer(input_ranges, [])

  todo
}

fn translate_seed_ranges_layer(
  input_ranges: List(Range),
  output_ranges: List(Range),
) -> List(Range) {
  case input_ranges {
    [input_range, ..rest] -> {
      let ranges = translate_seed_ranges_src(input_range, [])
      translate_seed_ranges_layer(rest, list.concat([ranges, output_ranges]))
    }
    [] -> todo
  }
}

fn translate_seed_ranges_src(
  src_range: Range,
  intersections: List(Range),
) -> List(Range) {
  todo
}

pub fn seed_ranges(almanac: Almanac) -> List(Range) {
  almanac.seeds
  |> list.sized_chunk(2)
  |> list.map(fn(seed_range) {
    let assert [start, length] = seed_range
    Range(start:, end_exclusive: start + length)
  })
}
