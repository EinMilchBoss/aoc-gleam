import gleam/string

import year_2024/day_04/grid

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
    |> grid.parse()

  assert grid.count_xmas(grid, grid.Coordinate(3, 3)) == 8 as "sanity check"

  assert grid.is_xmas_left_to_right(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_right_to_left(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_down_to_up(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_up_to_down(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_diagonal_forward_increasing(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_diagonal_forward_decreasing(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_diagonal_backward_increasing(grid, grid.Coordinate(3, 3))
  assert grid.is_xmas_diagonal_backward_decreasing(grid, grid.Coordinate(3, 3))
}
