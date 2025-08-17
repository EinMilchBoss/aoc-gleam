import gleam/float
import gleam/int
import gleam/result

pub type Operator {
  Add
  Multiply
  Concatenate
}

pub fn as_function(operator: Operator) -> fn(Int, Int) -> Int {
  case operator {
    Add -> int.add
    Multiply -> int.multiply
    Concatenate -> concatenate
  }
}

fn concatenate(left: Int, right: Int) {
  let assert Ok(offset) =
    int.power(10, int.to_float(get_digit_amount(right)))
    |> result.map(float.truncate)
    as "the base is always 10"

  left * offset + right
}

fn get_digit_amount(number: Int) -> Int {
  do_get_digit_amount(int.absolute_value(number), 1)
}

fn do_get_digit_amount(number: Int, acc: Int) -> Int {
  case number < 10 {
    True -> acc
    False -> do_get_digit_amount(number / 10, acc + 1)
  }
}
