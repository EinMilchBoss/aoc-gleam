import gleam/int
import gleam/list
import gleam/option.{type Option}

pub type Submatches =
  List(Option(String))

pub fn parse(submatches: Submatches) -> #(Int, Int) {
  let assert [a, b] =
    submatches
    |> list.map(fn(submatch) {
      let assert option.Some(number) =
        submatch
        |> option.map(fn(string) {
          string |> int.parse() |> option.from_result()
        })
        |> option.flatten()
        as "every submatch consists of a decimal number"

      number
    })
    as "every match contains two decimal number submatches"

  #(a, b)
}
