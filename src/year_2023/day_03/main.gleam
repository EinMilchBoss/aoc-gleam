import aoc/aoc
import aoc/input
import aoc/part
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}

import year_2023/day_03/engine_part.{type EnginePart}
import year_2023/day_03/gear
import year_2023/day_03/position.{type Position}
import year_2023/day_03/symbol

pub fn main() {
  let input = input.read(2023, 3)

  let one = part.one(input, solve_part_one)
  let two = part.two(input, solve_part_two)

  // io.println(aoc.run_fake_one(one, "4361"))
  // io.println(aoc.run_real(one))

  io.println(aoc.run_fake_two(two, "467835"))
  io.println(aoc.run_real(two))
}

fn solve_part_one(input: String) -> String {
  let parts = engine_part.parse(input)
  let symbol_positions = symbol.parse_positions(input)
  let adjacent_positions = list.flat_map(symbol_positions, position.adjacent)

  parts
  |> list.filter(fn(part) {
    engine_part.positions(part)
    |> list.any(fn(part_pos) {
      adjacent_positions
      |> list.any(fn(match_pos) { part_pos == match_pos })
    })
  })
  |> list.fold(0, fn(acc, part) { acc + part.number })
  |> int.to_string()
}

fn solve_part_two(input: String) -> String {
  let gear_positions = gear.parse_positions(input)
  let engine_parts =
    input
    |> engine_part.parse()
    |> list.map(fn(engine_part) {
      #(engine_part, engine_part.positions(engine_part) |> set.from_list())
    })
    |> dict.from_list()

  io.debug(engine_parts)

  recurse(gear_positions, engine_parts, [])
  |> list.fold(0, int.add)
  |> int.to_string()
}

fn recurse(
  gear_positions: List(Position),
  engine_parts: Dict(EnginePart, Set(Position)),
  acc: List(Int),
) -> List(Int) {
  case gear_positions {
    [] -> acc
    [gear_position, ..remaining_gear_positions] -> {
      let gear_adjacent_positions =
        gear_position
        |> position.adjacent()
        |> set.from_list()

      let matches =
        engine_parts
        |> dict.filter(fn(_, positions) {
          !set.is_disjoint(positions, gear_adjacent_positions)
        })

      case dict.size(matches) {
        2 -> {
          let assert [#(first, _), #(second, _)] = dict.to_list(matches)

          // Assumption: No part is being used twice.
          let engine_parts = dict.drop(engine_parts, dict.keys(matches))

          recurse(remaining_gear_positions, engine_parts, [
            gear.ratio(first, second),
            ..acc
          ])
        }
        _ -> recurse(remaining_gear_positions, engine_parts, acc)
      }
    }
  }
}
