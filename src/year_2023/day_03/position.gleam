import gleam/bool
import gleam/iterator

pub type Position {
  Position(x: Int, y: Int)
}

pub fn adjacent(position: Position) -> List(Position) {
  iterator.range(-1, 1)
  |> iterator.flat_map(fn(dy) {
    iterator.range(-1, 1)
    |> iterator.filter_map(fn(dx) {
      use <- bool.guard(dx == 0 && dy == 0, Error(Nil))

      Ok(Position(position.x + dx, position.y + dy))
    })
  })
  |> iterator.to_list()
}
