pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub fn add(left: Coordinate, right: Coordinate) -> Coordinate {
  Coordinate(left.x + right.x, left.y + right.y)
}

pub fn subtract(left: Coordinate, right: Coordinate) -> Coordinate {
  Coordinate(left.x - right.x, left.y - right.y)
}
