import gleam/set

import gleeunit/should

import year_2023/day_04/card.{Card}

pub fn from_line_one_digit_test() {
  let expected =
    Card(
      number: 1,
      winning: set.from_list([1, 8, 3, 6, 7]),
      owned: set.from_list([3, 6, 6, 1, 7, 9, 8, 3]),
    )

  let actual =
    card.from_line("Card 1:  1  8  3  6  7 |  3  6  6  1  7  9  8  3")

  should.equal(actual, expected)
}

pub fn from_line_two_digits_test() {
  let expected =
    Card(
      number: 1,
      winning: set.from_list([41, 48, 83, 86, 17]),
      owned: set.from_list([83, 86, 16, 31, 17, 19, 48, 53]),
    )

  let actual =
    card.from_line("Card 1: 41 48 83 86 17 | 83 86 16 31 17 19 48 53")

  should.equal(actual, expected)
}

pub fn from_line_different_length_test() {
  let expected =
    Card(
      number: 1,
      winning: set.from_list([41, 48, 83, 86, 17]),
      owned: set.from_list([83, 86, 6, 31, 17, 9, 48, 53]),
    )

  let actual =
    card.from_line("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53")

  should.equal(actual, expected)
}
