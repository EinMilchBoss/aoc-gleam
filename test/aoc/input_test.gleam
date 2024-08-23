import filepath
import gleeunit/should
import simplifile

import aoc/input

const success = "SUCCESS"

const failure = simplifile.Unknown("FAILURE")

pub fn do_read_files_correct_files_test() {
  let assert Ok(actual) = input.do_read_files(year: 1000, day: 10, with: Ok(_))

  should.equal(input.fake_one(actual), "./res/year_1000/day_10/fake_one.txt")
  should.equal(input.fake_two(actual), "./res/year_1000/day_10/fake_two.txt")
  should.equal(input.real(actual), "./res/year_1000/day_10/real.txt")
}

pub fn do_read_files_with_padding_test() {
  let expected_year = "year_0001"
  let expected_day = "day_01"

  let assert Error(read_error) =
    input.do_read_files(year: 1, day: 1, with: fn(_) { Error(failure) })
  let assert [_, _, actual_year, actual_day, ..] =
    filepath.split(read_error.file)

  should.equal(actual_year, expected_year)
  should.equal(actual_day, expected_day)
}

pub fn do_read_files_first_file_error_test() {
  let expected =
    input.ReadError(file: "./res/year_1000/day_10/fake_one.txt", cause: failure)

  let assert Error(actual) =
    input.do_read_files(year: 1000, day: 10, with: fn(file) {
      case filepath.base_name(file) {
        "fake_one.txt" -> Error(failure)
        "fake_two.txt" -> Ok(success)
        "real.txt" -> Ok(success)
        _ -> panic
      }
    })

  should.equal(actual, expected)
}

pub fn do_read_files_last_file_error_test() {
  let expected =
    input.ReadError(file: "./res/year_1000/day_10/real.txt", cause: failure)

  let assert Error(actual) =
    input.do_read_files(year: 1000, day: 10, with: fn(file) {
      case filepath.base_name(file) {
        "fake_one.txt" -> Ok(success)
        "fake_two.txt" -> Ok(success)
        "real.txt" -> Error(failure)
        _ -> panic
      }
    })

  should.equal(actual, expected)
}

pub fn do_read_files_multiple_error_test() {
  let expected =
    input.ReadError(file: "./res/year_2024/day_10/fake_one.txt", cause: failure)

  let assert Error(actual) =
    input.do_read_files(year: 2024, day: 10, with: fn(_) { Error(failure) })

  should.equal(actual, expected)
}
