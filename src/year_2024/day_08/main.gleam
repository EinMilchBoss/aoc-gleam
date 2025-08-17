import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}

import aoc
import aoc/input
import aoc/part
import year_2024/day_08/coordinate.{type Coordinate}
import year_2024/day_08/grid.{type Grid}

pub fn main() {
  let input = input.read_files(year: 2024, day: 8)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "14"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "34"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let grid = grid.parse(input)

  grid
  |> antinodes_by_model(fn(left, right) {
    grid.nearest_antinodes_model(grid, left, right)
  })
  |> set.size()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = grid.parse(input)

  grid
  |> antinodes_by_model(fn(left, right) {
    grid.all_antinodes_model(grid, left, right)
  })
  |> set.size()
  |> int.to_string()
}

fn antinodes_by_model(
  grid: Grid,
  model: fn(Coordinate, Coordinate) -> List(Coordinate),
) -> Set(Coordinate) {
  grid.frequencies
  |> list.flat_map(fn(antennas) {
    antennas
    |> list.combinations(2)
    |> list.flat_map(fn(combination) {
      let assert [left, right] = combination
        as "all combinations have 2 elements"

      model(left, right)
    })
  })
  |> set.from_list()
}
