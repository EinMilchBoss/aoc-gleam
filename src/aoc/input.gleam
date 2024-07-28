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
  let real = case
    simplifile.read("./res/year_" <> year <> "/day_" <> day <> "/real.txt")
  {
    Ok(real) -> real
    Error(err) -> {
      let err_msg =
        string_builder.new()
        |> string_builder.append("Could not load input file \"real\".\n")
        |> string_builder.append(simplifile.describe_error(err))
        |> string_builder.to_string
      io.print_error(err_msg)
      process.exit(1)

      ""
    }
  }
  let fake = case
    simplifile.read("./res/year_" <> year <> "/day_" <> day <> "/fake.txt")
  {
    Ok(fake) -> fake
    Error(err) -> {
      let err_msg =
        string_builder.new()
        |> string_builder.append("Could not load input file \"fake\".\n")
        |> string_builder.append(simplifile.describe_error(err))
        |> string_builder.to_string
      io.print_error(err_msg)
      process.exit(1)

      ""
    }
  }
  Input(real, fake)
}
