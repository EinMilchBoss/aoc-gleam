import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

import parallel_map

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
  Range(start: Int, end: Int)
}

fn part_one(input: String) -> String {
  let ranges = parse(input)

  ranges
  |> list.map(get_invalid_ids_double)
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let ranges = parse(input)

  let assert Ok(addends) =
    ranges
    |> parallel_map.list_pmap(
      get_invalid_ids_multiple,
      parallel_map.MatchSchedulersOnline,
      10_000,
    )
    |> result.all()
    as "no computation takes longer than 10 seconds"

  addends
  |> int.sum()
  |> int.to_string()
}

fn parse(input: String) -> List(Range) {
  input
  |> string.split(",")
  |> list.map(fn(range) {
    let assert [start, end] =
      range
      |> string.split("-")
      |> list.map(fn(string) {
        let assert Ok(int) = int.parse(string)
          as "every range consists of int bounds"
        int
      })
      as "every range consists of two bounds"

    Range(start:, end:)
  })
}

fn get_invalid_ids_double(range: Range) -> Int {
  do_get_invalid_ids_double(range.start, range.end, 0)
}

fn do_get_invalid_ids_double(id: Int, max_id_inclusive: Int, acc: Int) -> Int {
  case id <= max_id_inclusive {
    False -> acc
    True -> {
      let next_id = id + 1
      case is_invalid_id_double(int.to_string(id)) {
        False -> do_get_invalid_ids_double(next_id, max_id_inclusive, acc)
        True -> do_get_invalid_ids_double(next_id, max_id_inclusive, acc + id)
      }
    }
  }
}

fn is_invalid_id_double(id: String) -> Bool {
  let length = string.length(id)
  use <- bool.guard(length % 2 != 0, False)

  let half = length / 2

  let head = string.drop_end(id, half)
  let tail = string.drop_start(id, half)

  head == tail
}

fn get_invalid_ids_multiple(range: Range) -> Int {
  do_get_invalid_ids_multiple(range.start, range.end, 0)
}

fn do_get_invalid_ids_multiple(id: Int, max_id_inclusive: Int, acc: Int) -> Int {
  case id <= max_id_inclusive {
    False -> acc
    True -> {
      let next_id = id + 1
      case is_invalid_id_multiple(int.to_string(id)) {
        False -> do_get_invalid_ids_multiple(next_id, max_id_inclusive, acc)
        True -> do_get_invalid_ids_multiple(next_id, max_id_inclusive, acc + id)
      }
    }
  }
}

// The computation of an invalid ID that has an arbitrary number of repetitions is slow.
// Therefore we use an explicit recursion instead of precomputation and `list.any` to make it lazy.
fn is_invalid_id_multiple(id: String) -> Bool {
  // We only have to check until half, because it wouldn't be divisible otherwise.
  do_is_invalid_id_multiple(id, 1, string.length(id) / 2)
}

fn do_is_invalid_id_multiple(id: String, n: Int, max_n_inclusive: Int) -> Bool {
  case n <= max_n_inclusive {
    // We checked all possibilities and haven't encountered an invalid ID.
    // Therefore it must be a valid ID.
    False -> False
    True -> {
      let next_n = n + 1
      case try_chunk_id(id, n) {
        // Cannot be split evenly with current n.
        // Skip this one entirely and continue with n + 1.
        Error(Nil) -> do_is_invalid_id_multiple(id, next_n, max_n_inclusive)
        Ok(chunks) -> {
          case are_all_same(chunks) {
            // When split by a certain n, all elements are the same.
            // Therefore it is an invalid ID.
            True -> True
            False -> do_is_invalid_id_multiple(id, next_n, max_n_inclusive)
          }
        }
      }
    }
  }
}

fn try_chunk_id(id: String, n: Int) -> Result(List(String), Nil) {
  case string.length(id) % n == 0 {
    True ->
      Ok(
        id
        |> string.to_graphemes()
        |> list.sized_chunk(n)
        |> list.map(string.concat),
      )
    False -> Error(Nil)
  }
}

fn are_all_same(elements: List(String)) -> Bool {
  case elements {
    [] -> True
    [first, ..rest_elements] ->
      list.all(rest_elements, fn(element) { element == first })
  }
}
