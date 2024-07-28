import aoc/aoc
import aoc/input
import aoc/part
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub fn main() {
  let input = input.read(2023, 1)
  let one = part.one(input, solve_part_one)
  let two = part.two(input, solve_part_two)

  // io.println(aoc.run_fake(one, "142"))
  // io.println(aoc.run_real(one))

  io.println(aoc.run_fake(two, "281"))
  io.println(aoc.run_real(two))
}

fn solve_part_one(input: String) -> String {
  string.split(input, "\n")
  |> list.map(parse_line)
  |> list.fold(0, fn(acc, x) { acc + x })
  |> int.to_string
}

fn solve_part_two(input: String) -> String {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let left = parse_left(line)
    let right = parse_right(line)
    let assert Ok(value) = int.undigits([left, right], 10)
    value
  })
  |> list.fold(0, int.add)
  |> int.to_string()
}

fn parse_line(line: String) -> Int {
  let digits =
    line
    |> string.split("")
    |> list.filter_map(int.parse)
  let assert Ok(first) = list.first(digits)
  let assert Ok(last) = list.last(digits)
  io.debug([first, last])
  10 * first + last
}

fn substitute_word(line: String) -> String {
  line
  |> string.replace("one", "1")
  |> string.replace("two", "2")
  |> string.replace("three", "3")
  |> string.replace("four", "4")
  |> string.replace("five", "5")
  |> string.replace("six", "6")
  |> string.replace("seven", "7")
  |> string.replace("eight", "8")
  |> string.replace("nine", "9")
}

const string_to_int = [
  #("one", 1), #("two", 2), #("three", 3), #("four", 4), #("five", 5),
  #("six", 6), #("seven", 7), #("eight", 8), #("nine", 9),
]

fn parse_number_left(string: String) -> Result(Int, Nil) {
  use first <- result.try(string.first(string))
  int.parse(first)
}

fn parse_number_string_left(string: String) -> Result(Int, Nil) {
  list.find_map(string_to_int, fn(x) {
    case string.starts_with(string, x.0) {
      True -> Ok(x.1)
      False -> Error(Nil)
    }
  })
}

fn parse_left(line: String) -> Int {
  let number = parse_number_left(line)
  let number_string = parse_number_string_left(line)

  case result.or(number, number_string) {
    Ok(n) -> n
    Error(_) -> parse_left(string.drop_left(line, 1))
  }
}

fn parse_number_right(string: String) -> Result(Int, Nil) {
  use last <- result.try(string.last(string))
  int.parse(last)
}

fn parse_number_string_right(string: String) -> Result(Int, Nil) {
  list.find_map(string_to_int, fn(x) {
    case string.ends_with(string, x.0) {
      True -> Ok(x.1)
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
