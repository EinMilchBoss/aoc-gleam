import gleam/float
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
  let input = input.read_files(year: 2025, day: 3)

  let one = part.one(input, part_one)
  let two = part.two(input, part_two)

  io.println(aoc.run_fake_one(one, "357"))
  io.println(aoc.run_real(one))
  io.println(aoc.run_fake_two(two, "3121910778619"))
  io.println(aoc.run_real(two))
}

fn part_one(input: String) -> String {
  input
  |> string.split("\n")
  |> list.map(fn(bank) {
    let assert Ok(sum) =
      bank
      |> string.to_graphemes()
      |> list.combination_pairs()
      |> list.map(fn(pair) {
        let merged = pair.0 <> pair.1
        let assert Ok(parsed) = int.parse(merged) as "all joltages are ints"
        parsed
      })
      |> list.max(int.compare)
      as "there is at least one joltage per bank"
    sum
  })
  |> int.sum()
  |> int.to_string()
}

fn part_two(input: String) -> String {
  let assert Ok(maxes) =
    input
    |> string.split("\n")
    |> parallel_map.list_pmap(
      fn(bank) {
        let digits =
          bank
          |> string.to_graphemes()
          |> list.map(fn(grapheme) {
            let assert Ok(digit) = int.parse(grapheme)
              as "all joltages are ints"
            digit
          })
        find_max(digits, 12)
      },
      parallel_map.MatchSchedulersOnline,
      10_000,
    )
    |> result.all()

  maxes
  |> int.sum()
  |> int.to_string()
}

fn find_max(digits: List(Int), n: Int) -> Int {
  do_find_max(digits, list.length(digits), n, 0)
}

fn do_find_max(digits: List(Int), digits_length: Int, n: Int, acc: Int) -> Int {
  case n > 0 {
    // A number with less than 0 digits is no number. We are done.
    True -> acc
    False -> {
      // We need at least n - 1 digits left or else we won't reach our required length.
      let possibles = list.take(digits, digits_length - n + 1)

      // Prepend max digit by offsetting it with a multiplier based on n.
      let assert Ok(max_digit) = list.max(possibles, int.compare)
        as "there has to be at least one possible digit"
      let assert Ok(multiplier) = int.power(10, int.to_float(n - 1))
        as "base is always 10"
      let next_acc = acc + max_digit * float.truncate(multiplier)

      let max_digit_indices =
        possibles
        |> list.index_map(fn(possible, i) { #(i, possible) })
        |> list.filter(fn(pair) { pair.1 == max_digit })
        |> list.map(fn(pair) { pair.0 })

      let next_n = n - 1

      let assert Ok(max) =
        max_digit_indices
        |> list.map(fn(max_digit_index) {
          // We have to preserve order, so we cannot use the part until the current index anymore.
          let reduction = max_digit_index + 1
          let next_digits = list.drop(digits, reduction)
          let next_digits_length = digits_length - reduction

          // Find the n - 1 largest number with the remaining digits.
          do_find_max(next_digits, next_digits_length, next_n, next_acc)
        })
        |> list.max(int.compare)
        as "there is always a maximum and therefore indices"
      max
    }
  }
}
