import gleam/function
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

import year_2023/day_03/position.{type Position}

pub fn parse_positions(input: String) -> List(Position) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(grapheme, x) {
      case !is_empty(grapheme) && !is_number(grapheme) {
        True -> Ok(position.Position(x, y))
        False -> Error(Nil)
      }
    })
  })
  |> list.flatten()
  |> list.filter_map(function.identity)
}

fn is_number(grapheme: String) -> Bool {
  grapheme
  |> int.parse()
  |> result.is_ok()
}

fn is_empty(grapheme: String) -> Bool {
  string.compare(grapheme, ".") == order.Eq
}
