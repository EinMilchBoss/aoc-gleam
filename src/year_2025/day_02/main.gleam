import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2025, day: 2)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "1227775554"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "4174379265"))
  io.println(aoc.run_real(two))
}

type Range {
  Range(start: Int, end: Int, start_str: String, end_str: String)
}

fn part_one(input: String) -> String {
  let ranges: List(Range) =
    input
    |> string.split(",")
    |> list.map(fn(range) {
      let assert [#(start, start_str), #(end, end_str)] =
        range
        |> string.split("-")
        |> list.map(fn(string) {
          let assert Ok(int) = int.parse(string)
            as "every range consists of int bounds"
          #(int, string)
        })
        as "every range consists of two bounds"

      Range(start:, end:, start_str:, end_str:)
    })

  echo ranges as "ranges"

  ranges
  |> list.flat_map(fn(range) { get_invalid_ids(range) })
  |> echo as "invalid ids"
  |> int.sum()
  |> int.to_string()
}

fn get_invalid_ids(range: Range) -> List(Int) {
  do_get_invalid_ids(range.start, range.end, [])
}

fn do_get_invalid_ids(current: Int, end: Int, acc: List(Int)) -> List(Int) {
  case current <= end {
    False -> acc
    True -> {
      let next_current = current + 1
      case is_invalid_id(int.to_string(current)) {
        True -> do_get_invalid_ids(next_current, end, [current, ..acc])
        False -> do_get_invalid_ids(next_current, end, acc)
      }
    }
  }
}

fn is_invalid_id(id: String) -> Bool {
  let length = string.length(id)
  use <- bool.guard(length % 2 != 0, False)

  let half = length / 2

  let head = string.drop_end(id, half)
  let tail = string.drop_start(id, half)

  head == tail
}

fn part_two(input: String) -> String {
  let ranges: List(Range) =
    input
    |> string.split(",")
    |> list.map(fn(range) {
      let assert [#(start, start_str), #(end, end_str)] =
        range
        |> string.split("-")
        |> list.map(fn(string) {
          let assert Ok(int) = int.parse(string)
            as "every range consists of int bounds"
          #(int, string)
        })
        as "every range consists of two bounds"

      Range(start:, end:, start_str:, end_str:)
    })

  ranges
  |> list.flat_map(fn(range) { get_invalid_ids_multiple(range) })
  |> int.sum()
  |> int.to_string()
}

fn get_invalid_ids_multiple(range: Range) -> List(Int) {
  do_get_invalid_ids_multiple(range.start, range.end, [])
}

fn do_get_invalid_ids_multiple(
  current_id: Int,
  max_id_inclusive: Int,
  acc: List(Int),
) -> List(Int) {
  case current_id <= max_id_inclusive {
    False -> acc
    True -> {
      let next_id = current_id + 1
      case is_invalid_id_multiple(int.to_string(current_id)) {
        False -> do_get_invalid_ids_multiple(next_id, max_id_inclusive, acc)
        True ->
          do_get_invalid_ids_multiple(next_id, max_id_inclusive, [
            current_id,
            ..acc
          ])
      }
    }
  }
}

fn is_invalid_id_multiple(id: String) -> Bool {
  do_is_invalid_id_multiple(id, 1, string.length(id) / 2)
}

fn do_is_invalid_id_multiple(
  id: String,
  current_n: Int,
  max_inclusive: Int,
) -> Bool {
  case current_n <= max_inclusive {
    // We checked all possibilities and haven't encountered an invalid ID.
    // Therefore it must be a valid ID.
    False -> False
    True -> {
      let next_n = current_n + 1
      case split_id(id, current_n) {
        // Cannot be split evenly with current n.
        // Skip this one entirely and continue with n + 1.
        Error(Nil) -> do_is_invalid_id_multiple(id, next_n, max_inclusive)
        Ok(chunks) -> {
          case are_all_same(chunks) {
            // When split by a certain n, all elements are the same.
            // Therefore it is an invalid ID.
            True -> True
            False -> do_is_invalid_id_multiple(id, next_n, max_inclusive)
          }
        }
      }
    }
  }
}

fn are_all_same(xs: List(String)) -> Bool {
  case xs {
    [] -> True
    [head, ..tail] -> list.all(tail, fn(x) { x == head })
  }
}

fn split_id(id: String, n: Int) -> Result(List(String), Nil) {
  case string.length(id) % n == 0 {
    True ->
      Ok(
        id
        |> string.to_graphemes()
        |> list.sized_chunk(n)
        |> list.map(fn(chunk) { string.concat(chunk) }),
      )
    False -> Error(Nil)
  }
}
