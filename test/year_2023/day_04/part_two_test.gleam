import gleam/list

import gleeunit/should

import year_2023/day_04/card
import year_2023/day_04/part_two

pub fn total_card_amount_one_card_test() {
  let cards =
    ["Card 1:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 1)
}

pub fn total_card_amount_two_cards_test() {
  let cards =
    ["Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 2)
}

pub fn total_card_amount_three_cards_test() {
  let cards =
    ["Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  0", "Card 3:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 3)
}

pub fn total_card_amount_first_wins_once_test() {
  let cards =
    ["Card 1:  1  2  3 |  1", "Card 2:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 3)
}

pub fn total_card_amount_first_wins_twice_test() {
  let cards =
    [
      "Card 1:  1  2  3 |  1  2", "Card 2:  1  2  3 |  0",
      "Card 3:  1  2  3 |  0",
    ]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 5)
}

pub fn total_card_amount_second_wins_once_test() {
  let cards =
    ["Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  1", "Card 3:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 4)
}

pub fn total_card_amount_second_wins_twice_test() {
  let cards =
    [
      "Card 1:  1  2  3 |  0", "Card 2:  1  2  3 |  1  2",
      "Card 3:  1  2  3 |  0", "Card 4:  1  2  3 |  0",
    ]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 6)
}

pub fn total_card_amount_different_win_once_test() {
  let cards =
    ["Card 1:  1  2  3 |  1", "Card 2:  1  2  3 |  2", "Card 3:  1  2  3 |  0"]
    |> list.map(card.from_line)

  let actual = part_two.total_card_amount(cards)

  should.equal(actual, 6)
}
