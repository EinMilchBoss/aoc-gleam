import gleam/int
import gleam/list

import year_2023/day_05/almanac

pub fn solve(input: String) -> String {
  let almanac = almanac.from_string(input)

  let assert Ok(smallest_location) =
    almanac.translate_seeds(almanac) |> list.reduce(int.min)
  int.to_string(smallest_location)
}
