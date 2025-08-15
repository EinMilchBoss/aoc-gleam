import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

pub type Rules =
  Dict(Int, Set(Int))

pub fn parse(input: String) -> Dict(Int, Set(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [left, right] =
      line
      |> string.split("|")
      |> list.map(fn(string) {
        let assert Ok(int) = string |> int.parse()
          as "rules consist of integers"

        int
      })
      as "every rule has exactly 2 ints"

    #(left, right)
  })
  |> list.fold(dict.new(), fn(dict, pair) {
    let #(key, value) = pair

    dict.upsert(dict, key, fn(previous) {
      case previous {
        None -> set.from_list([value])
        Some(previous) -> set.insert(previous, value)
      }
    })
  })
}
