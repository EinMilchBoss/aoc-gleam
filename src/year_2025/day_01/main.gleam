import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc
import aoc/input
import aoc/part

type Rotation {
  Left(distance: Int)
  Right(distance: Int)
}

pub fn main() {
  let input = input.read_files(year: 2025, day: 1)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "3"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "6"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  let rotations: List(Rotation) =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(distance) = line |> string.drop_start(1) |> int.parse()
        as "every line has a valid int at the end"
      case line {
        "L" <> _ -> Left(distance:)
        "R" <> _ -> Right(distance:)
        _ -> panic as "every line starts with L or R"
      }
    })

  count_zeros_end(rotations) |> int.to_string()
}

fn part_two(input: String) -> String {
  let rotations: List(Rotation) =
    input
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(distance) = line |> string.drop_start(1) |> int.parse()
        as "every line has a valid int at the end"
      case line {
        "L" <> _ -> Left(distance:)
        "R" <> _ -> Right(distance:)
        _ -> panic as "every line starts with L or R"
      }
    })

  count_zeros_all(rotations) |> int.to_string()
}

fn count_zeros_end(rotations: List(Rotation)) -> Int {
  do_count_zeros_end(rotations, 50, 0)
}

fn do_count_zeros_end(
  rotations: List(Rotation),
  pointee: Int,
  zero_counter: Int,
) -> Int {
  case rotations {
    [] -> zero_counter
    [rotation, ..next_rotations] -> {
      let next_pointee = rotate(pointee, by: rotation)

      case next_pointee {
        0 -> do_count_zeros_end(next_rotations, next_pointee, zero_counter + 1)
        x if 1 <= x && x <= 99 ->
          do_count_zeros_end(next_rotations, next_pointee, zero_counter)
        _ -> panic as "an unreachable number was selected after rotation"
      }
    }
  }
}

fn count_zeros_all(rotations: List(Rotation)) -> Int {
  do_count_zeros_all(rotations, 50, 0)
}

fn do_count_zeros_all(
  rotations: List(Rotation),
  pointee: Int,
  zero_counter: Int,
) -> Int {
  case rotations {
    [] -> zero_counter
    [rotation, ..next_rotations] -> {
      let next_pointee = rotate(pointee, by: rotation)

      let total_rotations = rotation.distance / 100
      let additional_rotation = case pointee == 0 {
        // Only total rotations can increment the zero counter if the original pointee was 0.
        True -> 0
        False -> {
          case rotation {
            Left(_) if next_pointee > pointee -> 1
            Right(_) if next_pointee < pointee -> 1
            // If 0 was reached exactly, it shall be included in the counter.
            // The next iteration would ignore this case, see first condition.
            _ if next_pointee == 0 -> 1
            _ -> 0
          }
        }
      }
      let next_zero_counter =
        zero_counter + total_rotations + additional_rotation

      case next_pointee {
        x if 0 <= x && x <= 99 ->
          do_count_zeros_all(next_rotations, next_pointee, next_zero_counter)
        _ -> panic as "an unreachable number was selected after rotation"
      }
    }
  }
}

fn rotate(pointee: Int, by rotation: Rotation) -> Int {
  let assert Ok(next_pointee) = case rotation {
    Left(distance) -> int.modulo(pointee - distance, 100)
    Right(distance) -> int.modulo(pointee + distance, 100)
  }
    as "the divisor is always non zero"

  next_pointee
}
