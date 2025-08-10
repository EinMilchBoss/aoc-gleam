import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2024, day: 2)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "2"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "4"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let reports = parse_reports(input)

  let increasing = reports |> list.count(are_all_increasing)
  let decreasing = reports |> list.count(are_all_decreasing)

  int.to_string(increasing + decreasing)
}

fn part_two(input: String) -> String {
  let reports = parse_reports(input)

  let increasing =
    reports
    |> list.count(fn(report) {
      permutate_report(report) |> list.any(are_all_increasing)
    })
  let decreasing =
    reports
    |> list.count(fn(report) {
      permutate_report(report) |> list.any(are_all_decreasing)
    })

  int.to_string(increasing + decreasing)
}

fn permutate_report(report: List(Int)) -> List(List(Int)) {
  let length = list.length(report)
  list.combinations(report, length - 1)
}

fn parse_reports(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.map(fn(string) {
      let assert Ok(number) = int.base_parse(string, 10)
        as "input contains only decimal numbers"
      number
    })
  })
}

fn are_all_increasing(levels: List(Int)) -> Bool {
  are_all_x(levels, fn(left, right) { right - left })
}

fn are_all_decreasing(levels: List(Int)) -> Bool {
  are_all_x(levels, fn(left, right) { left - right })
}

fn are_all_x(levels: List(Int), difference: fn(Int, Int) -> Int) {
  levels
  |> list.window_by_2()
  |> list.all(fn(level) {
    let #(left, right) = level

    let difference = difference(left, right)
    1 <= difference && difference <= 3
  })
}
