pub type Direction {
  Up
  Down
  Right
  Left
}

pub fn turn_right(direction: Direction) -> Direction {
  case direction {
    Up -> Right
    Down -> Left
    Right -> Down
    Left -> Up
  }
}
