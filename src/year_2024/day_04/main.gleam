import gleam/dict
import gleam/int
import gleam/io
import gleam/list

import aoc
import aoc/input
import aoc/part
import year_2024/day_04/grid

pub fn main() {
  let input = input.read_files(year: 2024, day: 4)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "18"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "9"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let grid = grid.parse(input)

  grid.values
  |> dict.keys()
  |> list.map(grid.count_xmas(grid, _))
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = grid.parse(input)

  grid.values
  |> dict.keys()
  |> list.count(grid.is_mas(grid, _))
  |> int.to_string()
}
