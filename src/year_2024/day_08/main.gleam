import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/set
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2024, day: 8)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "14"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "34"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let grid = parse_grid(input)

  grid.frequencies
  |> list.flat_map(fn(antennas) {
    antennas
    |> list.combinations(2)
    |> list.flat_map(fn(combination) {
      let assert [left, right] = combination
        as "all combinations have 2 elements"

      get_nearest_antinodes(grid, left, right)
    })
  })
  |> set.from_list()
  |> set.size()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = parse_grid(input)
  echo grid as "grid"

  grid.frequencies
  |> list.flat_map(fn(antennas) {
    echo antennas as "antennas"

    antennas
    |> list.combinations(2)
    |> list.flat_map(fn(combination) {
      let assert [left, right] = combination
        as "all combinations have 2 elements"

      get_all_antinodes(grid, left, right) |> echo as "partial antinodes"
    })
  })
  |> set.from_list()
  |> set.size()
  |> int.to_string()
}

fn get_nearest_antinodes(
  grid: Grid,
  left: Coordinate,
  right: Coordinate,
) -> List(Coordinate) {
  [
    coordinate_add(left, coordinate_subtract(left, right)),
    coordinate_add(right, coordinate_subtract(right, left)),
  ]
  |> list.filter(grid_contains(grid, _))
}

fn do_complete_line(
  grid: Grid,
  step: Coordinate,
  last: Coordinate,
  acc: List(Coordinate),
) -> List(Coordinate) {
  let next = coordinate_add(last, step)
  case grid_contains(grid, next) {
    False -> acc
    True -> do_complete_line(grid, step, next, [next, ..acc])
  }
}

fn get_all_antinodes(
  grid: Grid,
  left: Coordinate,
  right: Coordinate,
) -> List(Coordinate) {
  let lefts = do_complete_line(grid, coordinate_subtract(left, right), left, [])
  let rights =
    do_complete_line(grid, coordinate_subtract(right, left), right, [])

  [left, right, ..list.append(lefts, rights)]
}

fn coordinate_add(left: Coordinate, right: Coordinate) -> Coordinate {
  Coordinate(left.x + right.x, left.y + right.y)
}

fn coordinate_subtract(left: Coordinate, right: Coordinate) -> Coordinate {
  Coordinate(left.x - right.x, left.y - right.y)
}

type Coordinate {
  Coordinate(x: Int, y: Int)
}

type Grid {
  Grid(frequencies: List(List(Coordinate)), width: Int, height: Int)
}

fn parse_grid(input: String) -> Grid {
  let lines = string.split(input, "\n")

  let height = list.length(lines)

  let assert Ok(first) = list.first(lines)
    as "the input contains at least one line"
  let width = first |> string.to_graphemes() |> list.length()

  let frequencies =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes()
      |> list.index_map(fn(grapheme, x) {
        case grapheme {
          "." -> Error(Nil)
          _ -> Ok(#(grapheme, Coordinate(x, y)))
        }
      })
      |> list.filter_map(function.identity)
    })
    |> list.flatten()
    |> list.group(pair.first)
    |> dict.values()
    |> list.map(list.map(_, pair.second))

  Grid(frequencies:, width:, height:)
}

fn grid_contains(grid: Grid, coordinate: Coordinate) -> Bool {
  use <- bool.guard(coordinate.x < 0 || grid.width <= coordinate.x, False)
  use <- bool.guard(coordinate.y < 0 || grid.height <= coordinate.y, False)

  True
}
