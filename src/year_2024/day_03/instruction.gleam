import gleam/list
import gleam/regexp

import year_2024/day_03/submatches

pub type Instruction {
  Multiply(left: Int, right: Int)
  Enable
  Disable
}

pub fn parse(input: String) -> List(Instruction) {
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(re) =
    regexp.compile("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)", options)
  let matches = regexp.scan(re, input)

  do_parse_instructions(matches, []) |> list.reverse()
}

fn do_parse_instructions(matches: List(regexp.Match), acc: List(Instruction)) {
  case matches {
    [] -> acc
    [match, ..rest] -> {
      case match.content {
        "do()" -> do_parse_instructions(rest, [Enable, ..acc])
        "don't()" -> do_parse_instructions(rest, [Disable, ..acc])
        _ -> {
          let #(left, right) = submatches.parse(match.submatches)
          do_parse_instructions(rest, [Multiply(left:, right:), ..acc])
        }
      }
    }
  }
}

pub fn to_pair(instruction: Instruction) -> Result(#(Int, Int), Nil) {
  case instruction {
    Multiply(a, b) -> Ok(#(a, b))
    _ -> Error(Nil)
  }
}

pub fn reduce(instructions: List(Instruction)) -> List(Instruction) {
  do_reduce_instructions(instructions, True, [])
}

fn do_reduce_instructions(
  instructions: List(Instruction),
  is_enabled: Bool,
  acc: List(Instruction),
) -> List(Instruction) {
  case is_enabled, instructions {
    _, [] -> acc
    True, [instruction, ..rest] -> {
      case instruction {
        Multiply(_, _) ->
          do_reduce_instructions(rest, True, [instruction, ..acc])
        Enable -> do_reduce_instructions(rest, True, acc)
        Disable -> do_reduce_instructions(rest, False, acc)
      }
    }
    False, [instruction, ..rest] -> {
      case instruction {
        Enable -> do_reduce_instructions(rest, True, acc)
        _ -> do_reduce_instructions(rest, False, acc)
      }
    }
  }
}
