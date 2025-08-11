import aoc/input.{type Input}
import aoc/part.{type Part}
import gleam/int
import gleam/order
import gleam/string
import gleam/string_tree as st

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

  st.new()
  |> st.append("Part ")
  |> st.append(part)
  |> st.append(" (fake): ")
  |> st.append(result)
  |> st.append(" (Result: ")
  |> st.append(test_result)
  |> st.append(")")
  |> st.to_string()
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

  st.new()
  |> st.append("Part ")
  |> st.append(part)
  |> st.append(" (real): ")
  |> st.append(result)
  |> st.to_string()
}
