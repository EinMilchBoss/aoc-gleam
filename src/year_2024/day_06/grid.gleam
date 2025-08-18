import gleam/bool
import gleam/function
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

import year_2024/day_06/coordinate.{type Coordinate, Coordinate}
import year_2024/day_06/direction
import year_2024/day_06/guard.{type GuardState, GuardState}

pub type Grid {
  Grid(
    obstructions: Set(Coordinate),
    start: Coordinate,
    width: Int,
    height: Int,
  )
}

pub fn parse(input: String) -> Grid {
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

pub fn contains(grid: Grid, coordinate: Coordinate) -> Bool {
  use <- bool.guard(coordinate.x < 0 || grid.width <= coordinate.x, False)
  use <- bool.guard(coordinate.y < 0 || grid.height <= coordinate.y, False)

  True
}

pub fn traverse(grid: Grid) -> Set(Coordinate) {
  do_traverse(grid, GuardState(grid.start, direction.Up), set.new())
}

fn do_traverse(
  grid: Grid,
  guard: GuardState,
  visited: Set(Coordinate),
) -> Set(Coordinate) {
  case contains(grid, guard.coordinate) {
    // We are out of bounds and therefore done.
    False -> visited
    True -> {
      let next_visited = set.insert(visited, guard.coordinate)

      let next_guard_stepped = guard.take_step(guard)

      case set.contains(grid.obstructions, next_guard_stepped.coordinate) {
        // Continue until either out of bounds or an obstruction is hit.
        False -> do_traverse(grid, next_guard_stepped, next_visited)
        // Turn right for now without moving forward because if there was an 
        // obstruction immediately after turning, we would run into it.
        True -> {
          let next_guard_turned = guard.turn_right(guard)

          do_traverse(grid, next_guard_turned, next_visited)
        }
      }
    }
  }
}

pub fn get_obstruction_possibilities(
  grid: Grid,
) -> List(#(GuardState, Coordinate)) {
  do_get_obstruction_possibilities(
    grid,
    GuardState(grid.start, direction.Up),
    set.new(),
    [],
  )
}

fn do_get_obstruction_possibilities(
  grid: Grid,
  guard: GuardState,
  added_obstructions: Set(Coordinate),
  acc: List(#(GuardState, Coordinate)),
) -> List(#(GuardState, Coordinate)) {
  case contains(grid, guard.coordinate) {
    // We are out of bounds and therefore done.
    False -> acc
    True -> {
      let next_guard_stepped = guard.take_step(guard)
      let next_guard_turned = guard.turn_right(guard)
      let added_obstruction = next_guard_stepped.coordinate

      case set.contains(grid.obstructions, added_obstruction) {
        // We can't stack obstructions so we don't need to add one.
        True ->
          do_get_obstruction_possibilities(
            grid,
            next_guard_turned,
            added_obstructions,
            acc,
          )
        False -> {
          case set.contains(added_obstructions, added_obstruction) {
            // We mustn't add the same obstruction at a later point in time.
            True ->
              do_get_obstruction_possibilities(
                grid,
                next_guard_stepped,
                added_obstructions,
                acc,
              )
            False ->
              do_get_obstruction_possibilities(
                grid,
                next_guard_stepped,
                set.insert(added_obstructions, added_obstruction),
                [#(next_guard_turned, added_obstruction), ..acc],
              )
          }
        }
      }
    }
  }
}

pub fn has_loop(grid: Grid, added_obstruction: Coordinate, guard: GuardState) {
  do_has_loop(
    grid,
    set.insert(grid.obstructions, added_obstruction),
    guard,
    set.new(),
  )
}

fn do_has_loop(
  grid: Grid,
  all_obstructions: Set(Coordinate),
  guard: GuardState,
  turned: Set(GuardState),
) -> Bool {
  case contains(grid, guard.coordinate) {
    // We are out of bounds and therefore no loop is in place.
    False -> False
    True -> {
      case set.contains(turned, guard) {
        // We know it's a loop and can return.
        True -> True
        // We have to follow the rules until we are are either out of bounds or hitting a loop.
        False -> {
          let next_guard_stepped = guard.take_step(guard)

          case set.contains(all_obstructions, next_guard_stepped.coordinate) {
            // We didn't turn so we don't have to update anything.
            False ->
              do_has_loop(grid, all_obstructions, next_guard_stepped, turned)
            True -> {
              let next_guard_turned = guard.turn_right(guard)
              let next_turned = set.insert(turned, guard)

              do_has_loop(
                grid,
                all_obstructions,
                next_guard_turned,
                next_turned,
              )
            }
          }
        }
      }
    }
  }
}
