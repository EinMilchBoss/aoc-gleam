import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Card {
  Card(number: Int, winning: Set(Int), owned: Set(Int))
}

pub fn from_line(line line: String) -> Card {
  let assert [front, back] = string.split(line, on: ": ")

  let assert [_, number, ..] =
    string.split(front, on: " ")
    |> list.filter(fn(string) { !string.is_empty(string) })
  let assert Ok(number) = number |> string.trim() |> int.parse()

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
  // and `pop_map()` instead, albeit a bit less readable.
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
