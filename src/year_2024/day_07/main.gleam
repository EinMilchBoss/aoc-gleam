import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

import aoc
import aoc/input
import aoc/part

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
  |> calculate_calibration_result(with: set.from_list([Add, Multiply]))
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let equations = parse_input(input)

  equations
  |> calculate_calibration_result(
    with: set.from_list([Add, Multiply, Concatenate]),
  )
  |> int.to_string()
}

fn calculate_calibration_result(
  equations: List(Equation),
  with operators: Set(Operator),
) -> Int {
  equations
  |> list.filter(is_solvable(_, with: operators))
  |> list.map(fn(equation) { equation.result })
  |> int.sum()
}

type Operator {
  Add
  Multiply
  Concatenate
}

fn as_function(operator: Operator) -> fn(Int, Int) -> Int {
  case operator {
    Add -> int.add
    Multiply -> int.multiply
    Concatenate -> concatenate
  }
}

fn concatenate(left: Int, right: Int) {
  let assert Ok(offset) =
    int.power(10, int.to_float(get_digit_amount(right)))
    |> result.map(float.truncate)
    as "the base is always 10"

  left * offset + right
}

fn get_digit_amount(number: Int) -> Int {
  do_get_digit_amount(int.absolute_value(number), 1)
}

fn do_get_digit_amount(number: Int, acc: Int) -> Int {
  case number < 10 {
    True -> acc
    False -> do_get_digit_amount(number / 10, acc + 1)
  }
}

fn is_solvable(equation: Equation, with operators: Set(Operator)) -> Bool {
  do_is_solvable([equation], operators, list.length(equation.numbers) - 1)
}

fn do_is_solvable(
  possibilities: List(Equation),
  operators: Set(Operator),
  times: Int,
) -> Bool {
  case times {
    0 -> list.any(possibilities, is_solved)
    _ ->
      do_is_solvable(
        update_possibilties(possibilities, with: operators),
        operators,
        times - 1,
      )
  }
}

fn is_solved(equation: Equation) -> Bool {
  let assert Ok(result) = list.first(equation.numbers)

  equation.result == result
}

fn update_possibilties(
  possibilities: List(Equation),
  with operators: Set(Operator),
) -> List(Equation) {
  do_update_possibilties(possibilities, operators, [])
}

fn do_update_possibilties(
  possibilities: List(Equation),
  operators: Set(Operator),
  acc: List(Equation),
) -> List(Equation) {
  case possibilities {
    [] -> acc
    [possibility, ..rest] ->
      do_update_possibilties(
        rest,
        operators,
        list.append(next_possibilities(possibility, with: operators), acc),
      )
  }
}

fn next_possibilities(
  equation: Equation,
  with operators: Set(Operator),
) -> List(Equation) {
  operators
  |> set.to_list()
  |> list.map(fn(operator) { collapse(equation, as_function(operator)) })
  |> list.filter(is_collapse_possible)
}

fn is_collapse_possible(collapse: Equation) -> Bool {
  let assert Ok(intermediate) = list.first(collapse.numbers)
    as "all equations must have at least one intermediate"

  intermediate <= collapse.result
}

fn collapse(
  equation: Equation,
  operator_function: fn(Int, Int) -> Int,
) -> Equation {
  case equation.numbers {
    [] -> panic as "all equations must have at least one number"
    [_] -> panic as "the end result cannot be collapsed any further"
    [intermediate, next, ..rest] ->
      Equation(..equation, numbers: [
        operator_function(intermediate, next),
        ..rest
      ])
  }
}

type Equation {
  Equation(result: Int, numbers: List(Int))
}

fn parse_input(input: String) -> List(Equation) {
  input |> string.split("\n") |> list.map(parse_equation)
}

fn parse_equation(line: String) -> Equation {
  let assert [result, numbers] = string.split(line, ": ")
    as "every equation has a result"

  let assert Ok(result) = int.parse(result) as "all results are ints"

  let numbers =
    numbers
    |> string.split(" ")
    |> list.map(fn(string) {
      let assert Ok(int) = int.parse(string) as "all values are ints"

      int
    })

  Equation(result:, numbers:)
}
