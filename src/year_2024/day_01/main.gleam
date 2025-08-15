import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2024, day: 1)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "11"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "31"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let #(left_list, right_list) = parse_column_lists(input)

  let left_list = list.sort(left_list, int.compare)
  let right_list = list.sort(right_list, int.compare)

  list.map2(left_list, right_list, fn(left, right) {
    int.absolute_value(right - left)
  })
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let #(left_list, right_list) = parse_column_lists(input)

  list.map(left_list, fn(left) {
    let occurrences = count_occurrences(left, right_list)
    left * occurrences
  })
  |> int.sum()
  |> int.to_string()
}

fn parse_column_lists(input: String) -> #(List(Int), List(Int)) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    string.split(line, "   ")
    |> list.map(fn(n) {
      let assert Ok(n) = int.parse(n)
        as "input consists only of decimal numbers"
      n
    })
  })
  |> list.fold(#([], []), fn(acc, line_list) {
    let assert [left, right] = line_list
      as "input consists of 2 numbers per line"

    #([left, ..acc.0], [right, ..acc.1])
  })
}

fn count_occurrences(left: Int, right_list: List(Int)) -> Int {
  list.count(right_list, fn(right) { right == left })
}
