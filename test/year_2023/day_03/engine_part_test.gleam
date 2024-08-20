import gleeunit/should
import year_2023/day_03/engine_part.{EnginePart}

const default = engine_part.EnginePart(0, 0, 0, 0)

pub fn end_test() {
  let expected = 2
  let engine_part = EnginePart(..default, start: 0, length: 3)

  let actual = engine_part.end(engine_part)

  should.equal(actual, expected)
}

pub fn parse_one_test() {
  let expected = [EnginePart(number: 123, y: 0, start: 0, length: 3)]
  let input = "123"

  let actual = engine_part.parse(input)

  should.equal(actual, expected)
}

pub fn parse_one_with_padding_test() {
  let expected = [EnginePart(number: 123, y: 0, start: 1, length: 3)]
  let input = ".123."

  let actual = engine_part.parse(input)

  should.equal(actual, expected)
}

pub fn parse_multiple_test() {
  let expected = [
    EnginePart(number: 456, y: 0, start: 4, length: 3),
    EnginePart(number: 123, y: 0, start: 0, length: 3),
  ]
  let input = "123.456"

  let actual = engine_part.parse(input)

  should.equal(actual, expected)
}

pub fn parse_multiple_with_padding_test() {
  let expected = [
    EnginePart(number: 456, y: 0, start: 5, length: 3),
    EnginePart(number: 123, y: 0, start: 1, length: 3),
  ]
  let input = ".123.456."

  let actual = engine_part.parse(input)

  should.equal(actual, expected)
}
