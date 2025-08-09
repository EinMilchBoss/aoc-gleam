import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

import year_2023/day_05/entry.{type EntryRanges}
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
  let seed_ranges = seed_ranges(almanac)

  list.fold(almanac.maps, seed_ranges, fn(acc, map) {
    list.fold(acc, [], fn(_output_ranges, input_range) {
      let entry_ranges_of_map = list.map(map.entries, entry.to_entry_ranges)

      list.find_map(entry_ranges_of_map, fn(entry_ranges) {
        case range.intersection(input_range, source_range) {
          Error(_) -> Ok([input_range])
          Ok(intersection) -> {
            todo
          }
        }

        let offset = destination_range.start - source_range.start

        range.intersection(input_range, source_range)
        |> result.map(range.offset(_, offset))
      })

      bool.lazy_guard()

      // Check if input_range hits a source_range.
      // - False: Add to output_ranges without anything.
      // - True: 
      // -- Split input_range into smaller parts.
      // -- Offset part of intersection.
      // -- Add all parts to the list.

      // Assumption: There are no overlapping `Range`s of `Entry`s in one `Map`.
      case
        list.find_map(ranges_of_entries, fn(ranges_of_entry) {
          let #(source_range, destination_range) = ranges_of_entry
          let offset = destination_range.start - source_range.start

          range.intersection(input_range, source_range)
          |> result.map(range.offset(_, offset))
        })
      {
        Error(_) -> acc
        Ok(offset_intersection) -> {
          [offset_intersection, ..acc]
        }
      }
    })
    list.append(matched, missed)
  })

  todo
}

fn seed_ranges(almanac: Almanac) -> List(Range) {
  almanac.seeds
  |> list.sized_chunk(2)
  |> list.map(fn(seed_range) {
    let assert [start, length] = seed_range
    Range(start:, end_exclusive: start + length)
  })
}
