import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

import parallel_map

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

type Grid {
  Grid(tiles: Dict(Point, Tile), width: Int, height: Int)
}

type Point {
  Point(x: Int, y: Int)
}

type Tile {
  Empty
  Roll
}

fn parse_tile(grapheme: String) -> Result(Tile, Nil) {
  case grapheme {
    "@" -> Ok(Roll)
    "." -> Ok(Empty)
    _ -> Error(Nil)
  }
}

fn part_one(input: String) -> String {
  let grid = parse(input)

  grid
  |> get_accessible_rolls()
  |> set.size()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let grid = parse(input)

  get_all_accessible_rolls(grid) |> set.size() |> int.to_string()
}

fn parse(input: String) -> Grid {
  let lines = string.split(input, "\n")
  let height = list.length(lines)

  let assert Ok(first_line) = list.first(lines)
  let width = string.length(first_line)

  let tiles =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes()
      |> list.index_map(fn(value, x) {
        let assert Ok(tile) = parse_tile(value) as "we only pass graphemes"

        #(Point(x:, y:), tile)
      })
    })
    |> list.flatten()
    |> dict.from_list()

  Grid(tiles:, width:, height:)
}

fn get_all_accessible_rolls(grid: Grid) {
  let roll_points =
    grid.tiles
    |> dict.filter(fn(_, value) { value == Roll })
    |> dict.keys()
  let all_roll_points = set.from_list(roll_points)

  do_get_all_accessible_rolls(roll_points, all_roll_points, set.new())
}

fn do_get_all_accessible_rolls(
  roll_points: List(Point),
  all_roll_points: Set(Point),
  acc: Set(Point),
) -> Set(Point) {
  let accessable_roll_points =
    do_get_accessible_rolls(roll_points, all_roll_points, set.new())
  let next_all_roll_points =
    set.difference(all_roll_points, accessable_roll_points)

  case set.size(accessable_roll_points) == 0 {
    True -> acc
    False ->
      do_get_all_accessible_rolls(
        set.to_list(next_all_roll_points),
        next_all_roll_points,
        set.union(acc, accessable_roll_points),
      )
  }
}

fn get_accessible_rolls(grid: Grid) -> Set(Point) {
  let roll_points =
    grid.tiles
    |> dict.filter(fn(_, value) { value == Roll })
    |> dict.keys()
  let all_roll_points = set.from_list(roll_points)

  do_get_accessible_rolls(roll_points, all_roll_points, set.new())
}

fn do_get_accessible_rolls(
  roll_points: List(Point),
  all_roll_points: Set(Point),
  acc: Set(Point),
) -> Set(Point) {
  case roll_points {
    [] -> acc
    [roll_point, ..next_roll_points] -> {
      let neighbor_points = get_neighbors(of: roll_point)

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

fn get_neighbors(of center: Point) -> Set(Point) {
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
