import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/set.{type Set}
import gleam/string

import year_2023/day_03/position.{type Position, Position}

pub type EnginePart {
  EnginePart(number: Int, y: Int, start: Int, length: Int)
}

pub fn end(engine_part: EnginePart) -> Int {
  engine_part.start + engine_part.length - 1
}

pub fn x_range(engine_part: EnginePart) -> Iterator(Int) {
  iterator.range(engine_part.start, end(engine_part))
}

pub fn parse(input: String) -> List(EnginePart) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    parse_line(string.to_graphemes(line), y, 0, 0, 0, [])
  })
  |> list.flatten()
}

fn parse_line(
  graphemes: List(String),
  y: Int,
  x: Int,
  part_number: Int,
  part_length: Int,
  acc: List(EnginePart),
) -> List(EnginePart) {
  case graphemes {
    [] if part_length > 0 -> [
      EnginePart(part_number, y, x - part_length, part_length),
      ..acc
    ]
    [] -> acc
    [current, ..rest] -> {
      let next = fn(part_number, part_length, acc) {
        parse_line(rest, y, x + 1, part_number, part_length, acc)
      }

      case int.parse(current) {
        Ok(current_number) -> {
          next(10 * part_number + current_number, part_length + 1, acc)
        }
        Error(Nil) if part_length > 0 -> {
          next(0, 0, [
            EnginePart(part_number, y, x - part_length, part_length),
            ..acc
          ])
        }
        Error(Nil) -> next(0, 0, acc)
      }
    }
  }
}

pub fn positions(engine_part: EnginePart) -> List(Position) {
  x_range(engine_part)
  |> iterator.map(fn(x) { Position(x, engine_part.y) })
  |> iterator.to_list()
}

pub fn adjacent_positions(engine_part: EnginePart) -> Set(Position) {
  let leftmost = engine_part.start
  let rightmost = end(engine_part)

  let left =
    iterator.range(-1, 1)
    |> iterator.map(fn(dy) { Position(leftmost - 1, engine_part.y + dy) })

  let right =
    iterator.range(-1, 1)
    |> iterator.map(fn(dy) { Position(rightmost + 1, engine_part.y + dy) })

  let above =
    x_range(engine_part)
    |> iterator.map(fn(x) { Position(x, engine_part.y + 1) })

  let below =
    x_range(engine_part)
    |> iterator.map(fn(x) { Position(x, engine_part.y - 1) })

  left
  |> iterator.append(right)
  |> iterator.append(above)
  |> iterator.append(below)
  |> iterator.to_list()
  |> set.from_list()
}
