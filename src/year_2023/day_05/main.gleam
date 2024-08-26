import gleam/io

import aoc
import aoc/input
import aoc/part
import year_2023/day_05/part_one

pub fn main() {
  let input = input.read_files(year: 2023, day: 5)

  let one = part.one(input, part_one.solve)
  // let two = part.two(input, part_two.solve)

  io.println(aoc.run_fake_one(one, "35"))
  io.println(aoc.run_real(one))
  // io.println(aoc.run_fake_two(two, "0"))
  // io.println(aoc.run_real(two))
}
