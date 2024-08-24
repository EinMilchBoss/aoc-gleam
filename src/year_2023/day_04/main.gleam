import gleam/io

import aoc
import aoc/input
import aoc/part
import year_2023/day_04/part_one

pub fn main() {
  let input = input.read_files(year: 2023, day: 4)

  let one = part.one(input, part_one.solve)
  // let two = part.two(input, solve_part_two)

  io.println(aoc.run_fake_one(one, "13"))
  io.println(aoc.run_real(one))
  // io.println(aoc.run_fake_two(two, "467835"))
  // io.println(aoc.run_real(two))
}
