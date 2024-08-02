import aoc/aoc
import aoc/input
import aoc/part
import gleam/bool
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/order
import gleam/result
import gleam/set
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
  io.println(aoc.run_real(one))
}

fn solve_part_one(input: String) -> String {
  let symbols = parse_symbol_positions(input)
  let parts = parse_parts(input)
  let adjacent_positions = unique_adjacent_positions(symbols)

  parts
  |> list.filter(fn(part) {
    part.positions
    |> list.any(fn(part_pos) {
      adjacent_positions
      |> list.any(fn(match_pos) { part_pos == match_pos })
    })
  })
  |> list.fold(0, fn(acc, part) { acc + part.number })
  |> int.to_string()
}

fn unique_adjacent_positions(positions: List(Position)) -> List(Position) {
  positions
  |> iterator.from_list()
  |> iterator.flat_map(fn(position) {
    iterator.range(-1, 1)
    |> iterator.flat_map(fn(dy) {
      iterator.range(-1, 1)
      |> iterator.filter_map(fn(dx) {
        use <- bool.guard(dx == 0 && dy == 0, Error(Nil))

        Ok(Position(position.x + dx, position.y + dy))
      })
    })
  })
  |> iterator.to_list()
  |> set.from_list()
  |> set.to_list()
}

fn parse_parts(input: String) -> List(Part) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> parse_parts_in_line(Position(0, y), 0, [], [])
  })
  |> list.flatten()
}

fn parse_parts_in_line(
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
        parse_parts_in_line(
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

fn parse_symbol_positions(input: String) -> List(Position) {
  input
  |> string.split("\n")
  |> iterator.from_list()
  |> iterator.index()
  |> iterator.flat_map(fn(line_y) {
    let #(line, y) = line_y

    line
    |> string.to_graphemes()
    |> iterator.from_list()
    |> iterator.index()
    |> iterator.filter_map(fn(grapheme_x) {
      let #(grapheme, x) = grapheme_x

      case !is_empty(grapheme) && !is_number(grapheme) {
        True -> Ok(Position(x, y))
        False -> Error(Nil)
      }
    })
  })
  |> iterator.to_list()
}

fn is_number(grapheme: String) -> Bool {
  grapheme
  |> int.parse()
  |> result.is_ok()
}

fn is_empty(grapheme: String) -> Bool {
  string.compare(grapheme, ".") == order.Eq
}
