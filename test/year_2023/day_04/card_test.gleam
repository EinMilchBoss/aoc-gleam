import gleam/list
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

pub fn total_card_amount_one_card_test() {
  let cards =
    ["Card 1:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 1)
}

pub fn total_card_amount_two_cards_test() {
  let cards =
    ["Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 2)
}

pub fn total_card_amount_three_cards_test() {
  let cards =
    ["Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  0", "Card 3:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 3)
}

pub fn total_card_amount_first_wins_once_test() {
  let cards =
    ["Card 1:  1  2  3 |  1", "Card 2:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 3)
}

pub fn total_card_amount_first_wins_twice_test() {
  let cards =
    [
      "Card 1:  1  2  3 |  1  2", "Card 2:  1  2  3 |  0",
      "Card 3:  1  2  3 |  0",
    ]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 5)
}

pub fn total_card_amount_second_wins_once_test() {
  let cards =
    ["Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  1", "Card 3:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 4)
}

pub fn total_card_amount_second_wins_twice_test() {
  let cards =
    [
      "Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  1  2",
      "Card 3:  1  2  3 |  0", "Card 4:  1  2  3 |  0",
    ]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 6)
}

pub fn total_card_amount_different_win_once_test() {
  let cards =
    ["Card 1:  1  2  3 |  1", "Card 2:  1  2  3 |  2", "Card 3:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = card.total_card_amount(of: cards)

  should.equal(actual, 6)
}
