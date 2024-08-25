import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string

import year_2023/day_04/card.{type Card}

pub fn solve(input: String) -> String {
  let cards =
    input
    |> string.split("\n")
    |> list.map(card.from_line)

  // 5 matches for Card 10: 11, 12, 13, 14, 15 again.
  // #(Instance, Card)
  // Everything has one instance in the beginning.
  // There is **no** cycle.
  // 1: 4 (2, 3, 4, 5)
  // 2 2: 2 (3, 4)
  // 3 3 3: 4 (4, 5, 6, 7)
  // 4 4 4 4: 0 ()
  // 5 5 5: 2 (6, 7)
  // 6 6 6: 0 ()
  // 7 7 7: 0 ()

  total_card_amount(cards) |> int.to_string()
}

pub fn total_card_amount(cards cards: List(Card)) -> Int {
  try_again(cards, cards)
  //try_something(originals: cards, instances: [], following: [], card_amount: 0)
}

// a: b, c
// b: c, d
// c: d
// d: -
// d: -
// b: c, d
// 

fn separate(cards: List(Card), acc: Int) {
  case cards {
    [] -> acc
    [card, ..rest] -> {
      let wins = wins(card)

      let amount = separate(rest, acc + 1)

      wins * amount
    }
  }
}

fn do_total_card_amount(
  originals originals: List(Card),
  instances instances: List(Card),
  following following: List(Card),
  cache cache: Dict(Card, Int),
  card_amount acc: Int,
) -> Int {
  case instances {
    // Firstly, go through all instances.
    [instance, ..rest_instances] -> {
      case following {
        // "Cards will never make you copy a card past the end of the table.""
        [] -> acc
        [_, ..next_following] -> {
          // Process the current instance if not already processed (vertical).
          let card_amount = case dict.get(cache, instance) {
            Ok(card_amount) -> card_amount
            Error(_) -> {
              let wins = wins(instance)
              let next_instances = list.take(from: following, up_to: wins)

              io.debug("vertical")
              do_total_card_amount(
                originals:,
                instances: next_instances,
                following: next_following,
                cache:,
                card_amount: acc + 1,
              )
            }
          }

          // Cache the result.
          let next_cache =
            dict.insert(into: cache, for: instance, insert: card_amount)

          // Repeat for the next instance (horizontal).
          io.debug("horizontal")
          do_total_card_amount(
            originals:,
            instances: rest_instances,
            following: next_following,
            cache: next_cache,
            card_amount:,
          )
        }
      }
    }
    // Secondly, proceed with the originals.
    [] -> {
      case originals {
        [] -> acc
        [original, ..rest_originals] -> {
          io.debug("next")
          do_total_card_amount(
            originals: rest_originals,
            instances: [original],
            following: rest_originals,
            cache:,
            card_amount: acc,
          )
        }
      }
    }
  }
}

// 1, 2, 3, 4, 5, 6
// 1: 2
// 2: 4
// 3: 2
// 4: 0
// 5: 0

// 1: 2, 3
// 2: 3, 4, 5, 6
// 3: 4, 5
// 4: -
// 5: -

// 1: 2, 3
// 2: 3, 4, 5, 6
// 2: 3, 4, 5, 6
// 3: 4, 5
// 3: 4, 5
// 3: 4, 5
// 3: 4, 5
// 4: -
// 4: -
// 4: -
// 4: -
// 4: -
// 4: -
// 4: -
// 5: -
// 5: -
// 5: -
// 5: -
// 5: -
// 5: -
// 5: -
fn try_again(cards: List(Card), all: List(Card)) {
  case cards {
    [] -> 0
    [current, ..rest] -> {
      // io.debug("Current: " <> int.to_string(current.number))

      let following =
        all
        |> list.drop_while(fn(card) { card.number <= current.number })
      // io.debug("Following: " <> string.inspect(card.numbers(following)))

      let wins = wins(current)
      // io.debug("Wins: " <> int.to_string(wins))

      let won = list.take(following, wins)
      // io.debug("Actually won: " <> string.inspect(card.numbers(won)))

      try_again(won, all) + try_again(rest, all) + 1
    }
  }
}

// -> [#(1, 1), #(2, 2), #(3, 3), #(3, 4), ]

fn try_something(
  originals originals: List(Card),
  instances instances: List(Card),
  following following: List(Card),
  card_amount acc: Int,
) -> Int {
  case instances {
    // Firstly, go through all instances.
    [instance, ..rest_instances] -> {
      case following {
        // "Cards will never make you copy a card past the end of the table.""
        [] -> acc
        [_, ..next_following] -> {
          let card_amount = acc + 1

          // Process the current instance (vertical).
          let wins = wins(instance)
          let next_instances = list.take(from: following, up_to: wins)

          io.debug("vertical")
          let card_amount =
            try_something(
              originals:,
              instances: next_instances,
              following: next_following,
              card_amount:,
            )

          // Repeat for the next instance (horizontal).
          io.debug("horizontal")
          try_something(
            originals:,
            instances: rest_instances,
            following: next_following,
            card_amount:,
          )
        }
      }
    }
    // Secondly, proceed with the originals.
    [] -> {
      case originals {
        [] -> acc
        [original, ..rest_originals] -> {
          io.debug("next")
          try_something(
            originals: rest_originals,
            instances: [original],
            following: rest_originals,
            card_amount: acc,
          )
        }
      }
    }
  }
}

fn wins(card: Card) -> Int {
  set.intersection(of: card.winning, and: card.owned) |> set.size()
}
