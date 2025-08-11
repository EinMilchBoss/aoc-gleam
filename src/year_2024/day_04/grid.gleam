import gleam/dict.{type Dict}
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
