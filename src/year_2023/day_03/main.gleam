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

  io.println(aoc.run_fake_one(one, "4361"))
  io.println(aoc.run_real(one))

  io.println(aoc.run_fake_two(two, "467835"))
  io.println(aoc.run_real(two))
}

fn solve_part_one(input: String) -> String {
  let symbol_positions = symbol.parse_positions(input)
  let engine_part_to_positions =
    input
    |> engine_part.parse()
    |> list.map(fn(engine_part) {
      #(engine_part, engine_part.positions(engine_part) |> set.from_list())
    })
    |> dict.from_list()

  part_numbers(symbol_positions, engine_part_to_positions, 0)
  |> int.to_string()
}

fn part_numbers(
  symbol_positions: List(Position),
  engine_part_to_positions: Dict(EnginePart, Set(Position)),
  acc: Int,
) -> Int {
  case symbol_positions {
    [] -> acc
    [gear_position, ..remaining_symbol_positions] -> {
      let gear_adjacent_positions =
        gear_position
        |> position.adjacent()
        |> set.from_list()

      let matches =
        engine_part_to_positions
        |> dict.filter(fn(_, positions) {
          !set.is_disjoint(positions, gear_adjacent_positions)
        })

      case dict.size(matches) {
        0 ->
          part_numbers(
            remaining_symbol_positions,
            engine_part_to_positions,
            acc,
          )
        _ -> {
          let engine_parts = dict.keys(matches)
          let additional =
            engine_parts
            |> list.fold(0, fn(acc, engine_part) { acc + engine_part.number })

          part_numbers(
            remaining_symbol_positions,
            dict.drop(engine_part_to_positions, engine_parts),
            acc + additional,
          )
        }
      }
    }
  }
}

fn solve_part_two(input: String) -> String {
  let gear_positions = gear.parse_positions(input)
  let engine_part_to_positions =
    input
    |> engine_part.parse()
    |> list.map(fn(engine_part) {
      #(engine_part, engine_part.positions(engine_part) |> set.from_list())
    })
    |> dict.from_list()

  gear_ratios(gear_positions, engine_part_to_positions, 0)
  |> int.to_string()
}

fn gear_ratios(
  gear_positions: List(Position),
  engine_part_to_positions: Dict(EnginePart, Set(Position)),
  acc: Int,
) -> Int {
  case gear_positions {
    [] -> acc
    [gear_position, ..remaining_gear_positions] -> {
      let gear_adjacent_positions =
        gear_position
        |> position.adjacent()
        |> set.from_list()

      let matches =
        engine_part_to_positions
        |> dict.filter(fn(_, positions) {
          !set.is_disjoint(positions, gear_adjacent_positions)
        })

      case dict.size(matches) {
        // Assumption #1: There cannot be more than two 
        // `EnginePart`s matching at the same time.
        // Assumption #2: No part is being used twice.
        2 -> {
          let assert [#(first, _), #(second, _)] = dict.to_list(matches)

          gear_ratios(
            remaining_gear_positions,
            dict.drop(engine_part_to_positions, [first, second]),
            acc + gear.ratio(first, second),
          )
        }
        _ -> {
          gear_ratios(remaining_gear_positions, engine_part_to_positions, acc)
        }
      }
    }
  }
}
