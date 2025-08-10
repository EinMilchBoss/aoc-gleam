import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option}
import year_2023/day_05/almanac
import year_2023/day_05/entry.{type EntryRanges}
import year_2023/day_05/map.{type Map}
import year_2023/day_05/range.{type Range}

pub fn solve(input: String) -> String {
  let almanac = almanac.from_string(input)

  let input_ranges = almanac |> almanac.seed_ranges()
  let output_ranges = almanac.maps |> list.fold(input_ranges, process_map)

  let assert Ok(min) =
    output_ranges
    |> list.map(fn(range) { range.start })
    |> list.reduce(int.min)

  int.to_string(min)
}

fn process_map(input_ranges: List(Range), map: Map) -> List(Range) {
  let #(split_input_ranges, offset_intersections) =
    for_each_input_range(
      input_ranges,
      map.entries |> list.map(entry.to_entry_ranges),
      [],
      [],
    )

  list.concat([split_input_ranges, offset_intersections])
}

/// First are the split input ranges.
/// Second are the offset intersections.
fn for_each_input_range(
  input_ranges: List(Range),
  entry_rangess: List(EntryRanges),
  acc_split_input_ranges: List(Range),
  acc_offset_intersections: List(Range),
) -> #(List(Range), List(Range)) {
  case input_ranges {
    [] -> #(acc_split_input_ranges, acc_offset_intersections)
    [input_range, ..remaining_input_ranges] -> {
      let #(split_input_ranges, offset_intersections) =
        for_each_entry_ranges(input_range, entry_rangess, [], [])

      for_each_input_range(
        remaining_input_ranges,
        entry_rangess,
        list.concat([split_input_ranges, acc_split_input_ranges]),
        list.concat([offset_intersections, acc_offset_intersections]),
      )
    }
  }
}

/// First are the split input ranges.
/// Second are the offset intersections.
fn for_each_entry_ranges(
  input_range: Range,
  entry_rangess: List(EntryRanges),
  acc_split_input_ranges: List(Range),
  acc_offset_intersections: List(Range),
) -> #(List(Range), List(Range)) {
  echo acc_split_input_ranges as "split input ranges"
  case entry_rangess {
    [] -> #(acc_split_input_ranges, acc_offset_intersections)
    [entry_ranges, ..remaining_entry_rangess] -> {
      let #(offset_intersection, split_input_ranges) =
        split_by_intersection_and_offset(
          between: input_range,
          and: entry_ranges,
        )

      let offset_intersection =
        offset_intersection
        |> option.map(fn(range) { [range] })
        |> option.unwrap([])

      case split_input_ranges {
        [] -> {
          for_each_entry_ranges(
            input_range,
            remaining_entry_rangess,
            list.concat([split_input_ranges, acc_split_input_ranges]),
            list.concat([offset_intersection, acc_offset_intersections]),
          )
        }
        [a] -> {
          for_each_entry_ranges(
            a,
            remaining_entry_rangess,
            list.concat([split_input_ranges, acc_split_input_ranges]),
            list.concat([offset_intersection, acc_offset_intersections]),
          )
        }
        [a, b] -> {
          let a_out = for_each_entry_ranges(a, remaining_entry_rangess, [], [])

          let b_out = for_each_entry_ranges(b, remaining_entry_rangess, [], [])

          #(
            list.concat([a_out.0, b_out.0, acc_split_input_ranges]),
            list.concat([a_out.1, b_out.1, acc_offset_intersections]),
          )
        }
        _ -> panic as "there should only be 0 - 2 parts left of the input range"
      }
    }
  }
}

/// First is the offset intersection.
/// Second is the intersection list.
fn split_by_intersection_and_offset(
  between input_range: Range,
  and entry_ranges: EntryRanges,
) -> #(Option(Range), List(Range)) {
  case
    split_by_intersection(between: input_range, and: entry_ranges.source_range)
  {
    #(option.None, remaining) -> #(option.None, remaining)
    #(option.Some(intersection), remaining) -> {
      let offset_intersection =
        intersection |> range.offset(by: entry.get_offset(from: entry_ranges))
      #(option.Some(offset_intersection), remaining)
    }
  }
}

/// Splits the `Range` into one to three `Range`s based on the intersection.
/// - If the intersection is the entire `Range` or there is no intersection, there will be only one element.
/// - If the intersection is at the start or end of the `Range`, there will be two elements.
/// - If the intersection is in the middle of the `Range`, there will be three elements.
/// 
/// The intersection is the first element of the tuple. The list contains the remaining `Range`s.
fn split_by_intersection(
  between super: Range,
  and sub: Range,
) -> #(Option(Range), List(Range)) {
  case intersection(between: super, and: sub) {
    Error(_) -> #(option.None, [super])
    Ok(intersection) -> {
      // Intersection is the entire `Range`.
      use <- bool.guard(
        when: intersection |> range.is_equal(to: super),
        return: #(option.Some(super), []),
      )

      // At the beginning.
      use <- bool.guard(
        when: intersection.start == super.start,
        return: #(option.Some(intersection), [
          range.Range(
            start: intersection.end_exclusive,
            end_exclusive: super.end_exclusive,
          ),
        ]),
      )

      // At the end.
      use <- bool.guard(
        when: intersection.end_exclusive == super.end_exclusive,
        return: #(option.Some(intersection), [
          range.Range(start: super.start, end_exclusive: intersection.start),
        ]),
      )

      // In the middle.
      #(option.Some(intersection), [
        range.Range(..super, end_exclusive: intersection.start),
        range.Range(..super, start: intersection.end_exclusive),
      ])
    }
  }
}

fn intersection(between super: Range, and sub: Range) -> Result(Range, Nil) {
  use <- bool.guard(
    when: super.start > sub.end_exclusive || sub.start > super.end_exclusive,
    return: Error(Nil),
  )

  let start = int.max(super.start, sub.start)
  let end_exclusive = int.min(super.end_exclusive, sub.end_exclusive)
  Ok(range.Range(start:, end_exclusive:))
}
