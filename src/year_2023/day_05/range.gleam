import gleam/bool
import gleam/result

pub type Range {
  Range(start: Int, end_exclusive: Int)
}

pub fn length(range: Range) -> Int {
  range.end_exclusive - range.start
}

pub fn offset(range: Range, by offset: Int) -> Range {
  Range(
    start: range.start + offset,
    end_exclusive: range.end_exclusive + offset,
  )
}

pub fn is_equal(this: Range, to other: Range) -> Bool {
  this.start == other.start && this.end_exclusive == other.end_exclusive
}

// /// # Overlapping
// /// 
// /// ```
// /// first:  |-----|
// /// second:     |-----|
// /// result: |---|-|---|
// /// 
// /// first:      |-----|
// /// second: |-----|
// /// result: |---|-|---|
// /// ```
// /// 
// /// # Separated
// /// 
// /// ```
// /// first:  |-----|
// /// second:        |-----|
// /// result: |-----||-----|
// /// 
// /// first:  |-----|
// /// second:        |-----|
// /// result: |-----||-----|
// /// ```
// /// 
// /// # Equal
// /// 
// /// ```
// /// first:  |-----|
// /// second: |-----|
// /// result: |-----|
// /// ```
// /// 
// /// # Contained
// /// 
// /// ```
// /// first:  |-----|
// /// second:   |-|
// /// result: |-----|
// /// ```
// pub fn split_overlapping(this: Range, other: Range) -> List(Range) {
//   use <- bool.guard(is_equal(this, other), [this])

//   case intersection(this, other) {
//     Error(_) -> [this, other]
//     Ok(intersection) -> {
//       [
//         Range(..this, end_exclusive: this.end_exclusive - length(intersection)),
//         Range(..other, start: other.start + length(intersection)),
//       ]
//     }
//   }
// }

// pub fn symmetric_difference(of this: Range, and other: Range) -> #(Range, Range) {
//   result.lazy_or(
//     symmetric_difference_unidirectional(of: this, and: other),
//     fn() { symmetric_difference_unidirectional(of: other, and: this) },
//   )
// }

// /// Returns the symmetric difference of first and second.
// /// ```
// /// first:  |-----|
// /// second:     |-----|
// /// result: |---| |---|
// /// 
// /// first:  |-----|
// /// second:        |-----|
// /// result: |-----||-----|
// /// ```
// /// 
// /// `Range`s cannot go in a descending direction.
// /// ```
// /// first:      |-----|
// /// second: |-----|
// /// result: Nil
// /// ```
// fn symmetric_difference_unidirectional(
//   of this: Range,
//   and other: Range,
// ) -> Result(#(Range, Range), Nil) {
//   result.map(
//     intersection_unidirectional(between: this, and: other),
//     fn(intersection) {
//       #(
//         Range(..this, end_exclusive: this.end_exclusive - length(intersection)),
//         Range(..other, start: other.start + length(intersection)),
//       )
//     },
//   )
// }

pub fn remove_intersection(this: Range, other: Range) -> List(Range) {
  use <- bool.guard(is_equal(this, other), [this])

  result.lazy_or(
    split_by_intersection_unidirectional(between_left: this, and_right: other),
    fn() {
      split_by_intersection_unidirectional(between_left: other, and_right: this)
    },
  )
  |> todo
}

fn split_by_intersection_unidirectional(
  between_left left: Range,
  and_right right: Range,
) -> Result(List(Range), Nil) {
  intersection_unidirectional(between_left: left, and_right: right)
  |> result.map(fn(intersection) {
    case intersection {
      // Wrapped
      // |-----|
      //  |---|
      //  |---|
      _ if intersection.end_exclusive == right.end_exclusive -> [
        Range(..left, end_exclusive: intersection.start),
        intersection,
        Range(..left, start: intersection.end_exclusive),
      ]
      // Trailing
      // |-----|
      //   |---|
      //   |---|
      _ if intersection.end_exclusive == left.end_exclusive -> {
        [Range(..left, end_exclusive: intersection.start), intersection]
      }

      // Overlapping
      // |-----|
      //   |-----|
      //   |---|
      _ -> [
        Range(..left, end_exclusive: intersection.start),
        intersection,
        Range(..right, start: intersection.end_exclusive),
      ]
    }
  })
}

fn overlaps(this: Range, with other: Range) {
  overlaps_unidirectional(this, other) || overlaps_unidirectional(other, this)
}

fn overlaps_unidirectional(this: Range, with other: Range) -> Bool {
  other.start <= this.start && this.start < other.end_exclusive
}

fn contains(this: Range, other: Range) -> Bool {
  this.start <= other.start && other.end_exclusive <= this.end_exclusive
}

pub fn intersection(between this: Range, and other: Range) -> Result(Range, Nil) {
  result.lazy_or(
    intersection_unidirectional(between_left: this, and_right: other),
    fn() { intersection_unidirectional(between_left: other, and_right: this) },
  )
}

/// Returns the intersection between first and second.
/// ```
/// first:  |-----|
/// second:     |-----|
/// result:     |-|
/// 
/// first:  |-----|
/// second:        |-----|
/// result: Nil
/// ```
/// 
/// `Range`s cannot go in a descending direction.
/// ```
/// first:      |-----|
/// second: |-----|
/// result: Nil
/// ```
fn intersection_unidirectional(
  between_left left: Range,
  and_right right: Range,
) -> Result(Range, Nil) {
  use <- bool.guard(right.start < left.start, Error(Nil))

  let delta = left.end_exclusive - right.start

  Ok(Range(..right, end_exclusive: right.start + delta))
}
