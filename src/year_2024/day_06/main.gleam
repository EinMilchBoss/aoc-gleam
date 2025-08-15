import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

import aoc
import aoc/input
import aoc/part

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
  let grid = grid_parse(input)
  grid_traverse(grid) |> set.size() |> int.to_string()
}

fn part_two(input: String) -> String {
  todo
}

type Coordinate {
  Coordinate(x: Int, y: Int)
}

fn coordinate_walk(coordinate: Coordinate, direction: Direction) -> Coordinate {
  case direction {
    Up -> Coordinate(..coordinate, y: coordinate.y - 1)
    Down -> Coordinate(..coordinate, y: coordinate.y + 1)
    Right -> Coordinate(..coordinate, x: coordinate.x + 1)
    Left -> Coordinate(..coordinate, x: coordinate.x - 1)
  }
}

type Direction {
  Up
  Down
  Right
  Left
}

fn direction_turn_right(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Down -> Left
    Right -> Down
    Left -> Up
  }
}

type Grid {
  Grid(
    obstructions: Set(Coordinate),
    start: Coordinate,
    width: Int,
    height: Int,
  )
}

fn grid_parse(input: String) -> Grid {
  let lines = string.split(input, "\n")

  let height = list.length(lines)

  let assert Ok(first) = list.first(lines) as "input has at least one line"
  let width = first |> string.to_graphemes() |> list.length()

  let assert #(Some(start), obstructions) =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes()
      |> list.index_map(fn(grapheme, x) {
        case grapheme {
          "#" -> Ok(#(None, Some(Coordinate(x, y))))
          "^" -> Ok(#(Some(Coordinate(x, y)), None))
          _ -> Error(Nil)
        }
      })
      |> list.filter_map(function.identity)
    })
    |> list.flatten()
    |> list.fold(#(None, set.new()), fn(acc, x) {
      let #(player, obstructions) = acc

      case x {
        #(Some(player), _) -> #(Some(player), obstructions)
        #(_, Some(obstruction)) -> #(
          player,
          set.insert(obstructions, obstruction),
        )
        _ -> panic as "a coordinate is either an obstruction or the player"
      }
    })
    as "there has to be exactly one player"

  Grid(obstructions:, start:, width:, height:)
}

fn grid_contains(grid: Grid, coordinate: Coordinate) -> Bool {
  let is_x_valid = 0 <= coordinate.x && coordinate.x < grid.width
  let is_y_valid = 0 <= coordinate.y && coordinate.y < grid.height

  is_x_valid && is_y_valid
}

fn grid_traverse(grid: Grid) -> Set(Coordinate) {
  do_grid_traverse(grid, grid.start, Up, set.new())
}

fn do_grid_traverse(
  grid: Grid,
  player: Coordinate,
  direction: Direction,
  visited: Set(Coordinate),
) -> Set(Coordinate) {
  case grid_contains(grid, player) {
    // We are out of bounds and therefore done.
    False -> visited
    True -> {
      let updated_visited = set.insert(visited, player)
      let updated_player = coordinate_walk(player, direction)

      case set.contains(grid.obstructions, updated_player) {
        // Continue until either out of bounds or an obstruction is hit.
        False ->
          do_grid_traverse(grid, updated_player, direction, updated_visited)
        // Turn right for now without moving forward because if there was an 
        // obstruction immediately after turning, we would run into problems
        True -> {
          do_grid_traverse(
            grid,
            player,
            direction_turn_right(direction),
            updated_visited,
          )
        }
      }
    }
  }
}
