import aoc/input.{type Input}
import aoc/part.{type Part}
import gleam/int
import gleam/order
import gleam/string
import gleam/string_builder

pub fn run_fake1(part: Part, expected: String) -> String {
  run_fake(part, expected, input.fake_one)
}

pub fn run_fake2(part: Part, expected: String) -> String {
  run_fake(part, expected, input.fake_two)
}

pub fn run_fake(
  part: Part,
  expected: String,
  get_fake: fn(Input) -> String,
) -> String {
  let result =
    part
    |> part.input()
    |> get_fake()
    |> part.solution(part)
  let part =
    part
    |> part.number()
    |> int.to_string()

  let test_result = case string.compare(expected, result) {
    order.Eq -> "PASS"
    _ -> "FAIL"
  }

  string_builder.new()
  |> string_builder.append("Part ")
  |> string_builder.append(part)
  |> string_builder.append(" (fake): ")
  |> string_builder.append(result)
  |> string_builder.append("(Result: ")
  |> string_builder.append(test_result)
  |> string_builder.append(")")
  |> string_builder.to_string()
}

pub fn run_real(part: Part) -> String {
  let result =
    part
    |> part.input()
    |> input.real()
    |> part.solution(part)
  let part =
    part
    |> part.number()
    |> int.to_string()

  string_builder.new()
  |> string_builder.append("Part ")
  |> string_builder.append(part)
  |> string_builder.append(" (real): ")
  |> string_builder.append(result)
  |> string_builder.to_string()
}
