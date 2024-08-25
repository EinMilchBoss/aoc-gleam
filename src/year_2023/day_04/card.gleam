import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/set.{type Set}
import gleam/string

pub type Card {
  Card(number: Int, winning: Set(Int), owned: Set(Int))
}

pub fn from_line(line line: String) -> Card {
  let assert [front, back] = string.split(line, on: ": ")

  let assert [_, number, ..] =
    front
    |> string.split(on: " ")
    |> list.filter(fn(string) {
      string
      |> string.is_empty()
      |> bool.negate()
    })
  let assert Ok(number) = number |> int.parse()

  let assert [winning, owned] = string.split(back, on: " | ")
  let winning = parse_numbers(winning)
  let owned = parse_numbers(owned)

  Card(number:, winning:, owned:)
}

fn parse_numbers(numbers: String) -> Set(Int) {
  do_parse_numbers(from: numbers, into: set.new())
}

fn do_parse_numbers(from numbers: String, into acc: Set(Int)) -> Set(Int) {
  // This function could potentially be improved by using `List(String)` 
  // and `pop_map()` instead, but that would be less readable.
  case
    numbers
    |> string.slice(at_index: 0, length: 2)
    |> string.trim_left()
    |> int.parse()
  {
    Error(_) -> acc
    Ok(number) ->
      do_parse_numbers(
        from: string.drop_left(numbers, up_to: 3),
        into: set.insert(into: acc, this: number),
      )
  }
}

pub fn wins(of card: Card) -> Int {
  set.intersection(of: card.winning, and: card.owned) |> set.size()
}

pub fn total_card_amount(of cards: List(Card)) -> Int {
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
          let copies = list.take(from: possible, up_to: wins(of: instance))
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
