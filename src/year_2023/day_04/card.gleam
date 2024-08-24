import gleam/int
import gleam/set.{type Set}
import gleam/string

pub type Card {
  Card(winning: Set(Int), owned: Set(Int))
}

pub fn from_line(line line: String) -> Card {
  let assert [_, numbers] = string.split(line, on: ": ")
  let assert [winning, owned] = string.split(numbers, on: " | ")
  Card(parse_numbers(winning), parse_numbers(owned))
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
