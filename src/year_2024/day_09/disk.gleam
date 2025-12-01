import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string
import gleam/string_tree

pub type Space {
  File(id: Int)
  Free
}

pub type FileBlock {
  FileBlock(index: Int, size: Int, id: Int)
}

pub type FreeBlock {
  FreeBlock(index: Int, size: Int)
}

pub type DiskMap =
  Dict(Int, Space)

pub fn calculate_checksum(disk_map: DiskMap) -> Int {
  list.range(0, dict.size(disk_map) - 1)
  |> list.map(fn(index) {
    let assert Ok(space) = dict.get(disk_map, index)
      as "indices are created based on length"

    let assert File(file_id) = space as "only files are left after compacting"

    index * file_id
  })
  |> int.sum()
}

pub fn parse_map(layout: String) -> DiskMap {
  layout
  |> string.to_graphemes()
  |> list.map(fn(string) {
    let assert Ok(int) = int.parse(string) as "layout only consists of integers"

    int
  })
  |> do_parse_map(0, True, 0, dict.new())
}

fn do_parse_map(
  layout: List(Int),
  index: Int,
  is_file: Bool,
  file_id: Int,
  acc: DiskMap,
) -> DiskMap {
  case layout {
    [] -> acc
    [times, ..next_layout] -> {
      let next_index = index + times
      let next_is_file = !is_file

      case times {
        // Skip everything and proceed with next.
        0 -> do_parse_map(next_layout, next_index, next_is_file, file_id, acc)
        _ -> {
          let #(next_file_id, next_acc) = case is_file {
            True -> {
              let next_acc =
                list.range(index, next_index - 1)
                |> list.map(fn(index) { #(index, File(file_id)) })
                |> dict.from_list()
                |> dict.merge(acc)

              #(file_id + 1, next_acc)
            }
            False -> {
              let next_acc =
                list.range(index, next_index - 1)
                |> list.map(fn(index) { #(index, Free) })
                |> dict.from_list()
                |> dict.merge(acc)

              #(file_id, next_acc)
            }
          }

          do_parse_map(
            next_layout,
            next_index,
            next_is_file,
            next_file_id,
            next_acc,
          )
        }
      }
    }
  }
}

pub fn parse_blocks(layout: String) -> #(List(FileBlock), List(FreeBlock)) {
  let #(files, frees, _, _) =
    layout
    |> string.to_graphemes()
    |> list.map(fn(string) {
      let assert Ok(int) = int.parse(string)
        as "layout only consists of integers"

      int
    })
    |> list.index_fold(#([], [], 0, 0), fn(acc, times, index) {
      let #(files, frees, actual_index, file_id) = acc

      case int.bitwise_and(index, 0b1) {
        0 -> #(
          [FileBlock(actual_index, times, file_id), ..files],
          frees,
          actual_index + times,
          file_id + 1,
        )
        1 -> #(
          files,
          [FreeBlock(actual_index, times), ..frees],
          actual_index + times,
          file_id,
        )
        _ -> panic as "an int can only be even or odd"
      }
    })

  #(files, frees)
}

pub fn debug(disk_map: DiskMap) -> String {
  use <- bool.guard(dict.size(disk_map) == 0, "")

  list.range(0, dict.size(disk_map) - 1)
  |> list.fold(string_tree.new(), fn(acc, index) {
    let assert Ok(space) = dict.get(disk_map, index)
      as "indices are created based on length"

    case space {
      File(id) -> string_tree.append(acc, int.to_string(id))
      Free -> string_tree.append(acc, ".")
    }
  })
  |> string_tree.to_string()
}

pub fn compact(disk_map: DiskMap) -> DiskMap {
  do_compact(disk_map, 0, dict.size(disk_map) - 1)
}

fn do_compact(disk_map: DiskMap, front_index: Int, back_index: Int) -> DiskMap {
  let next_back_index = back_index - 1

  case dict.get(disk_map, back_index) {
    // This only ever happens if we only have free spaces and no files at all.
    Error(_) -> disk_map
    Ok(space) -> {
      case space {
        // Skip this space and fill it later on.
        Free -> {
          let next_disk_map = dict.delete(disk_map, back_index)

          do_compact(next_disk_map, front_index, next_back_index)
        }
        file -> {
          case get_next_free_index(disk_map, front_index) {
            // No more space left so we cannot compact any further.
            Error(_) -> disk_map
            Ok(next_front_index) -> {
              let next_disk_map =
                disk_map
                |> dict.insert(next_front_index, file)
                |> dict.delete(back_index)

              do_compact(next_disk_map, next_front_index, next_back_index)
            }
          }
        }
      }
    }
  }
}

fn get_next_free_index(disk_map: DiskMap, index: Int) -> Result(Int, Nil) {
  case dict.get(disk_map, index) {
    // Index does not exist so there is no empty space left.
    Error(_) -> Error(Nil)
    Ok(space) -> {
      case space {
        // We found the index of the next free space.
        Free -> Ok(index)
        File(_) -> get_next_free_index(disk_map, index + 1)
      }
    }
  }
}
