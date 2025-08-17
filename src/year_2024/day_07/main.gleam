import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

import aoc
import aoc/input
import aoc/part
import year_2024/day_07/equation.{type Equation}
import year_2024/day_07/operator.{type Operator, Add, Concatenate, Multiply}

pub fn main() {
  let input = input.read_files(year: 2024, day: 7)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "3749"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "11387"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let equations = parse_input(input)

  equations
  |> get_calibration_result(with: set.from_list([Add, Multiply]))
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let equations = parse_input(input)

  equations
  |> get_calibration_result(with: set.from_list([Add, Multiply, Concatenate]))
  |> int.to_string()
}

fn parse_input(input: String) -> List(Equation) {
  input |> string.split("\n") |> list.map(equation.parse)
}

fn get_calibration_result(
  equations: List(Equation),
  with operators: Set(Operator),
) -> Int {
  equations
  |> list.filter(equation.is_solvable(_, operators))
  |> list.map(fn(equation) { equation.result })
  |> int.sum()
}
