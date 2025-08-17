import year_2024/day_06/coordinate.{type Coordinate, Coordinate}
import year_2024/day_06/direction.{type Direction}

pub type GuardState {
  GuardState(coordinate: Coordinate, direction: Direction)
}

pub fn turn_right(guard: GuardState) -> GuardState {
  GuardState(..guard, direction: direction.turn_right(guard.direction))
}

pub fn take_step(guard: GuardState) -> GuardState {
  case guard.direction {
    direction.Up ->
      GuardState(
        ..guard,
        coordinate: Coordinate(..guard.coordinate, y: guard.coordinate.y - 1),
      )
    direction.Down ->
      GuardState(
        ..guard,
        coordinate: Coordinate(..guard.coordinate, y: guard.coordinate.y + 1),
      )
    direction.Right ->
      GuardState(
        ..guard,
        coordinate: Coordinate(..guard.coordinate, x: guard.coordinate.x + 1),
      )
    direction.Left ->
      GuardState(
        ..guard,
        coordinate: Coordinate(..guard.coordinate, x: guard.coordinate.x - 1),
      )
  }
}
