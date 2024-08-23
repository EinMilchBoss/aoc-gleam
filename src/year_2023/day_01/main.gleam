import aoc/aoc
import aoc/input
import aoc/part
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const string_to_int = [
  #("one", 1), #("two", 2), #("three", 3), #("four", 4), #("five", 5),
  #("six", 6), #("seven", 7), #("eight", 8), #("nine", 9),
]

pub fn main() {
  let input = input.read_files(2023, 1)

  let one = part.one(input, solve_part_one)
  let two = part.two(input, solve_part_two)

  io.println(aoc.run_fake_one(one, "142"))
  io.println(aoc.run_real(one))

  io.println(aoc.run_fake_two(two, "281"))
  io.println(aoc.run_real(two))
}

fn solve_part_one(input: String) -> String {
  string.split(input, "\n")
  |> list.map(parse_line)
  |> list.fold(0, int.add)
  |> int.to_string()
}

fn solve_part_two(input: String) -> String {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let first = parse_left(line)
    let last = parse_right(line)
    to_value(first, last)
  })
  |> list.fold(0, int.add)
  |> int.to_string()
}

fn parse_line(line: String) -> Int {
  let digits =
    line
    |> string.to_graphemes()
    |> list.filter_map(int.parse)
  let assert Ok(first) = list.first(digits)
  let assert Ok(last) = list.last(digits)
  to_value(first, last)
}

fn parse_left(line: String) -> Int {
  let number = parse_number_left(line)
  let number_string = parse_number_string_left(line)

  case result.or(number, number_string) {
    Ok(n) -> n
    Error(_) -> parse_left(string.drop_left(line, 1))
  }
}

fn to_value(first_digit: Int, last_digit: Int) -> Int {
  10 * first_digit + last_digit
}

fn parse_number_left(string: String) -> Result(Int, Nil) {
  use first <- result.try(string.first(string))
  int.parse(first)
}

fn parse_number_string_left(string: String) -> Result(Int, Nil) {
  list.find_map(string_to_int, fn(x) {
    let #(number_string, number) = x
    case string.starts_with(string, number_string) {
      True -> Ok(number)
      False -> Error(Nil)
    }
  })
}

fn parse_right(line: String) -> Int {
  let number = parse_number_right(line)
  let number_string = parse_number_string_right(line)

  case result.or(number, number_string) {
    Ok(n) -> n
    Error(_) -> parse_right(string.drop_right(line, 1))
  }
}

fn parse_number_right(string: String) -> Result(Int, Nil) {
  use last <- result.try(string.last(string))
  int.parse(last)
}

fn parse_number_string_right(string: String) -> Result(Int, Nil) {
  list.find_map(string_to_int, fn(x) {
    let #(number_string, number) = x
    case string.ends_with(string, number_string) {
      True -> Ok(number)
      False -> Error(Nil)
    }
  })
}
