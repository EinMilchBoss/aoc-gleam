import gleeunit/should
import year_2023/day_03/engine_part.{EnginePart}

const default = engine_part.EnginePart(0, 0, 0, 0)

pub fn end_test() {
  let expected = 2
  let engine_part = EnginePart(..default, start: 0, length: 3)

  let actual = engine_part.end(engine_part)

  actual |> should.equal(expected)
}

pub fn parse_one_test() {
  let expected = [EnginePart(number: 123, y: 0, start: 0, length: 3)]
  let input = "123"

  let actual = engine_part.parse(input)

  actual |> should.equal(expected)
}
