import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/regexp
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2024, day: 3)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "161"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "48"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(re) = regexp.compile("mul\\((\\d+),(\\d+)\\)", options)

  let pairs =
    regexp.scan(re, input)
    |> list.map(fn(match) { parse_submatches(match.submatches) })

  pairs |> sum_pair_products() |> int.to_string()
}

fn part_two(input: String) -> String {
  let pairs =
    input
    |> parse_instructions()
    |> reduce_instructions()
    |> list.map(fn(mul_instruction) {
      let assert Ok(pair) = instruction_to_pair(mul_instruction)
        as "only `Instruction`s of variant `Multiply` are left"

      pair
    })

  pairs |> sum_pair_products() |> int.to_string()
}

fn sum_pair_products(pairs: List(#(Int, Int))) -> Int {
  pairs
  |> list.map(fn(pair) { pair.0 * pair.1 })
  |> int.sum()
}

fn parse_submatches(submatches: List(Option(String))) -> #(Int, Int) {
  let assert [a, b] =
    submatches
    |> list.map(fn(submatch) {
      let assert option.Some(number) =
        submatch
        |> option.map(fn(string) {
          int.base_parse(string, 10) |> option.from_result()
        })
        |> option.flatten()
        as "every submatch consists of a decimal number"

      number
    })
    as "every match contains two decimal number submatches"

  #(a, b)
}

type Instruction {
  Multiply(Int, Int)
  Enable
  Disable
}

fn instruction_to_pair(instruction: Instruction) -> Result(#(Int, Int), Nil) {
  case instruction {
    Multiply(a, b) -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

fn reduce_instructions(instructions: List(Instruction)) -> List(Instruction) {
  do_reduce_instructions(instructions, True, [])
}

fn do_reduce_instructions(
  instructions: List(Instruction),
  is_enabled: Bool,
  acc: List(Instruction),
) -> List(Instruction) {
  case is_enabled, instructions {
    _, [] -> acc
    True, [instruction, ..rest] -> {
      case instruction {
        Multiply(_, _) ->
          do_reduce_instructions(rest, True, [instruction, ..acc])
        Enable -> do_reduce_instructions(rest, True, acc)
        Disable -> do_reduce_instructions(rest, False, acc)
      }
    }
    False, [instruction, ..rest] -> {
      case instruction {
        Enable -> do_reduce_instructions(rest, True, acc)
        _ -> do_reduce_instructions(rest, False, acc)
      }
    }
  }
}

fn parse_instructions(input: String) {
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(re) = regexp.compile("^\\((\\d+),(\\d+)\\)", options)

  do_parse_instructions(input, re, []) |> list.reverse()
}

fn do_parse_instructions(
  input: String,
  re: regexp.Regexp,
  acc: List(Instruction),
) -> List(Instruction) {
  case input {
    "" -> acc
    "do()" <> rest -> do_parse_instructions(rest, re, [Enable, ..acc])
    "don't()" <> rest -> do_parse_instructions(rest, re, [Disable, ..acc])
    "mul" <> rest -> {
      case regexp.scan(re, rest) {
        [] -> do_parse_instructions(rest, re, acc)
        [match] -> {
          let match_length = string.length(match.content)

          let pair = parse_submatches(match.submatches)
          do_parse_instructions(string.drop_left(input, match_length), re, [
            Multiply(pair.0, pair.1),
            ..acc
          ])
        }
        _ -> panic as "only the first one is matched"
      }
    }
    _ -> {
      do_parse_instructions(string.drop_left(input, 1), re, acc)
    }
  }
}
