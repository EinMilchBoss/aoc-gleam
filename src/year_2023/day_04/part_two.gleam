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
  |> card.total_card_amount()
  |> int.to_string()
}
