import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn solve(input: String) -> String {
  let almanac = parse_almanac(input)

  io.debug(almanac)

  let assert Ok(smallest_location) =
    translate_seeds(almanac) |> list.reduce(int.min)
  int.to_string(smallest_location)
}

fn translate_seeds(almanac: Almanac) -> List(Int) {
  almanac.maps
  |> list.fold(almanac.seeds, fn(acc, map) {
    list.map(acc, translate_seed(map, _))
  })
}

fn translate_seed(map: Map, seed: Int) -> Int {
  case list.find(map.entries, contains(_, seed)) {
    Error(_) -> seed
    Ok(entry) -> translate(entry, seed)
  }
}

type Almanac {
  Almanac(seeds: List(Int), maps: List(Map))
}

type Map {
  Map(entries: List(Entry))
}

pub type Entry {
  Entry(destination: Int, source: Int, length: Int)
}

pub fn contains(entry: Entry, x: Int) -> Bool {
  entry.source <= x && x < entry.source + entry.length
}

pub fn translate(entry: Entry, x: Int) -> Int {
  x - entry.source + entry.destination
}

/// # Format
/// seeds: 79 14 55 13
/// 
/// a-to-b map:
/// 60 56 37
/// 56 93 4
/// 
/// b-to-c map:
/// 60 56 37
/// 56 93 4
fn parse_almanac(input: String) -> Almanac {
  let assert [seeds, ..maps] = string.split(input, "\n\n")

  let seeds = parse_seeds(seeds)
  let maps = maps |> list.map(parse_map)

  Almanac(seeds:, maps:)
}

/// # Format
/// seeds: 79 14 55 13
fn parse_seeds(input: String) -> List(Int) {
  let assert [_, numbers] = string.split(input, ": ")
  string.split(numbers, " ")
  |> list.map(fn(number) {
    let assert Ok(seed) = int.parse(number)
    seed
  })
}

/// # Format
/// a-to-b map:
/// 60 56 37
/// 56 93 4
fn parse_map(input: String) -> Map {
  let entries =
    string.split(input, "\n") |> list.drop(1) |> list.map(parse_entry)

  Map(entries:)
}

/// # Format
/// 60 56 37
fn parse_entry(input: String) -> Entry {
  let assert [destination, source, length] =
    string.split(input, " ")
    |> list.map(fn(part) {
      let assert Ok(number) = int.parse(part)
      number
    })

  Entry(destination:, source:, length:)
}
