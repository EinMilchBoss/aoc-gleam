import gleam/int
import gleam/io
import gleam/string
import gleam/string_builder
import plinth/node/process
import simplifile

pub opaque type Input {
  Input(fake: String, real: String)
}

pub fn fake(input: Input) {
  input.fake
}

pub fn real(input: Input) {
  input.real
}

pub fn read(year: Int, day: Int) -> Input {
  let year = int.to_string(year) |> string.pad_left(4, "0")
  let day = int.to_string(day) |> string.pad_left(2, "0")
  let real =
    read_or_exit("./res/year_" <> year <> "/day_" <> day <> "/real.txt")
  let fake =
    read_or_exit("./res/year_" <> year <> "/day_" <> day <> "/fake.txt")
  Input(fake, real)
}

fn read_or_exit(file: String) -> String {
  case simplifile.read(file) {
    Ok(content) -> content
    Error(error) -> {
      string_builder.new()
      |> string_builder.append("Could not load input file.\n")
      |> string_builder.append(simplifile.describe_error(error))
      |> string_builder.to_string()
      |> io.print_error()
      process.exit(1)
      panic
    }
  }
}
