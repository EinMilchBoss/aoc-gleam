import gleeunit/should

import year_2023/day_05/part_one.{Entry}

pub fn translate_at_start_test() {
  let entry = Entry(destination: 10, source: 0, length: 5)

  let actual = part_one.translate(entry, 0)

  should.equal(actual, 10)
}

pub fn translate_at_end_test() {
  let entry = Entry(destination: 10, source: 0, length: 5)

  let actual = part_one.translate(entry, 4)

  should.equal(actual, 14)
}

pub fn contains_at_start_test() {
  let entry = Entry(destination: 10, source: 0, length: 5)

  let actual = part_one.contains(entry, 0)

  should.be_true(actual)
}

pub fn contains_at_end_test() {
  let entry = Entry(destination: 10, source: 0, length: 5)

  let actual = part_one.contains(entry, 4)

  should.be_true(actual)
}

pub fn contains_before_start_test() {
  let entry = Entry(destination: 10, source: 0, length: 5)

  let actual = part_one.contains(entry, -1)

  should.be_false(actual)
}

pub fn contains_after_end_test() {
  let entry = Entry(destination: 10, source: 0, length: 5)

  let actual = part_one.contains(entry, 5)

  should.be_false(actual)
}
