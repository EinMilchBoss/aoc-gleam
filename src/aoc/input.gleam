import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gleam/string_builder as sb
import plinth/node/process
import simplifile.{type FileError}

pub opaque type Input {
  Input(fake_one: String, fake_two: String, real: String)
}

pub fn fake_one(input: Input) -> String {
  input.fake_one
}

pub fn fake_two(input: Input) -> String {
  input.fake_two
}

pub fn real(input: Input) -> String {
  input.real
}

pub fn read_files(year year: Int, day day: Int) -> Input {
  do_read_files(year:, day:, with: simplifile.read) |> exit_on_file_error()
}

@internal
pub type ReadError {
  ReadError(file: String, cause: FileError)
}

@internal
pub fn do_read_files(
  year year: Int,
  day day: Int,
  with read: fn(String) -> Result(String, FileError),
) -> Result(Input, ReadError) {
  let year = int.to_string(year) |> string.pad_left(4, "0")
  let day = int.to_string(day) |> string.pad_left(2, "0")
  let path = "./res/year_" <> year <> "/day_" <> day

  let read_file = read_file(_, with: read)
  use fake_one <- result.try(read_file(path <> "/fake_one.txt"))
  use fake_two <- result.try(read_file(path <> "/fake_two.txt"))
  use real <- result.try(read_file(path <> "/real.txt"))
  Ok(Input(fake_one:, fake_two:, real:))
}

fn read_file(
  file file: String,
  with read: fn(String) -> Result(String, FileError),
) -> Result(String, ReadError) {
  read(file) |> result.map_error(ReadError(file, _))
}

fn exit_on_file_error(result: Result(Input, ReadError)) -> Input {
  case result {
    Ok(content) -> content
    Error(error) -> {
      sb.new()
      |> sb.append("Could not load input file \"")
      |> sb.append(error.file)
      |> sb.append("\".\nReason: ")
      |> sb.append(simplifile.describe_error(error.cause))
      |> sb.append(".")
      |> sb.to_string()
      |> io.println_error()

      process.exit(1)
      panic
    }
  }
}
