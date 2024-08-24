import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string

import year_2023/day_04/card

pub fn solve(input: String) -> String {
  let cards =
    input
    |> string.split("\n")
    |> list.map(card.from_line)

  cards
  |> list.fold(0, fn(acc, card) {
    let points =
      points(set.intersection(of: card.winning, and: card.owned) |> set.size())
    acc + points
  })
  |> int.to_string()
}

fn points(matches: Int) -> Int {
  case matches {
    0 -> 0
    _ -> {
      let assert Ok(power) =
        int.power(2, of: int.to_float(matches) -. 1.0)
        |> result.map(float.truncate)
      power
    }
  }
}
