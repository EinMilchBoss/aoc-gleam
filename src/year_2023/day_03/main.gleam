import aoc/aoc
import aoc/input
import aoc/part
import gleam/function
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/order
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Part {
  Part(number: Int, positions: List(Position))
}

type Position {
  Position(x: Int, y: Int)
}

pub fn main() {
  let input = input.read(2023, 3)

  let one = part.one(input, solve_part_one)
  // let two = part.two(input, solve_part_two)

  io.println(aoc.run_fake_one(one, "4361"))
  // io.println(aoc.run_real(one))
}

fn solve_part_one(input: String) -> String {
  let symbols = find_symbols(input)
  let parts = find_parts(input)
  let matches = adjacent_positions(symbols)

  let results =
    parts
    |> list.filter(fn(part) {
      part.positions
      |> list.any(fn(part_pos) {
        matches
        |> list.any(fn(match_pos) { part_pos == match_pos })
      })
    })
    |> list.fold(0, fn(acc, part) { acc + part.number })
  int.to_string(results)
}

fn adjacent_positions(positions: List(Position)) -> List(Position) {
  positions
  |> iterator.from_list()
  |> iterator.flat_map(fn(position) {
    iterator.range(-1, 1)
    |> iterator.flat_map(fn(dy) {
      iterator.range(-1, 1)
      |> iterator.map(fn(dx) { Position(position.x + dx, position.y + dy) })
    })
  })
  |> iterator.to_list()
}

fn find_parts(input: String) -> List(Part) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> find_parts_in_line(Position(0, y), 0, [], [])
  })
  |> list.flatten()
}

fn find_parts_in_line(
  graphemes: List(String),
  position: Position,
  part_number: Int,
  part_positions: List(Position),
  acc: List(Part),
) -> List(Part) {
  case graphemes {
    [] -> acc
    [current, ..rest] -> {
      let next = fn(part_number, part_positions, acc) {
        find_parts_in_line(
          rest,
          Position(..position, x: position.x + 1),
          part_number,
          part_positions,
          acc,
        )
      }

      case int.parse(current) {
        Ok(current_number) -> {
          next(
            10 * part_number + current_number,
            [position, ..part_positions],
            acc,
          )
        }
        Error(_) if part_number > 0 -> {
          next(0, [], [Part(part_number, part_positions), ..acc])
        }
        Error(_) -> next(0, [], acc)
      }
    }
  }
}

fn find_symbols(input: String) -> List(Position) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(grapheme, x) {
      let is_empty = string.compare(grapheme, ".") == order.Eq
      let is_digit =
        grapheme
        |> int.parse()
        |> result.is_ok()

      case !is_empty && !is_digit {
        True -> Ok(Position(x, y))
        False -> Error(Nil)
      }
    })
  })
  |> list.flatten()
  |> list.filter_map(function.identity)
}
