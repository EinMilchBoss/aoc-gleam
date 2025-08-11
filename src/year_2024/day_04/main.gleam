import gleam/bool
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc
import aoc/input
import aoc/part
import year_2024/day_04/grid.{type Coordinate, type Grid}

pub fn main() {
  let input = input.read_files(year: 2024, day: 4)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "18"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "9"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let grid = grid.parse(input)

  grid.values
  |> dict.keys()
  |> list.map(count_xmas(grid, _))
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = grid.parse(input)

  grid.values
  |> dict.keys()
  |> list.count(is_mas(grid, _))
  |> int.to_string()
}

fn is_mas(grid: Grid, coordinate: Coordinate) -> Bool {
  is_mas_diagonal_increasing(grid, coordinate)
  && is_mas_diagonal_decreasing(grid, coordinate)
}

fn is_mas_diagonal_increasing(grid: Grid, coordinate: Coordinate) -> Bool {
  is_mas_diagonal(
    grid,
    coordinate,
    grid.Coordinate(coordinate.x - 1, coordinate.y - 1),
    grid.Coordinate(coordinate.x + 1, coordinate.y + 1),
  )
}

fn is_mas_diagonal_decreasing(grid: Grid, coordinate: Coordinate) -> Bool {
  is_mas_diagonal(
    grid,
    coordinate,
    grid.Coordinate(coordinate.x - 1, coordinate.y + 1),
    grid.Coordinate(coordinate.x + 1, coordinate.y - 1),
  )
}

fn is_mas_diagonal(
  grid: Grid,
  coordinate: Coordinate,
  left: Coordinate,
  right: Coordinate,
) -> Bool {
  use <- bool.guard(!grid.has_char_at(grid, coordinate, "A"), False)

  let a =
    grid.has_char_at(grid, left, "M") && grid.has_char_at(grid, right, "S")
  let b =
    grid.has_char_at(grid, left, "S") && grid.has_char_at(grid, right, "M")

  a || b
}

pub fn count_xmas(grid: Grid, coordinate: Coordinate) -> Int {
  use <- bool.guard(!grid.has_char_at(grid, coordinate, "X"), 0)

  [
    is_xmas_left_to_right(grid, coordinate),
    is_xmas_right_to_left(grid, coordinate),
    is_xmas_down_to_up(grid, coordinate),
    is_xmas_up_to_down(grid, coordinate),
    is_xmas_diagonal_forward_increasing(grid, coordinate),
    is_xmas_diagonal_forward_decreasing(grid, coordinate),
    is_xmas_diagonal_backward_increasing(grid, coordinate),
    is_xmas_diagonal_backward_decreasing(grid, coordinate),
  ]
  |> list.count(function.identity)
}

pub fn is_xmas_left_to_right(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(..coordinate, x: coordinate.x + 1)
  })
}

pub fn is_xmas_right_to_left(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(..coordinate, x: coordinate.x - 1)
  })
}

pub fn is_xmas_down_to_up(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(..coordinate, y: coordinate.y + 1)
  })
}

pub fn is_xmas_up_to_down(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(..coordinate, y: coordinate.y - 1)
  })
}

pub fn is_xmas_diagonal_forward_increasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(coordinate.x + 1, coordinate.y + 1)
  })
}

pub fn is_xmas_diagonal_forward_decreasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(coordinate.x + 1, coordinate.y - 1)
  })
}

pub fn is_xmas_diagonal_backward_increasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(coordinate.x - 1, coordinate.y + 1)
  })
}

pub fn is_xmas_diagonal_backward_decreasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    grid.Coordinate(coordinate.x - 1, coordinate.y - 1)
  })
}

fn is_xmas_by_update(
  grid: Grid,
  coordinate: Coordinate,
  update: fn(Coordinate) -> Coordinate,
) -> Bool {
  do_is_xmas_by_update(grid, coordinate, update, "XMAS")
}

fn do_is_xmas_by_update(
  grid: Grid,
  coordinate: Coordinate,
  update: fn(Coordinate) -> Coordinate,
  word: String,
) -> Bool {
  case string.pop_grapheme(word) {
    // We went through the entire word successfully.
    Error(_) -> True
    Ok(#(expected, rest)) -> {
      case dict.get(grid.values, coordinate) {
        Ok(actual) if actual == expected ->
          do_is_xmas_by_update(grid, update(coordinate), update, rest)
        // Either went out of the grid or current character did not match with word character.
        _ -> False
      }
    }
  }
}
