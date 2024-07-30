import aoc/aoc
import aoc/input
import aoc/part
import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Game {
  Game(number: Int, sets: List(Set))
}

type Set {
  Set(r: Int, g: Int, b: Int)
}

pub fn main() {
  let input = input.read(2023, 2)

  let one = part.one(input, solve_part_one)

  io.println(aoc.run_fake_one(one, "8"))
  // io.println(aoc.run_real(one))
}

fn solve_part_one(input: String) -> String {
  let is_possible = is_possible(_, with: Set(12, 13, 14))
  input
  |> parse_games()
  |> list.filter_map(fn(game) {
    case list.all(game.sets, is_possible) {
      True -> Ok(game.number)
      False -> Error(Nil)
    }
  })
  |> list.fold(0, int.add)
  |> int.to_string()
}

fn is_possible(set: Set, with max: Set) -> Bool {
  set.r <= max.r && set.g <= max.g && set.b <= max.b
}

fn power(set: Set) -> Int {
  set.r * set.g * set.b
}

fn parse_games(input: String) -> List(Game) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [game_part, sets_part] = string.split(line, ": ")
    let number = parse_game_number(game_part)
    let sets =
      sets_part
      |> string.split("; ")
      |> list.map(parse_game_set)
    Game(number, sets)
  })
}

fn parse_game_number(input: String) -> Int {
  let assert [_, game_number] = string.split(input, " ")
  let assert Ok(game_number) = int.parse(game_number)
  game_number
}

fn parse_game_set(input: String) -> Set {
  input
  |> string.split(", ")
  |> list.fold(Set(0, 0, 0), fn(acc, cube) {
    let assert [amount, color] = string.split(cube, " ")
    let assert Ok(amount) = int.parse(amount)

    case color {
      "red" -> Set(..acc, r: acc.r + amount)
      "green" -> Set(..acc, g: acc.g + amount)
      "blue" -> Set(..acc, b: acc.b + amount)
      _ -> panic
    }
  })
}
