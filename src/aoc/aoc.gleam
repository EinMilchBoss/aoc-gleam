import aoc/input.{type Input}
import aoc/part.{type Part}
import gleam/int
import gleam/order
import gleam/string
import gleam/string_builder as sb

pub fn run_fake_one(part: Part, expected expected: String) -> String {
  run_fake(part, expected:, with: input.fake_one)
}

pub fn run_fake_two(part: Part, expected expected: String) -> String {
  run_fake(part, expected:, with: input.fake_two)
}

@internal
pub fn run_fake(
  part: Part,
  expected expected: String,
  with fake: fn(Input) -> String,
) -> String {
  let result =
    part
    |> part.input()
    |> fake()
    |> part.solution(part)
  let part =
    part
    |> part.number()
    |> int.to_string()

  let test_result = case string.compare(expected, result) {
    order.Eq -> "PASS"
    _ -> "FAIL"
  }

  sb.new()
  |> sb.append("Part ")
  |> sb.append(part)
  |> sb.append(" (fake): ")
  |> sb.append(result)
  |> sb.append(" (Result: ")
  |> sb.append(test_result)
  |> sb.append(")")
  |> sb.to_string()
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

  sb.new()
  |> sb.append("Part ")
  |> sb.append(part)
  |> sb.append(" (real): ")
  |> sb.append(result)
  |> sb.to_string()
}
