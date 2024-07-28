import aoc/input
import aoc/part.{type Part}
import gleam/int
import gleam/order
import gleam/string
import gleam/string_builder

pub fn run_fake(part: Part, expected: String) -> String {
  let result =
    part
    |> part.input
    |> input.fake
    |> part.solution(part)
  let part =
    part
    |> part.number
    |> int.to_string

  let test_result = case string.compare(expected, result) {
    order.Eq -> "PASS"
    _ -> "FAIL"
  }

  string_builder.new()
  |> string_builder.append("Part ")
  |> string_builder.append(part)
  |> string_builder.append(" (fake): ")
  |> string_builder.append(result)
  |> string_builder.append("\nResult: ")
  |> string_builder.append(test_result)
  |> string_builder.to_string
}

pub fn run_real(part: Part) -> String {
  let result = part.input(part) |> input.real |> part.solution(part)
  let part = part.number(part) |> int.to_string()

  string_builder.new()
  |> string_builder.append("Part ")
  |> string_builder.append(part)
  |> string_builder.append(" (real): ")
  |> string_builder.append(result)
  |> string_builder.to_string
}
