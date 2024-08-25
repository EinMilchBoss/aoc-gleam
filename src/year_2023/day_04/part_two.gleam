import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set
import gleam/string

import year_2023/day_04/card.{type Card}

pub fn solve(input: String) -> String {
  let cards =
    input
    |> string.split("\n")
    |> list.map(card.from_line)

  total_card_amount(cards) |> int.to_string()
}

pub fn total_card_amount(cards cards: List(Card)) -> Int {
  try_again(cards, cards)
}

fn try_again(cards: List(Card), all: List(Card)) {
  case cards {
    [] -> 0
    [current, ..rest] -> {
      // io.debug("Current: " <> int.to_string(current.number))

      let following =
        all
        |> list.drop_while(fn(card) { card.number <= current.number })
      // io.debug("Following: " <> string.inspect(card.numbers(following)))

      let wins = card.wins(current)
      // io.debug("Wins: " <> int.to_string(wins))

      let won = list.take(following, wins)
      // io.debug("Actually won: " <> string.inspect(card.numbers(won)))

      try_again(won, all) + try_again(rest, all) + 1
    }
  }
}
