import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string

import year_2023/day_04/card.{type Card}

pub fn solve(input: String) -> String {
  let cards =
    input
    |> string.split("\n")
    |> list.map(card.from_line)

  cards
  |> total_card_amount()
  |> int.to_string()
}

pub fn total_card_amount(cards cards: List(Card)) -> Int {
  do_total_card_amount(
    of: cards,
    with_next: list.drop(cards, 1),
    cached: dict.new(),
  )
  |> pair.first()
}

fn do_total_card_amount(
  of cards: List(Card),
  with_next possible: List(Card),
  cached cache: Dict(Int, Int),
) -> #(Int, Dict(Int, Int)) {
  case cards {
    [] -> #(0, cache)
    [instance, ..rest_instances] -> {
      // Remove the first entry for future processing.
      // We would end up in an infinite loop because we would
      // copy the same card over and over again.
      let next_possible = list.drop(from: possible, up_to: 1)

      // DFS for all copies based on the current instance's amount of wins.
      let #(depth, depth_cache) = case cache |> dict.get(instance.number) {
        Ok(memoized) -> #(memoized, cache)
        Error(_) -> {
          let copies = possible |> list.take(card.wins(instance))
          do_total_card_amount(
            of: copies,
            with_next: next_possible,
            cached: cache,
          )
        }
      }

      // Merge the current and past results to our cache,
      // so we don't lose the progress of our memoization.
      let updated_cache =
        cache
        |> dict.merge(depth_cache)
        |> dict.insert(instance.number, depth)

      // Continue to use the cache for all horizontal instances.
      // Vertical instances are copies of the horizontal ones, so
      // cache hits are guaranteed as long as a copy was created earlier.
      let #(breadth, _) =
        do_total_card_amount(
          of: rest_instances,
          with_next: next_possible,
          cached: updated_cache,
        )

      #(depth + breadth + 1, updated_cache)
    }
  }
}
