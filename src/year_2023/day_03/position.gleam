import gleam/bool
import gleam/yielder

pub type Position {
  Position(x: Int, y: Int)
}

pub fn adjacent(position: Position) -> List(Position) {
  yielder.range(-1, 1)
  |> yielder.flat_map(fn(dy) {
    yielder.range(-1, 1)
    |> yielder.filter_map(fn(dx) {
      use <- bool.guard(dx == 0 && dy == 0, Error(Nil))

      Ok(Position(position.x + dx, position.y + dy))
    })
  })
  |> yielder.to_list()
}
