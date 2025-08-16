import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
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

  grid |> grid_traverse() |> set.size() |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = grid_parse(input)
  let obstruction_possibilities = get_obstruction_possibilities(grid)

  obstruction_possibilities
  |> list.map(pair.second)
  |> list.filter(fn(new_obstruction) {
    set.contains(grid.obstructions, new_obstruction)
  })
  |> list.is_empty()

  obstruction_possibilities
  |> list.count(fn(obstruction_possibility) {
    let #(player, added_obstruction) = obstruction_possibility

    has_loop(grid, added_obstruction, player)
  })
  |> int.to_string()
}

fn has_loop(
  grid: Grid,
  added_obstruction: Coordinate,
  player: #(Coordinate, Direction),
) {
  do_has_loop(
    grid,
    set.insert(grid.obstructions, added_obstruction),
    player,
    set.new(),
  )
}

fn do_has_loop(
  grid: Grid,
  all_obstructions: Set(Coordinate),
  player: #(Coordinate, Direction),
  visited: Set(#(Coordinate, Direction)),
) -> Bool {
  let #(player_coordinate, player_direction) = player

  case grid_contains(grid, player_coordinate) {
    False -> False
    True -> {
      let next_visited = set.insert(visited, player)

      case set.contains(visited, player) {
        // We know it's a loop and can return.
        True -> True
        // We have to follow the rules until we are are either out of bounds or hitting a loop.
        False -> {
          let next_player_coordinate =
            coordinate_walk(player_coordinate, player_direction)

          case set.contains(all_obstructions, next_player_coordinate) {
            False ->
              do_has_loop(
                grid,
                all_obstructions,
                #(next_player_coordinate, player_direction),
                next_visited,
              )
            True -> {
              let next_player_direction = direction_turn_right(player_direction)

              do_has_loop(
                grid,
                all_obstructions,
                #(player_coordinate, next_player_direction),
                next_visited,
              )
            }
          }
        }
      }
    }
  }
}

fn get_obstruction_possibilities(
  grid: Grid,
) -> List(#(#(Coordinate, Direction), Coordinate)) {
  do_get_obstruction_possibilities(grid, #(grid.start, Up), set.new(), [])
}

fn do_get_obstruction_possibilities(
  grid: Grid,
  player: #(Coordinate, Direction),
  added_obstructions: Set(Coordinate),
  acc: List(#(#(Coordinate, Direction), Coordinate)),
) -> List(#(#(Coordinate, Direction), Coordinate)) {
  let #(player_coordinate, player_direction) = player

  case grid_contains(grid, player_coordinate) {
    // We are out of bounds and therefore done.
    False -> acc
    True -> {
      let next_player_coordinate =
        coordinate_walk(player_coordinate, player_direction)
      let next_player_direction = direction_turn_right(player_direction)

      case set.contains(grid.obstructions, next_player_coordinate) {
        // We can't stack obstructions so we don't need to add one.
        True ->
          do_get_obstruction_possibilities(
            grid,
            #(player_coordinate, next_player_direction),
            added_obstructions,
            acc,
          )
        False -> {
          case set.contains(added_obstructions, next_player_coordinate) {
            // We mustn't add the same obstruction at a later point in time.
            True ->
              do_get_obstruction_possibilities(
                grid,
                #(next_player_coordinate, player_direction),
                added_obstructions,
                acc,
              )
            False ->
              do_get_obstruction_possibilities(
                grid,
                #(next_player_coordinate, player_direction),
                set.insert(added_obstructions, next_player_coordinate),
                [
                  #(
                    #(player_coordinate, next_player_direction),
                    next_player_coordinate,
                  ),
                  ..acc
                ],
              )
          }
        }
      }
    }
  }
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
  do_grid_traverse(grid, #(grid.start, Up), set.new())
}

fn do_grid_traverse(
  grid: Grid,
  player: #(Coordinate, Direction),
  visited: Set(Coordinate),
) -> Set(Coordinate) {
  let #(player_coordinate, player_direction) = player

  case grid_contains(grid, player_coordinate) {
    // We are out of bounds and therefore done.
    False -> visited
    True -> {
      let updated_visited = set.insert(visited, player_coordinate)
      let updated_player_coordinate =
        coordinate_walk(player_coordinate, player_direction)

      case set.contains(grid.obstructions, updated_player_coordinate) {
        // Continue until either out of bounds or an obstruction is hit.
        False ->
          do_grid_traverse(
            grid,
            #(updated_player_coordinate, player_direction),
            updated_visited,
          )
        // Turn right for now without moving forward because if there was an 
        // obstruction immediately after turning, we would run into it.
        True -> {
          let updated_player_direction = direction_turn_right(player_direction)

          do_grid_traverse(
            grid,
            #(player_coordinate, updated_player_direction),
            updated_visited,
          )
        }
      }
    }
  }
}
