import gleam/float
import gleam/int
import gleam/list
import gleam/string

import year_2023/day_04/card

pub fn solve(input: String) -> String {
  let cards =
    input
    |> string.split("\n")
    |> list.map(card.from_line)

  cards
  |> list.fold(0, fn(acc, card) { acc + points(from_wins: card.wins(of: card)) })
  |> int.to_string()
}

fn points(from_wins wins: Int) -> Int {
  case wins {
    0 -> 0
    _ -> {
      let exponent = int.to_float(wins) -. 1.0
      let assert Ok(power) = 2 |> int.power(of: exponent)
      power |> float.truncate()
    }
  }
}
