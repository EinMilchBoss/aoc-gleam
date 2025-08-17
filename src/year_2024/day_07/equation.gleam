import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

import year_2024/day_07/operator.{type Operator}

pub type Equation {
  Equation(result: Int, numbers: List(Int))
}

pub fn parse(line: String) -> Equation {
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

pub fn is_solvable(equation: Equation, with operators: Set(Operator)) {
  do_is_solvable(equation, operators, list.length(equation.numbers) - 1)
}

fn do_is_solvable(
  equation: Equation,
  operators: Set(Operator),
  times: Int,
) -> Bool {
  case times {
    0 -> is_solved(equation)
    _ -> {
      equation
      |> next_possibilities(with: operators)
      |> list.any(do_is_solvable(_, operators, times - 1))
    }
  }
}

fn is_solved(equation: Equation) -> Bool {
  let assert Ok(result) = list.first(equation.numbers)

  equation.result == result
}

fn next_possibilities(
  equation: Equation,
  with operators: Set(Operator),
) -> List(Equation) {
  operators
  |> set.to_list()
  |> list.map(fn(operator) {
    collapse(equation, operator.as_function(operator))
  })
  |> list.filter(is_collapse_possible)
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

fn is_collapse_possible(collapse: Equation) -> Bool {
  let assert Ok(intermediate) = list.first(collapse.numbers)
    as "all equations must have at least one intermediate"

  intermediate <= collapse.result
}
