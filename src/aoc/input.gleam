import gleam/int
import gleam/io
import gleam/string
import gleam/string_builder as sb
import plinth/node/process
import simplifile

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

pub fn read(year: Int, day: Int) -> Input {
  let year = int.to_string(year) |> string.pad_left(4, "0")
  let day = int.to_string(day) |> string.pad_left(2, "0")
  let fake_one =
    read_or_exit("./res/year_" <> year <> "/day_" <> day <> "/fake_one.txt")
  let fake_two =
    read_or_exit("./res/year_" <> year <> "/day_" <> day <> "/fake_two.txt")
  let real =
    read_or_exit("./res/year_" <> year <> "/day_" <> day <> "/real.txt")
  Input(fake_one, fake_two, real)
}

fn read_or_exit(file: String) -> String {
  case simplifile.read(file) {
    Ok(content) -> content
    Error(error) -> {
      sb.new()
      |> sb.append("Could not load input file \"")
      |> sb.append(file)
      |> sb.append("\".\nReason: ")
      |> sb.append(simplifile.describe_error(error))
      |> sb.append(".")
      |> sb.to_string()
      |> io.println_error()
      process.exit(1)
      panic
    }
  }
}
