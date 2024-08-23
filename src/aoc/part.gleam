import aoc/input.{type Input}

pub opaque type Part {
  Part(number: Int, input: Input, solution: fn(String) -> String)
}

pub fn one(input: Input, solution: fn(String) -> String) -> Part {
  Part(1, input:, solution:)
}

pub fn two(input: Input, solution: fn(String) -> String) -> Part {
  Part(2, input:, solution:)
}

@internal
pub fn new(number: Int, input: Input, solution: fn(String) -> String) -> Part {
  Part(number:, input:, solution:)
}

pub fn number(part: Part) -> Int {
  part.number
}

pub fn input(part: Part) -> Input {
  part.input
}

pub fn solution(part: Part) -> fn(String) -> String {
  part.solution
}
