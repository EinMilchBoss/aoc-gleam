import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

import aoc
import aoc/input
import aoc/part

pub fn main() {
  let input = input.read_files(year: 2025, day: 4)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "13"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "43"))
  io.println(aoc.run_real(two))
}

type Point {
  Point(x: Int, y: Int)
}

fn part_one(input: String) -> String {
  let roll_points = get_roll_points(input)

  roll_points
  |> get_accessible_rolls()
  |> set.size()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let roll_points = get_roll_points(input)

  roll_points
  |> get_all_accessible_rolls()
  |> set.size()
  |> int.to_string()
}

fn get_roll_points(input: String) -> Set(Point) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(value, x) {
      case is_roll(value) {
        True -> Ok(Point(x:, y:))
        False -> Error(Nil)
      }
    })
    |> list.filter_map(function.identity)
  })
  |> list.flatten()
  |> set.from_list()
}

fn is_roll(grapheme: String) -> Bool {
  case grapheme {
    "@" -> True
    _ -> False
  }
}

fn get_all_accessible_rolls(roll_points: Set(Point)) {
  do_get_all_accessible_rolls(roll_points, set.new())
}

fn do_get_all_accessible_rolls(
  roll_points: Set(Point),
  acc: Set(Point),
) -> Set(Point) {
  let accessible_roll_points = get_accessible_rolls(roll_points)
  let next_roll_points = set.difference(roll_points, accessible_roll_points)

  case set.size(accessible_roll_points) == 0 {
    True -> acc
    False ->
      do_get_all_accessible_rolls(
        next_roll_points,
        set.union(acc, accessible_roll_points),
      )
  }
}

fn get_accessible_rolls(roll_points: Set(Point)) -> Set(Point) {
  do_get_accessible_rolls(set.to_list(roll_points), roll_points, set.new())
}

fn do_get_accessible_rolls(
  roll_points: List(Point),
  all_roll_points: Set(Point),
  acc: Set(Point),
) -> Set(Point) {
  case roll_points {
    [] -> acc
    [roll_point, ..next_roll_points] -> {
      let neighbor_points = get_neighbor_points_unchecked(roll_point)

      let intersection =
        set.intersection(of: neighbor_points, and: all_roll_points)
      let next_acc = case set.size(intersection) < 4 {
        True -> set.insert(acc, roll_point)
        False -> acc
      }

      do_get_accessible_rolls(next_roll_points, all_roll_points, next_acc)
    }
  }
}

/// Returns all neighbors of a point even if they are out of bounds.
fn get_neighbor_points_unchecked(center: Point) -> Set(Point) {
  [
    // Upper layer.
    Point(center.x - 1, center.y - 1),
    Point(center.x, center.y - 1),
    Point(center.x + 1, center.y - 1),

    // Same layer.
    Point(center.x - 1, center.y),
    Point(center.x + 1, center.y),

    // Lower layer.
    Point(center.x - 1, center.y + 1),
    Point(center.x, center.y + 1),
    Point(center.x + 1, center.y + 1),
  ]
  |> set.from_list()
}
