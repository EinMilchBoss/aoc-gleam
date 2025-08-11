import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/string

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub type Grid {
  Grid(values: Dict(Coordinate, String), width: Int, height: Int)
}

pub fn parse(input: String) -> Grid {
  let lines = string.split(input, "\n")

  let height = list.length(lines)

  let assert Ok(line) = list.first(lines) as "the input has at least one line"
  let width = line |> string.to_graphemes() |> list.length()

  let values =
    lines
    |> list.map(string.to_graphemes)
    |> list.index_map(fn(row, y) {
      row
      |> list.index_map(fn(char, x) { #(Coordinate(x, y), char) })
    })
    |> list.flatten()
    |> dict.from_list()

  Grid(values:, width:, height:)
}

pub fn has_char_at(grid: Grid, coordinate: Coordinate, char: String) -> Bool {
  case dict.get(grid.values, coordinate) {
    Ok(value) if value == char -> True
    _ -> False
  }
}

pub fn is_mas(grid: Grid, coordinate: Coordinate) -> Bool {
  use <- bool.guard(!has_char_at(grid, coordinate, "A"), False)

  is_mas_diagonal_increasing(grid, coordinate)
  && is_mas_diagonal_decreasing(grid, coordinate)
}

fn is_mas_diagonal_increasing(grid: Grid, coordinate: Coordinate) -> Bool {
  is_mas_diagonal(
    grid,
    Coordinate(coordinate.x - 1, coordinate.y - 1),
    Coordinate(coordinate.x + 1, coordinate.y + 1),
  )
}

fn is_mas_diagonal_decreasing(grid: Grid, coordinate: Coordinate) -> Bool {
  is_mas_diagonal(
    grid,
    Coordinate(coordinate.x - 1, coordinate.y + 1),
    Coordinate(coordinate.x + 1, coordinate.y - 1),
  )
}

fn is_mas_diagonal(grid: Grid, left: Coordinate, right: Coordinate) -> Bool {
  let a = has_char_at(grid, left, "M") && has_char_at(grid, right, "S")
  let b = has_char_at(grid, left, "S") && has_char_at(grid, right, "M")

  a || b
}

pub fn count_xmas(grid: Grid, coordinate: Coordinate) -> Int {
  use <- bool.guard(!has_char_at(grid, coordinate, "X"), 0)

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
    Coordinate(..coordinate, x: coordinate.x + 1)
  })
}

pub fn is_xmas_right_to_left(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(..coordinate, x: coordinate.x - 1)
  })
}

pub fn is_xmas_down_to_up(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(..coordinate, y: coordinate.y + 1)
  })
}

pub fn is_xmas_up_to_down(grid: Grid, coordinate: Coordinate) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(..coordinate, y: coordinate.y - 1)
  })
}

pub fn is_xmas_diagonal_forward_increasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(coordinate.x + 1, coordinate.y + 1)
  })
}

pub fn is_xmas_diagonal_forward_decreasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(coordinate.x + 1, coordinate.y - 1)
  })
}

pub fn is_xmas_diagonal_backward_increasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(coordinate.x - 1, coordinate.y + 1)
  })
}

pub fn is_xmas_diagonal_backward_decreasing(
  grid: Grid,
  coordinate: Coordinate,
) -> Bool {
  is_xmas_by_update(grid, coordinate, fn(coordinate) {
    Coordinate(coordinate.x - 1, coordinate.y - 1)
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
