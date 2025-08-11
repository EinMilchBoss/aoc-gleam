import gleam/string

import year_2024/day_04/main

pub fn is_xmas_test() {
  let grid =
    [
      "S**S**S",
      "*A*A*A*",
      "**MMM**",
      "SAMXMAS",
      "**MMM**",
      "*A*A*A*",
      "S**S**S",
    ]
    |> string.join("\n")
    |> main.grid_parse()

  assert main.count_xmas(grid, main.Coordinate(3, 3)) == 8 as "sanity check"

  assert main.is_xmas_left_to_right(grid, main.Coordinate(3, 3))
  assert main.is_xmas_right_to_left(grid, main.Coordinate(3, 3))
  assert main.is_xmas_down_to_up(grid, main.Coordinate(3, 3))
  assert main.is_xmas_up_to_down(grid, main.Coordinate(3, 3))
  assert main.is_xmas_diagonal_forward_increasing(grid, main.Coordinate(3, 3))
  assert main.is_xmas_diagonal_forward_decreasing(grid, main.Coordinate(3, 3))
  assert main.is_xmas_diagonal_backward_increasing(grid, main.Coordinate(3, 3))
  assert main.is_xmas_diagonal_backward_decreasing(grid, main.Coordinate(3, 3))
}
