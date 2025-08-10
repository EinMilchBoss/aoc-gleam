import gleam/int
import gleam/io
import gleam/list
import gleam/regexp

import aoc
import aoc/input
import aoc/part
import year_2024/day_03/instruction
import year_2024/day_03/submatches

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
    |> list.map(fn(match) { submatches.parse(match.submatches) })

  pairs |> sum_pair_products() |> int.to_string()
}

fn part_two(input: String) -> String {
  let pairs =
    input
    |> instruction.parse()
    |> instruction.reduce()
    |> list.map(fn(multiply) {
      let assert Ok(pair) = instruction.to_pair(multiply)
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
