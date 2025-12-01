import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string

import aoc
import aoc/input
import aoc/part
import year_2024/day_09/disk

pub fn main() {
  let input = input.read_files(year: 2024, day: 9)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  // io.println(aoc.run_fake_one(one, "1928"))
  // io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "2858"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let disk_map = disk.parse_map(input)

  let compacted_disk_map = disk.compact(disk_map)

  compacted_disk_map |> disk.calculate_checksum() |> int.to_string()
}

fn part_two(input: String) -> String {
  let disk_blocks = disk.parse_blocks(input)

  input
  |> string.to_graphemes()
  |> list.map(fn(string) {
    let assert Ok(int) = int.parse(string)

    int
  })
  |> int.sum()

  let compacted = compact_blocks(disk_blocks.0, disk_blocks.1)

  compacted
  |> dict.to_list()
  |> list.map(fn(pair) { pair.0 * pair.1 })
  |> int.sum()
  |> int.to_string()
}

fn compact_blocks(
  files: List(disk.FileBlock),
  frees: List(disk.FreeBlock),
) -> Dict(Int, Int) {
  do_compact_blocks(files, list.reverse(frees), dict.new())
}

fn do_compact_blocks(
  files: List(disk.FileBlock),
  frees: List(disk.FreeBlock),
  acc: Dict(Int, Int),
) -> Dict(Int, Int) {
  case files {
    [] -> acc
    [file, ..next_files] -> {
      case split_find(frees, fn(free) { free.size >= file.size }) {
        Error(_) -> {
          let next_acc =
            list.range(file.index, file.index + file.size - 1)
            |> list.map(fn(index) { #(index, file.id) })
            |> dict.from_list()
            |> dict.merge(acc)

          do_compact_blocks(next_files, frees, next_acc)
        }
        Ok(#(before, fitting, after)) -> {
          let next_acc =
            list.range(fitting.index, fitting.index + file.size - 1)
            |> list.map(fn(index) { #(index, file.id) })
            |> dict.from_list()
            |> dict.merge(acc)

          case fill_free_space(fitting, file) {
            // Free block was fully consumed.
            Error(_) ->
              do_compact_blocks(
                next_files,
                list.append(before, after),
                next_acc,
              )
            // A little bit of the free block is left.
            Ok(remainder) ->
              do_compact_blocks(
                next_files,
                list.append(before, [remainder, ..after]),
                next_acc,
              )
          }
        }
      }
    }
  }
}

fn split_find(
  list: List(a),
  predicate: fn(a) -> Bool,
) -> Result(#(List(a), a, List(a)), Nil) {
  do_split_find(list, predicate, [])
}

fn do_split_find(
  list: List(a),
  predicate: fn(a) -> Bool,
  before: List(a),
) -> Result(#(List(a), a, List(a)), Nil) {
  case list {
    [] -> Error(Nil)
    [current, ..after] -> {
      case predicate(current) {
        False -> do_split_find(after, predicate, [current, ..before])
        True -> Ok(#(list.reverse(before), current, after))
      }
    }
  }
}

fn fill_free_space(
  free: disk.FreeBlock,
  file: disk.FileBlock,
) -> Result(disk.FreeBlock, Nil) {
  case int.compare(free.size, file.size) {
    order.Eq -> Error(Nil)
    order.Gt ->
      Ok(disk.FreeBlock(
        index: free.index + file.size,
        size: free.size - file.size,
      ))
    order.Lt -> panic as "free block has to be at least as big as file block"
  }
}
