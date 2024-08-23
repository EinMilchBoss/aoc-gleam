import aoc
import aoc/input
import aoc/part
import gleam/function
import gleeunit/should

const success = "SUCCESS"

const failure = "FAILURE"

pub fn run_fake_success_test() {
  let expected = "Part 0 (fake): " <> success <> " (Result: PASS)"
  let assert Ok(input) =
    input.do_read_files(year: 1000, day: 10, with: fn(_) { Ok("") })
  let part = part.new(0, input, function.identity)

  let actual = aoc.run_fake(part, expected: success, with: fn(_) { success })

  should.equal(actual, expected)
}

pub fn run_fake_failure_test() {
  let expected = "Part 0 (fake): " <> failure <> " (Result: FAIL)"
  let assert Ok(input) =
    input.do_read_files(year: 1000, day: 10, with: fn(_) { Ok("") })
  let part = part.new(0, input, function.identity)

  let actual = aoc.run_fake(part, expected: success, with: fn(_) { failure })

  should.equal(actual, expected)
}

pub fn run_real_test() {
  let expected = "Part 0 (real): " <> success
  let assert Ok(input) =
    input.do_read_files(year: 1000, day: 10, with: fn(_) { Ok(success) })
  let part = part.new(0, input, function.identity)

  let actual = aoc.run_real(part)

  should.equal(actual, expected)
}
