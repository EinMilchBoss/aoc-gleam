import gleam/bool
import gleam/dict
import gleam/function
import gleam/list
import gleam/pair
import gleam/string

import year_2024/day_08/coordinate.{type Coordinate, Coordinate}

pub type Grid {
  Grid(frequencies: List(List(Coordinate)), width: Int, height: Int)
}

pub fn parse(input: String) -> Grid {
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

fn contains(grid: Grid, coordinate: Coordinate) -> Bool {
  use <- bool.guard(coordinate.x < 0 || grid.width <= coordinate.x, False)
  use <- bool.guard(coordinate.y < 0 || grid.height <= coordinate.y, False)

  True
}

pub fn nearest_antinodes_model(
  grid: Grid,
  left: Coordinate,
  right: Coordinate,
) -> List(Coordinate) {
  [
    coordinate.add(left, coordinate.subtract(left, right)),
    coordinate.add(right, coordinate.subtract(right, left)),
  ]
  |> list.filter(contains(grid, _))
}

pub fn all_antinodes_model(
  grid: Grid,
  left: Coordinate,
  right: Coordinate,
) -> List(Coordinate) {
  let lefts = complete_line(grid, left, right)
  let rights = complete_line(grid, right, left)

  [left, right, ..list.append(lefts, rights)]
}

fn complete_line(
  grid: Grid,
  left: Coordinate,
  right: Coordinate,
) -> List(Coordinate) {
  do_complete_line(grid, coordinate.subtract(left, right), left, [])
}

fn do_complete_line(
  grid: Grid,
  step: Coordinate,
  last: Coordinate,
  acc: List(Coordinate),
) -> List(Coordinate) {
  let next = coordinate.add(last, step)

  case contains(grid, next) {
    False -> acc
    True -> do_complete_line(grid, step, next, [next, ..acc])
  }
}
