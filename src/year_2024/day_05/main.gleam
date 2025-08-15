import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

import aoc
import aoc/input
import aoc/part
import year_2024/day_05/manual
import year_2024/day_05/rules

pub fn main() {
  let input = input.read_files(year: 2024, day: 5)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "143"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "123"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let #(rules, manuals) = input_parse(input)

  manuals
  |> list.filter(manual.manual_is_correct(_, rules))
  |> list.map(manual.get_middle_page)
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let #(rules, manuals) = input_parse(input)

  manuals
  |> list.filter(fn(manual) { !manual.manual_is_correct(manual, rules) })
  |> list.map(manual.manual_correct(_, rules))
  |> list.map(manual.get_middle_page)
  |> int.sum()
  |> int.to_string()
}

fn input_parse(input: String) -> #(Dict(Int, Set(Int)), List(List(Int))) {
  let assert [rules, manuals] = input |> string.split("\n\n")

  #(rules.parse(rules), manual.parse(manuals))
}
