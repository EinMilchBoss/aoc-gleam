import gleam/function
import gleam/list
import gleam/order
import gleam/string

import year_2023/day_03/engine_part.{type EnginePart}
import year_2023/day_03/position.{type Position, Position}

pub fn parse_positions(input: String) -> List(Position) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(grapheme, x) {
      case string.compare(grapheme, "*") {
        order.Eq -> Ok(Position(x, y))
        _ -> Error(Nil)
      }
    })
  })
  |> list.flatten()
  |> list.filter_map(function.identity)
}

pub fn ratio(first: EnginePart, second: EnginePart) -> Int {
  first.number * second.number
}
