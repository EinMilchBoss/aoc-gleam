import gleam/int
import gleam/io
import gleam/list
import gleam/set

import aoc
import aoc/input
import aoc/part
import year_2024/day_06/grid

pub fn main() {
  let input = input.read_files(year: 2024, day: 6)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "41"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "6"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let grid = grid.parse(input)

  grid |> grid.traverse() |> set.size() |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = grid.parse(input)
  let obstruction_possibilities = grid.get_obstruction_possibilities(grid)

  obstruction_possibilities
  |> list.count(fn(obstruction_possibility) {
    let #(guard, added_obstruction) = obstruction_possibility

    grid.has_loop(grid, added_obstruction, guard)
  })
  |> int.to_string()
}
