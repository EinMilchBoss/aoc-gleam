import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2025, day: 6)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "4277556"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "3263827"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let parts_of_rows =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      // There can be multiple spaces next to each other.
      // This would result in empty strings which we have to filter out.
      line
      |> string.split(" ")
      |> list.filter(fn(x) { !string.is_empty(x) })
    })

  let assert #(numbers_of_rows, [operations]) =
    list.split(parts_of_rows, at: list.length(parts_of_rows) - 1)
    as "the input has at least one line"
  let numbers_of_problems =
    numbers_of_rows
    |> list.transpose()
    |> list.map(fn(strings) {
      strings
      |> list.map(fn(string) {
        let assert Ok(number) = int.parse(string)
          as "all lines except the last consist of only ints"
        number
      })
    })

  let assert Ok(problems) = list.strict_zip(operations, numbers_of_problems)
    as "both lists have the same length"

  problems
  |> list.map(fn(problem) {
    let #(operation, numbers) = problem
    case operation {
      "*" -> int.product(numbers)
      "+" -> int.sum(numbers)
      _ -> panic as "there are only additions and multiplications"
    }
  })
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let lines = string.split(input, "\n")
  let assert #(number_rows, [operations_row]) =
    list.split(lines, list.length(lines) - 1)
    as "the input has at least one line"

  let ordered_sizes =
    operations_row
    |> string.to_graphemes()
    |> list.index_map(fn(value, index) { #(index, value) })
    |> list.filter_map(fn(pair) {
      case pair.1 {
        " " -> Error(Nil)
        _ -> Ok(pair.0)
      }
    })
    |> list.window_by_2()
    |> list.map(fn(bounds) {
      let #(start, start_next) = bounds
      start_next - start - 1
    })

  let numbers =
    number_rows
    |> list.map(munch_by_sizes(_, ordered_sizes))
    |> list.transpose()
    |> list.map(undigit_columns)

  let assert Ok(problems) =
    operations_row
    |> string.to_graphemes()
    |> list.filter(fn(x) { x != " " })
    |> list.strict_zip(numbers)
    as "there are the same amount of operations and columns"

  problems
  |> list.map(fn(problem) {
    let #(operation, numbers) = problem
    case operation {
      "*" -> int.product(numbers)
      "+" -> int.sum(numbers)
      _ -> panic as "there are only additions and multiplications"
    }
  })
  |> int.sum()
  |> int.to_string()
}

/// Takes digits of rows and combines them to ints on a column-by-column basis.
/// 
/// ## Constraints
/// 
/// - All rows strings must have the same size. 
/// - Each row must only consist of decimal digits and spaces for padding.
/// - There must not be any spaces between digits of a column.
/// 
/// ## Examples
/// 
/// ```gleam
/// undigit_columns([
///   "103",
///   "456",
///   "780"
/// ])
/// // -> [147, 58, 36]
/// ```
/// 
fn undigit_columns(rows: List(String)) -> List(Int) {
  case rows {
    [] -> []
    [first, ..rest] -> {
      do_undigit_columns(rest, string.to_graphemes(first))
    }
  }
}

fn do_undigit_columns(rows: List(String), acc: List(String)) -> List(Int) {
  case rows {
    [] -> {
      list.map(acc, fn(string) {
        let assert Ok(int) =
          string
          |> string.trim()
          |> int.parse()
          as "all digits combined in each column are ints"
        int
      })
    }
    [row, ..next_rows] -> {
      let assert Ok(zipped) =
        row
        |> string.to_graphemes()
        |> list.strict_zip(acc, _)
        as "both lists always have the same length"
      let next_acc = list.map(zipped, fn(x) { x.0 <> x.1 })

      do_undigit_columns(next_rows, next_acc)
    }
  }
}

/// Takes one bite after another from the start. The argument `sizes` contains the size of each bite in order.
/// Between bites, one grapheme crumbles away and is not included in the input.
/// 
/// ## Examples
/// 
/// ```gleam
/// split_by_lengths("aaa bbbb cc", [3, 4, 2])
/// // -> ["aaa", "bbbb", "cc"]
/// ```
/// 
fn munch_by_sizes(input: String, sizes: List(Int)) -> List(String) {
  do_munch_by_sizes(string.to_graphemes(input), sizes, [])
}

fn do_munch_by_sizes(
  graphemes: List(String),
  lengths: List(Int),
  acc: List(String),
) -> List(String) {
  case lengths {
    [] -> {
      // Munching was done from left to right and new parts were prepended.
      // Therefore the order is exactly wrong.
      graphemes
      |> string.concat()
      |> list.prepend(acc, _)
      |> list.reverse()
    }
    [length, ..next_lengths] -> {
      let #(part, rest) = list.split(graphemes, length)

      // Remove the column of whitespace.
      let next_graphemes = list.drop(rest, 1)

      // Combine split off graphemes to form the number of correct length.
      let next_acc =
        part
        |> string.concat()
        |> list.prepend(acc, _)

      do_munch_by_sizes(next_graphemes, next_lengths, next_acc)
    }
  }
}
